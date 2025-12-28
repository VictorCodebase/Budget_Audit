// lib/core/services/parser/equity_parser.dart

import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';

/**
 * TODO: Issue
 * the parser does not distinguish money out from money in. It records them as moey out
 */

class EquityParser extends StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.equity;

  /// Regex to parse transaction rows from Equity Bank statements
  /// Matches: [Date] [Value Date] [Particulars] [Money Out] [Money In] [Balance]
  ///
  /// Group 1: Date (DD-MM-YYYY format)
  /// Group 2: Value Date (optional, DD-MM format)
  /// Group 3: Particulars (transaction details)
  /// Group 4: Money Out (optional amount)
  /// Group 5: Money In (optional amount)
  /// Group 6: Balance (with Cr/Dr indicator)
  static final RegExp _transactionRowPattern = RegExp(
    // 1. Date: DD-MM-YYYY
    r'(\d{2}-\d{2}-\d{4})'
    r'\s+'
    // 2. Value Date: DD-MM (optional, may not always be present)
    r'(\d{2}-\d{2})?'
    r'\s*'
    // 3. Particulars: Non-greedy capture until we hit amount patterns
    r'(.+?)'
    r'\s+'
    // 4. Money Out: Optional amount (numbers with commas and decimals)
    r'([\d,]+\.\d{2})?'
    r'\s+'
    // 5. Money In: Optional amount
    r'([\d,]+\.\d{2})?'
    r'\s+'
    // 6. Balance: Amount followed by Cr or Dr
    r'([\d,]+\.\d{2}\s+(?:Cr|Dr))',
    multiLine: true,
    dotAll: true,
  );

  @override
  Future<ValidationResult> validateDocument(
    File pdfFile, {
    String? password,
  }) async {
    PdfDocument? document;
    try {
      document = PdfDocument(
          inputBytes: pdfFile.readAsBytesSync(), password: password);
      String text = PdfTextExtractor(document).extractText();

      // Check 1: Institution Markers
      if (!containsInstitutionMarkers(text)) {
        return const ValidationResult(
          canParse: false,
          errorMessage: "Does not appear to be an Equity Bank statement.",
          missingCheckpoints: ["Equity Bank Header"],
        );
      }

      // Check 2: Key Column Headers
      final requiredHeaders = [
        "Date",
        "Particulars",
        "Money Out",
        "Money In",
        "Balance"
      ];

      final missingHeaders = <String>[];
      for (var header in requiredHeaders) {
        if (!text.contains(header)) {
          missingHeaders.add(header);
        }
      }

      if (missingHeaders.isNotEmpty) {
        return ValidationResult(
          canParse: false,
          errorMessage: "Missing required column headers.",
          missingCheckpoints: missingHeaders,
        );
      }

      return const ValidationResult.success();
    } catch (e) {
      return ValidationResult(
        canParse: false,
        errorMessage: "Failed to open PDF: ${e.toString()}",
      );
    } finally {
      document?.dispose();
    }
  }

  @override
  Future<ParseResult> parseDocument(
    File pdfFile,
    UploadedDocument documentMetadata, {
    String? password,
  }) async {
    PdfDocument? document;
    final transactions = <ParsedTransaction>[];

    try {
      document = PdfDocument(
          inputBytes: pdfFile.readAsBytesSync(), password: password);

      String fullText = PdfTextExtractor(document).extractText();
      final uuid = const Uuid();

      // Debug: Uncomment to see extracted text
      // print('--- RAW PDF EXTRACTED TEXT START ---');
      // print(fullText);
      // print('--- RAW PDF EXTRACTED TEXT END ---');

      // Iterate over all transaction matches
      for (final match in _transactionRowPattern.allMatches(fullText)) {
        final rawDate = match.group(1);
        final rawParticulars = match.group(3);
        final rawMoneyOut = match.group(4);
        final rawMoneyIn = match.group(5);

        if (rawDate == null || rawParticulars == null) continue;

        // Skip non-transaction rows (like "Page Total:", "Grand Total:", etc.)
        if (rawParticulars.contains('Total:') ||
            rawParticulars.contains('Uncleared') ||
            rawParticulars.contains('Foreign exchange') ||
            rawParticulars.contains('Contact your Manager')) {
          continue;
        }

        final transactionDate = parseDate(rawDate);
        if (transactionDate == null) {
          continue;
        }

        // Parse amounts
        double? moneyOut =
            rawMoneyOut != null ? parseAmount(rawMoneyOut) : null;
        double? moneyIn = rawMoneyIn != null ? parseAmount(rawMoneyIn) : null;

        // Determine final amount (Income vs Expense)
        double finalAmount = 0.0;

        if (moneyIn != null && moneyIn > 0) {
          finalAmount = moneyIn; // Positive for income
        } else if (moneyOut != null && moneyOut > 0) {
          finalAmount = -moneyOut; // Negative for expenses
        } else {
          // Skip zero-value transactions
          continue;
        }

        transactions.add(ParsedTransaction(
          id: uuid.v4(),
          date: transactionDate,
          vendorName: normalizeVendorName(rawParticulars),
          amount: finalAmount,
          originalDescription: rawParticulars.trim(),
          useMemory: false,
        ));
      }

      return ParseResult(
        success: true,
        transactions: transactions,
        document: documentMetadata,
      );
    } catch (e) {
      return ParseResult(
        success: false,
        errorMessage: "Error parsing Equity Bank PDF: $e",
        document: documentMetadata,
        transactions: [],
      );
    } finally {
      document?.dispose();
    }
  }

  @override
  String normalizeVendorName(String rawVendor) {
    // Clean up the particulars field to extract meaningful vendor names
    var cleaned = rawVendor.trim();

    // Remove common transaction type prefixes
    cleaned = cleaned
        .replaceAll(
            RegExp(r'^(APP/MPESA|MPESA|VISA-GOOGLE|VISA-)',
                caseSensitive: false),
            '')
        .trim();

    // Handle M-PESA transactions - extract reference after last slash
    if (cleaned.contains('/')) {
      final parts = cleaned.split('/');
      // Get the last meaningful part
      if (parts.length > 1) {
        cleaned = parts.last.trim();
      }
    }

    // Handle transaction charges
    if (cleaned.toUpperCase().contains('TRANSACTION') &&
        cleaned.toUpperCase().contains('CHARGE')) {
      return 'Equity Bank Charges';
    }

    // Handle SMS charges
    if (cleaned.toUpperCase().contains('SMS CHARGE')) {
      return 'Equity SMS Charges';
    }

    // Handle VISA transactions - clean up the vendor name
    if (cleaned.contains('*')) {
      // Pattern like: *HDEC *PUR/531870812840
      // Extract the meaningful part before PUR or other codes
      final parts = cleaned.split('*');
      if (parts.length > 1) {
        cleaned = parts[1].split('/').first.trim();
      }
    }

    // Remove transaction reference codes (patterns like A6B95B8340C32)
    cleaned = cleaned.replaceAll(RegExp(r'[A-Z0-9]{10,}'), '').trim();

    // Remove extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned.isEmpty ? rawVendor.trim() : cleaned;
  }

  @override
  DateTime? parseDate(String dateString) {
    // Format: DD-MM-YYYY (e.g., 10-11-2025)
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  @override
  bool containsInstitutionMarkers(String pdfText) {
    final upperText = pdfText.toUpperCase();
    return upperText.contains('EQUITY') &&
        (upperText.contains('STATEMENT OF ACCOUNT') ||
            upperText.contains('EQUITY BANK'));
  }

  @override
  List<List<String>> extractTableData(String pdfText) {
    // Not used in this regex-based implementation
    return [];
  }
}

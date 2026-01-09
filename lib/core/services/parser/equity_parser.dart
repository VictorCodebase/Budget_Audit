// lib/core/services/parser/equity_parser.dart

import 'dart:io';
import 'package:budget_audit/core/services/parser/parser_mixin.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';



class EquityParser with ParserMixin implements StatementParser {
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
  ///
  /// I am trying to use the balance to determine if the transaction is a deposit or withdrawal
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
      // Validate PDF openability/security
      final unlockResult = await unlockPdf(pdfFile, password);
      if (unlockResult != ValidationErrorType.none) {
        return ValidationResult.failure(
          error: unlockResult == ValidationErrorType.passwordRequired
              ? 'Document is password protected'
              : 'Incorrect password',
          missing: ['PDF unlock failed'],
          type: unlockResult,
        );
      }

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

      // New regex that captures: Date, Particulars (everything in between), ONE amount, and Balance
      final rowPattern = RegExp(
        r'(\d{2}-\d{2}-\d{4})' // Date
        r'\s+'
        r'(?:\d{2}-\d{2}\s+)?' // Optional value date
        r'(.+?)' // Particulars (non-greedy)
        r'\s+'
        r'([\d,]+\.\d{2})' // The amount (either Money Out or Money In - we'll determine from balance)
        r'\s+'
        r'([\d,]+\.\d{2})\s+(Cr|Dr)', // Balance with indicator
        multiLine: true,
      );

      double? previousBalance;

      // First, find the initial balance (opening balance row)
      final openingBalancePattern = RegExp(
        r'(?:Balance Brought Forward|Opening Balance|B/F).*?([\d,]+\.\d{2})\s+(Cr|Dr)',
        caseSensitive: false,
      );

      final openingMatch = openingBalancePattern.firstMatch(fullText);
      if (openingMatch != null) {
        previousBalance = parseAmount(openingMatch.group(1)!);
        // Handle Dr balances as negative if needed
        if (openingMatch.group(2)?.toUpperCase() == 'DR') {
          previousBalance = -previousBalance!;
        }
      }

      // If no explicit opening balance, use the first transaction's balance as reference
      final allMatches = rowPattern.allMatches(fullText).toList();

      for (int i = 0; i < allMatches.length; i++) {
        final match = allMatches[i];

        final rawDate = match.group(1);
        final rawParticulars = match.group(2);
        final rawAmount = match.group(3);
        final rawBalance = match.group(4);
        final balanceIndicator = match.group(5);

        if (rawDate == null ||
            rawParticulars == null ||
            rawAmount == null ||
            rawBalance == null) continue;

        // Skip non-transaction rows
        if (rawParticulars.contains('Total:') ||
            rawParticulars.contains('Uncleared') ||
            rawParticulars.contains('Foreign exchange') ||
            rawParticulars.contains('Contact your Manager') ||
            rawParticulars.contains('Balance Brought Forward') ||
            rawParticulars.contains('Opening Balance')) {
          continue;
        }

        final transactionDate = parseDate(rawDate);
        if (transactionDate == null) continue;

        final amount = parseAmount(rawAmount);
        final currentBalance = parseAmount(rawBalance);

        if (amount == null || currentBalance == null) continue;

        // Initialize previousBalance if this is the first transaction
        if (previousBalance == null) {
          // Work backwards: if current balance is higher than amount, it was income
          // if current balance is lower, we need to figure it out from the pattern
          previousBalance = currentBalance - amount; // Assume income first
          if (previousBalance < 0) {
            previousBalance =
                currentBalance + amount; // It was actually expense
          }
        }

        // Determine transaction type by comparing balances
        double finalAmount;
        bool isIncome;

        if (currentBalance > previousBalance) {
          // Balance increased = Money In
          isIncome = true;

          finalAmount = currentBalance - previousBalance;
        } else {
          // Balance decreased = Money Out
          isIncome = false;
          finalAmount = previousBalance - currentBalance;
        }

        // Verify the amount matches what we extracted
        // (there might be small rounding differences)
        if ((finalAmount - amount).abs() > 0.02) {
          // Amount mismatch - log warning but continue
          print(
              'Warning: Calculated amount ($finalAmount) differs from extracted amount ($amount)');
        }

        transactions.add(ParsedTransaction(
          id: uuid.v4(),
          date: transactionDate,
          vendorName: normalizeVendorName(rawParticulars),
          amount: isIncome ? finalAmount : -finalAmount,
          ignoreTransaction: isIncome, //! Ignore income transactions
          originalDescription: rawParticulars.trim(),
          useMemory: true,
        ));

        // Update previousBalance for next iteration
        previousBalance = currentBalance;
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

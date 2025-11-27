// lib/core/services/parser/mpesa_parser.dart

import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';

class MPesaParser implements StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.mpesa;

  /// Regex to parse a transaction line based on the Image provided.
  /// Matches: [Receipt] [Date Time] [Details] [Status] [Paid In] [Withdrawn] [Balance]
  ///
  /// Group 1: Date Time (e.g., 2025-11-24 19:53:55)
  /// Group 2: Details (The text in the middle)
  /// Group 3: Status (COMPLETED/FAILED)
  /// Group 4: Paid In (Amount)
  /// Group 5: Withdrawn (Amount)
  static final RegExp _transactionRowPattern = RegExp(
    // Date: YYYY-MM-DD HH:MM:SS
    r'(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s+'
    // Details: Non-greedy match until we hit the status
    r'(.+?)\s+'
    // Status
    r'(COMPLETED|FAILED)\s+'
    // Paid In (allow commas and decimals)
    r'([\d,]+\.\d{2})\s+'
    // Withdrawn (allow commas and decimals)
    r'([\d,]+\.\d{2})\s+'
    // Balance (trailing)
    r'([\d,]+\.\d{2})',
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
          errorMessage: "Does not appear to be an M-PESA statement.",
          missingCheckpoints: ["M-PESA Header"],
        );
      }

      // Check 2: Key Column Headers from the image
      final requiredHeaders = [
        "Receipt No",
        "Completion Time",
        "Details",
        "Paid in",
        "Withdrawn"
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

      // Extract all text. For multi-page statements, we iterate.
      // Syncfusion extracts text page-by-page.
      String fullText = PdfTextExtractor(document).extractText();

      // Split into lines for processing
      final lines = fullText.split('\n');
      final uuid = const Uuid();

      for (var line in lines) {
        line = line.trim();

        // Skip irrelevant lines
        if (line.isEmpty ||
            line.contains("DETAILED STATEMENT") ||
            line.contains("Receipt No")) {
          continue;
        }

        // Apply Regex
        final match = _transactionRowPattern.firstMatch(line);
        if (match != null) {
          final rawDate = match.group(1)!;
          final rawDetails = match.group(2)!;
          final status = match.group(3)!;
          final rawPaidIn = match.group(4)!;
          final rawWithdrawn = match.group(5)!;

          // Requirement 1: Only include Completed transactions
          if (status.toUpperCase() != 'COMPLETED') continue;

          // Parse Amounts
          double paidIn = parseAmount(rawPaidIn) ?? 0.0;
          double withdrawn = parseAmount(rawWithdrawn) ?? 0.0;

          // Determine final amount (Income vs Expense)
          // Income = Positive, Expense = Negative
          double finalAmount = 0.0;

          if (paidIn > 0) {
            finalAmount = paidIn;
          } else if (withdrawn > 0) {
            finalAmount = -withdrawn; // Negate expenses
          } else {
            // Skip zero-value transactions (e.g. failed or purely informational)
            continue;
          }

          transactions.add(ParsedTransaction(
            id: uuid.v4(),
            date: parseDate(rawDate) ?? DateTime.now(),
            vendorName: normalizeVendorName(rawDetails),
            amount: finalAmount,
            originalDescription: rawDetails,
            useMemory: false, // Default for new parsing
          ));
        }
      }

      return ParseResult(
        success: true,
        transactions: transactions,
        document: documentMetadata,
      );
    } catch (e) {
      return ParseResult(
        success: false,
        errorMessage: "Error parsing M-PESA PDF: $e",
        document: documentMetadata,
        transactions: [],
      );
    } finally {
      document?.dispose();
    }
  }

@override
  String normalizeVendorName(String rawVendor) {
    // 1. Handle Special Cases FIRST (Bundles, Overdrafts, etc.)
    // These need specific naming regardless of what follows the dash.
    
    // Pattern: "OD Loan Repayment to..." -> "M-PESA Overdraft"
    if (rawVendor.contains("OD Loan Repayment")) {
      return "M-PESA Overdraft";
    }

    // Pattern: "Customer Bundle Purchase..." -> "Safaricom Data Bundles"
    if (rawVendor.contains("Bundle Purchase") || rawVendor.contains("DATA BUNDLES")) {
      return "Safaricom Data Bundles";
    }
    
    // 2. Handle Generic "Name - Number" or "Type Number - Name" patterns
    // Example: "Customer Payment to Small Business to 0716***929 - ALICE NJERI"
    if (rawVendor.contains(" - ")) {
      final parts = rawVendor.split(" - ");
      if (parts.length > 1) {
        // Return the part after the dash (the actual name)
        return parts.last.trim(); 
      }
    }

    // 3. Fallback cleanup if no dash was found
    // Remove common prefixes
    var cleaned = rawVendor
        .replaceAll(RegExp(r'(Customer Transfer of Funds Charge)'), 'M-PESA Charge')
        .replaceAll(RegExp(r'Sent to |Received from |Paid to |Withdraw from |Deposit to '), '')
        .trim();

    return cleaned;
  }
  @override
  DateTime? parseDate(String dateString) {
    // Format based on Image: YYYY-MM-DD HH:MM:SS
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  @override
  double? parseAmount(String amountString) {
    // Remove commas, spaces, currency codes
    final cleaned = amountString.replaceAll(RegExp(r'[KSh\s,]'), '').trim();
    try {
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  @override
  bool containsInstitutionMarkers(String pdfText) {
    return pdfText.toUpperCase().contains('MPESA FULL STATEMENT') ||
        pdfText.toUpperCase().contains('SAFARICOM') ||
        pdfText.toUpperCase().contains('M-PESA');
  }

  @override
  Future<bool> unlockPdf(File pdfFile, String? password) async {
    try {
      final doc = PdfDocument(
          inputBytes: pdfFile.readAsBytesSync(), password: password);
      doc.dispose();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Unused helper for this specific implementation as we use Regex parsing
  @override
  List<List<String>> extractTableData(String pdfText) {
    return [];
  }
}

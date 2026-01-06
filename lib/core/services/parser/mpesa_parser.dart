// lib/core/services/parser/mpesa_parser.dart

import 'dart:io';
import 'package:budget_audit/core/services/parser/parser_mixin.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';


class MPesaParser with ParserMixin implements StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.mpesa;

  static const String _separator = r'\s+';

  /// Regex to parse a transaction line based on the Image provided.
  /// Matches: [Receipt] [Date Time] [Details] [Status] [Paid In] [Withdrawn] [Balance]
  ///
  /// Group 1: Date Time (e.g., 2025-11-24 19:53:55)
  /// Group 2: Details (The text in the middle)
  /// Group 3: Status (COMPLETED/FAILED)
  /// Group 4: Paid In (Amount)
  /// Group 5: Withdrawn (Amount)
  static final RegExp _transactionRowPattern = RegExp(
    // 0. Skip Receipt No (e.g., TKDATA1A7V)
    r'.*?'
    // 1. Date: YYYY-MM-DD HH:MM:SS
    r'(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})'
    r'\s+'
    // 2. Details: Non-greedy, allowing newlines until Status
    r'(.+?)'
    r'\s+'
    // 3. Status
    r'(COMPLETED|FAILED)'
    r'\s+'
    // 4. Paid In
    r'([\d,]+\.\d{2})'
    r'\s+'
    // 5. Withdrawn
    r'([\d,]+\.\d{2})'
    r'\s+'
    // 6. Balance
    r'([\d,]+\.\d{2})',

    // and DOT ALL (s) flag to allow . to match newlines within the details.
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

      String fullText = PdfTextExtractor(document).extractText();
      final uuid = const Uuid();

      // Modified regex: Capture TWO consecutive amounts (the Paid In and Withdrawn columns)
      final transactionRowPattern = RegExp(
        // Skip Receipt No
        r'.*?'
        // 1. Date: YYYY-MM-DD HH:MM:SS
        r'(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})'
        r'\s+'
        // 2. Details: Non-greedy until Status
        r'(.+?)'
        r'\s+'
        // 3. Status
        r'(COMPLETED|FAILED)'
        r'\s+'
        // 4. First Amount (could be Paid In or Withdrawn)
        r'([\d,]+\.\d{2})'
        r'\s+'
        // 5. Second Amount (the other one)
        r'([\d,]+\.\d{2})'
        r'\s+'
        // 6. Balance (we keep this for validation but don't strictly need it)
        r'([\d,]+\.\d{2})',
        multiLine: true,
        dotAll: true,
      );

      for (final match in transactionRowPattern.allMatches(fullText)) {
        final rawDate = match.group(1)!;
        final rawDetails = match.group(2)!;
        final status = match.group(3)!;
        final rawFirstAmount = match.group(4)!;
        final rawSecondAmount = match.group(5)!;

        // Skip non-completed transactions
        if (status.toUpperCase() != 'COMPLETED') continue;

        final transactionDate = parseDate(rawDate);
        if (transactionDate == null) {
          print("Transaction parse error: date not found");
          continue;
        }

        // Parse both amounts
        double firstAmount = parseAmount(rawFirstAmount) ?? 0.0;
        double secondAmount = parseAmount(rawSecondAmount) ?? 0.0;

        // Determine transaction type based on which amount is 0.00
        double transactionAmount;
        bool ignoreTransaction = false;

        if (firstAmount == 0.0 && secondAmount > 0.0) {
          // Pattern: 0.00 [amount] = Withdrawal (money out)
          transactionAmount = -secondAmount; // Negative for expense
          ignoreTransaction = false;
        } else if (firstAmount > 0.0 && secondAmount == 0.0) {
          // Pattern: [amount] 0.00 = Deposit (money in)
          transactionAmount = firstAmount; // Positive for income
          ignoreTransaction = true; // Application focuses on expenditures
        } else if (firstAmount == 0.0 && secondAmount == 0.0) {
          // Both zero - skip this transaction entirely
          continue;
        } else {
          // Both have values (unusual) - log warning and skip
          print(
              "Warning: Both amounts present - First: $firstAmount, Second: $secondAmount");
          print("Details: $rawDetails");
          continue;
        }

        transactions.add(ParsedTransaction(
          id: uuid.v4(),
          date: transactionDate,
          vendorName: normalizeVendorName(rawDetails),
          amount: transactionAmount,
          originalDescription: rawDetails,
          ignoreTransaction: ignoreTransaction,
          useMemory: true,
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
    if (rawVendor.contains("Bundle Purchase") ||
        rawVendor.contains("DATA BUNDLES")) {
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
        .replaceAll(
            RegExp(r'(Customer Transfer of Funds Charge)'), 'M-PESA Charge')
        .replaceAll(
            RegExp(
                r'Sent to |Received from |Paid to |Withdraw from |Deposit to '),
            '')
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

  // @override
  // double? parseAmount(String amountString) {
  //   // Remove commas, spaces, currency codes
  //   final cleaned = amountString.replaceAll(RegExp(r'[KSh\s,]'), '').trim();
  //   try {
  //     return double.parse(cleaned);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  bool containsInstitutionMarkers(String pdfText) {
    return pdfText.toUpperCase().contains('MPESA FULL STATEMENT') ||
        pdfText.toUpperCase().contains('SAFARICOM') ||
        pdfText.toUpperCase().contains('M-PESA');
  }

  // Unused helper for this specific implementation as we use Regex parsing
  @override
  List<List<String>> extractTableData(String pdfText) {
    return [];
  }
}

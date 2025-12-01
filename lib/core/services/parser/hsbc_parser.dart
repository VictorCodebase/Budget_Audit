// lib/core/services/parser/hsbc_parser.dart

import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/**
 * ! Issue breakdown for when I puck up later:
 * 
 * The pdf reading mechanism is concatenating  different columns into a single mess that is difficult to 
 * uderstand without using very brittle key word matching ie: DatePaymenttypeanddetailsPaidoutPaidinBalance
 * There needs a way to understand spacing in between columns at pdf reading level
 * 
 * Im thiking of finally using syncfusion's text extraction with letter mapping
 * I tried prompting claude for this, The solution feels half baked. More like a suggestio of what could happen
 * Replace th parser with one that anderstands position
 * 
 * ! Detects Column Boundaries
 * _detectColumnBoundaries() // Finds "Date", "Paid out", "Paid in" X positions
 * 
 * 
 * ! Assigns Text to Columns by X Position
 * if (x >= _descriptionStart && x < _descriptionEnd) {
     description += text;
   } else if (x >= _paidOutStart && x < _paidOutEnd) {
     paidOut = text;
   }
 */

class HSBCParser extends StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.hsbc;

  // Single pattern that handles both old and new HSBC formats
  // The key insight: both formats have the same structure, just different spacing
  static final RegExp _transactionRowPattern = RegExp(
    r'(?:^|\s)' // Start of line or whitespace
    r'(?:(VIS|DD|TR|TFR|BP|OBP|CHQ|CR|\)\)\))\s+)?' // Group 1: Transaction Type (optional)
    r'(.+?)' // Group 2: Description (non-greedy)
    r'\s{2,}' // At least 2 spaces separator
    r'([\d,\.]*)\s*' // Group 3: Paid Out (may be empty)
    r'\s{2,}' // At least 2 spaces separator
    r'([\d,\.]*)\s*' // Group 4: Paid In (may be empty)
    r'(?:\s{2,}([\d,\.]+\s*[DC]?))?$', // Group 5: Balance (optional, may have D/C)
    multiLine: false,
  );

  @visibleForTesting
  static RegExp get transactionRowPattern => _transactionRowPattern;

  @override
  Future<ValidationResult> validateDocument(
    File pdfFile, {
    String? password,
  }) async {
    try {
      final canUnlock = await unlockPdf(pdfFile, password);
      if (!canUnlock) {
        return const ValidationResult(
          canParse: false,
          errorMessage: 'Unable to unlock PDF. Password may be incorrect.',
          missingCheckpoints: ['PDF unlock'],
        );
      }

      final document = PdfDocument(
        inputBytes: pdfFile.readAsBytesSync(),
        password: password,
      );

      final fullText = PdfTextExtractor(document).extractText();
      document.dispose();

      final missingCheckpoints = <String>[];

      print("\n\n ------ FULL TEXT -----");
      print(fullText);
      print("------ END FULL TEXT -----\n\n");

      if (!containsInstitutionMarkers(fullText)) {
        missingCheckpoints.add('HSBC institution markers');
      }

      // Check for column headers (flexible matching for OCR variations)
      final hasPaidOut = fullText.contains('Paid out') ||
          fullText.contains('£ Paid out') ||
          fullText.contains('Paid o ut');
      final hasPaidIn = fullText.contains('Paid in') ||
          fullText.contains('£ Paid in') ||
          fullText.contains('Paid i n');
      final hasBalance =
          fullText.contains('Balance') || fullText.contains('£ Balance');

      if (!hasPaidOut) missingCheckpoints.add('Paid out column header');
      if (!hasPaidIn) missingCheckpoints.add('Paid in column header');
      if (!hasBalance) missingCheckpoints.add('Balance column header');

      // Check for date pattern (DD MMM YY format)
      if (!RegExp(r'\d{1,2}\s+[A-Z][a-z]{2}\s+\d{2}').hasMatch(fullText)) {
        missingCheckpoints.add('Date format (DD MMM YY)');
      }

      if (missingCheckpoints.isNotEmpty) {
        return ValidationResult(
          canParse: false,
          errorMessage: 'Document does not match HSBC format',
          missingCheckpoints: missingCheckpoints,
        );
      }

      return const ValidationResult(
        canParse: true,
        errorMessage: null,
        missingCheckpoints: [],
      );
    } catch (e) {
      return ValidationResult(
        canParse: false,
        errorMessage: 'Error validating document: $e',
        missingCheckpoints: ['Document validation'],
      );
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
        inputBytes: pdfFile.readAsBytesSync(),
        password: password,
      );

      String fullText = PdfTextExtractor(document).extractText();
      final uuid = const Uuid();
      final lines = fullText.split('\n');

      DateTime? lastSeenDate;

      for (var i = 0; i < lines.length; i++) {
        var line = lines[i].trimRight();
        if (line.isEmpty) continue;

        // Look for date at start of line: "12 Jun 25"
        final dateMatch = RegExp(r'^\s*(\d{1,2}\s+[A-Z][a-z]{2}\s+\d{2})\s+')
            .firstMatch(line);

        if (dateMatch != null) {
          // Found a new date - update lastSeenDate
          lastSeenDate = _parseStatementDate(dateMatch.group(1)!);

          // Check if there's a transaction on the same line after the date
          final remainingLine = line.substring(dateMatch.end);
          if (remainingLine.trim().isNotEmpty) {
            final transMatch = _transactionRowPattern.firstMatch(remainingLine);
            if (transMatch != null && lastSeenDate != null) {
              final transaction = _extractTransaction(
                uuid: uuid,
                date: lastSeenDate,
                match: transMatch,
              );
              if (transaction != null) {
                transactions.add(transaction);
                print(
                    'DEBUG: Extracted transaction on date line: ${transaction.vendorName} - ${transaction.amount}');
              }
            }
          }
          continue;
        }

        // No date found - this is either:
        // 1. A same-day transaction (starts with transaction type like VIS, )))
        // 2. A continuation line (wrapped description - no transaction type, no amounts)
        if (lastSeenDate != null) {
          final transMatch = _transactionRowPattern.firstMatch(line);
          if (transMatch != null) {
            final transaction = _extractTransaction(
              uuid: uuid,
              date: lastSeenDate, // Use the last date we saw
              match: transMatch,
            );
            if (transaction != null) {
              transactions.add(transaction);
              print(
                  'DEBUG: Extracted same-day transaction: ${transaction.vendorName} - ${transaction.amount}');
            }
          }
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
        errorMessage: "Error parsing HSBC PDF: $e",
        document: documentMetadata,
        transactions: [],
      );
    } finally {
      document?.dispose();
    }
  }

  // Extract transaction from regex match
  ParsedTransaction? _extractTransaction({
    required Uuid uuid,
    required DateTime date,
    required RegExpMatch match,
  }) {
    final transType = match.group(1);
    final rawDetails = match.group(2)?.trim() ?? '';
    final rawPaidOut = match.group(3) ?? '';
    final rawPaidIn = match.group(4) ?? '';

    // Skip if no description or if it's a balance line
    if (rawDetails.isEmpty || _isBalanceLine(rawDetails)) {
      return null;
    }

    double paidOut = parseAmount(rawPaidOut) ?? 0.0;
    double paidIn = parseAmount(rawPaidIn) ?? 0.0;

    double finalAmount = 0.0;

    if (paidIn > 0 && paidOut == 0) {
      finalAmount = paidIn; // Income
    } else if (paidOut > 0 && paidIn == 0) {
      finalAmount = -paidOut; // Expense
    } else {
      return null; // Skip zero or ambiguous
    }

    if (finalAmount == 0.0) return null;

    return ParsedTransaction(
      id: uuid.v4(),
      date: date,
      vendorName: normalizeVendorName(rawDetails),
      amount: finalAmount,
      originalDescription: rawDetails,
      useMemory: false,
    );
  }

  // Check if description is a balance/summary line
  bool _isBalanceLine(String description) {
    final upper = description.toUpperCase();
    return upper.contains('BALANCE BROUGHT FORWARD') ||
        upper.contains('BALANCE CARRIED FORWARD') ||
        upper.contains('TOTAL PAID OUT') ||
        upper.contains('TOTAL PAID IN') ||
        upper == 'BALANCE';
  }

  DateTime? _parseStatementDate(String dateString) {
    const monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };

    try {
      final parts = dateString.trim().split(RegExp(r'\s+'));
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final monthNum = monthMap[parts[1]];
        final shortYear = parts[2];
        final fullYear = int.parse('20$shortYear');

        if (monthNum != null && day >= 1 && day <= 31) {
          return DateTime(fullYear, monthNum, day);
        }
      }
      return null;
    } catch (e) {
      print('Date parsing error for "$dateString": $e');
      return null;
    }
  }

  @override
  String normalizeVendorName(String rawVendor) {
    var cleaned = rawVendor
        // Remove transaction type codes
        .replaceAll(RegExp(r'^(?:VIS|DD|TR|BP|TFR|CHQ|OBP|CR|\)\)\))\s+'), '')
        // Remove common location names
        .replaceAll(RegExp(r'\b(LONDON|BRISTOL|SOUTHAMPTON|AVON)\b'), '')
        // Remove long numbers (sort codes, reference numbers)
        .replaceAll(RegExp(r'\d{6,}'), '')
        // Normalize whitespace
        .replaceAll(RegExp(r'[\u00A0\s]+'), ' ')
        .trim();

    return cleaned.isEmpty ? rawVendor.trim() : cleaned;
  }

  @override
  bool containsInstitutionMarkers(String pdfText) {
    final upperText = pdfText.toUpperCase();
    
    return upperText.contains('HSBC') &&
        (upperText.contains('ADVANCE') ||
            upperText.contains('YOUR STATEMENT') ||
            upperText.contains('YOUR STUDENT BANK ACCOUNT') ||
            upperText.contains('HSBC UK'));
  }

  @override
  DateTime? parseDate(String dateString) {
    return _parseStatementDate(dateString);
  }

  @override
  double? parseAmount(String amountString) {
    if (amountString.isEmpty) return null;
    final cleaned = amountString
        .replaceAll(RegExp(r'[£,\s]'), '')
        .replaceAll(RegExp(r'[DC]$'), '') // Remove D/C suffix
        .trim();
    if (cleaned.isEmpty) return null;
    try {
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  @override
  List<List<String>> extractTableData(String pdfText) {
    final lines = pdfText.split('\n');
    final tableData = <List<String>>[];

    for (var line in lines) {
      final match = _transactionRowPattern.firstMatch(line);
      if (match != null) {
        tableData.add([
          match.group(2)?.trim() ?? '', // Description
          match.group(3)?.trim() ?? '', // Paid Out
          match.group(4)?.trim() ?? '', // Paid In
          match.group(5)?.trim() ?? '', // Balance
        ]);
      }
    }

    return tableData;
  }
}

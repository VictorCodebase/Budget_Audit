// lib/core/services/parser/hsbc_parser.dart

import 'dart:io';
import 'dart:ui';
import 'package:budget_audit/core/models/client_models.dart';
import 'package:uuid/uuid.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class HSBCParser extends StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.hsbc;

  // Column X-position boundaries (detected from header row)
  double? _dateColumnStart;
  double? _dateColumnEnd;
  double? _descriptionStart;
  double? _descriptionEnd;
  double? _paidOutStart;
  double? _paidOutEnd;
  double? _paidInStart;
  double? _paidInEnd;
  double? _balanceStart;

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

      if (!containsInstitutionMarkers(fullText)) {
        missingCheckpoints.add('HSBC institution markers');
      }

      // Flexible header matching
      final hasPaidOut =
          fullText.contains('Paid out') || fullText.contains('Paidout');
      final hasPaidIn =
          fullText.contains('Paid in') || fullText.contains('Paidin');
      final hasBalance = fullText.contains('Balance');

      if (!hasPaidOut) missingCheckpoints.add('Paid out column header');
      if (!hasPaidIn) missingCheckpoints.add('Paid in column header');
      if (!hasBalance) missingCheckpoints.add('Balance column header');

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

      final uuid = const Uuid();
      final extractor = PdfTextExtractor(document);

      // Extract text lines with spatial information
      final List<TextLine> allTextLines = extractor.extractTextLines();

      // Step 1: Detect column boundaries from header row
      _detectColumnBoundaries(allTextLines);

      print('DEBUG: Column boundaries detected:');
      print('  Date: $_dateColumnStart - $_dateColumnEnd');
      print('  Description: $_descriptionStart - $_descriptionEnd');
      print('  Paid Out: $_paidOutStart - $_paidOutEnd');
      print('  Paid In: $_paidInStart - $_paidInEnd');
      print('  Balance: $_balanceStart+');

      DateTime? lastSeenDate;

      // Step 2: Process each line using spatial column detection
      for (var line in allTextLines) {
        final lineText = line.text.trim();
        if (lineText.isEmpty) continue;

        // Skip header and balance lines
        if (_isHeaderOrBalanceLine(lineText)) {
          continue;
        }

        // Check for date in the line
        final dateMatch =
            RegExp(r'(\d{1,2}\s+[A-Z][a-z]{2}\s+\d{2})').firstMatch(lineText);
        if (dateMatch != null) {
          lastSeenDate = _parseStatementDate(dateMatch.group(1)!);
        }

        // Try to parse as transaction using spatial columns
        if (lastSeenDate != null && _descriptionStart != null) {
          final transaction = _parseLineWithSpatialInfo(
            line,
            lastSeenDate,
            uuid,
            allTextLines,
          );

          if (transaction != null) {
            transactions.add(transaction);
            print(
                'DEBUG: ✓ ${transaction.vendorName} - £${transaction.amount.toStringAsFixed(2)}');
          }
        }
      }

      print('DEBUG: Total transactions extracted: ${transactions.length}');

      return ParseResult(
        success: true,
        transactions: transactions,
        document: documentMetadata,
      );
    } catch (e) {
      print('ERROR: $e');
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

  // Detect column boundaries by finding header words
  void _detectColumnBoundaries(List<TextLine> lines) {
    for (var line in lines) {
      final words = line.wordCollection;

      for (var word in words) {
        final text = word.text.toLowerCase();
        final x = word.bounds.left;

        // Find "Date" or similar
        if (text.contains('date') && _dateColumnStart == null) {
          _dateColumnStart = x;
          _dateColumnEnd = x + 80; // Approximate width
        }

        // Find "Paid out" or "Paidout"
        if ((text.contains('paid') && text.contains('out')) ||
            text.contains('paidout')) {
          _paidOutStart = x;
          _paidOutEnd = x + 80;
        }

        // Find "Paid in" or "Paidin"
        if ((text.contains('paid') && text.contains('in')) ||
            text.contains('paidin')) {
          _paidInStart = x;
          _paidInEnd = x + 80;
        }

        // Find "Balance"
        if (text.contains('balance')) {
          _balanceStart = x;
        }
      }
    }

    // Set description column between date and paid out
    if (_dateColumnEnd != null && _paidOutStart != null) {
      _descriptionStart = _dateColumnEnd!;
      _descriptionEnd = _paidOutStart!;
    }
  }

  // Parse a line using spatial column information
  ParsedTransaction? _parseLineWithSpatialInfo(
    TextLine line,
    DateTime date,
    Uuid uuid,
    List<TextLine> allLines,
  ) {
    // If column boundaries not detected, fall back to regex
    if (_descriptionStart == null) {
      return null;
    }

    final words = line.wordCollection;

    String description = '';
    String paidOut = '';
    String paidIn = '';

    // Extract text from each column based on X position
    for (var word in words) {
      final x = word.bounds.left;
      final text = word.text.trim();

      if (text.isEmpty) continue;

      // Determine which column this word belongs to
      if (_descriptionStart != null &&
          _descriptionEnd != null &&
          x >= _descriptionStart! &&
          x < _descriptionEnd!) {
        // Description column
        description += text + ' ';
      } else if (_paidOutStart != null &&
          _paidOutEnd != null &&
          x >= _paidOutStart! &&
          x < _paidOutEnd!) {
        // Paid out column
        paidOut = text;
      } else if (_paidInStart != null &&
          _paidInEnd != null &&
          x >= _paidInStart! &&
          x < _paidInEnd!) {
        // Paid in column
        paidIn = text;
      }
    }

    description = description.trim();

    // Skip if no description
    if (description.isEmpty) return null;

    // Skip transaction type codes if they appear alone
    if (RegExp(r'^(VIS|DD|DR|BP|CR|TFR|OBP|CHQ|\)\)\))$')
        .hasMatch(description)) {
      return null;
    }

    // Parse amounts - be very careful here
    final paidOutAmount = _parseAmountSafely(paidOut);
    final paidInAmount = _parseAmountSafely(paidIn);

    double finalAmount = 0.0;
    if (paidInAmount > 0 && paidOutAmount == 0) {
      finalAmount = paidInAmount; // Income
    } else if (paidOutAmount > 0 && paidInAmount == 0) {
      finalAmount = -paidOutAmount; // Expense
    } else {
      return null; // Skip if both have values or both are zero
    }

    if (finalAmount == 0.0) return null;

    return ParsedTransaction(
      id: uuid.v4(),
      date: date,
      vendorName: normalizeVendorName(description),
      amount: finalAmount,
      originalDescription: description,
      useMemory: false,
    );
  }

  // Safely parse amount - only if it looks like a number
  double _parseAmountSafely(String text) {
    if (text.isEmpty) return 0.0;

    // Must contain digits
    if (!RegExp(r'\d').hasMatch(text)) return 0.0;

    // Remove currency symbols and commas
    final cleaned = text
        .replaceAll(RegExp(r'[£,\s]'), '')
        .replaceAll(RegExp(r'[DC]$'), '')
        .trim();

    if (cleaned.isEmpty) return 0.0;

    try {
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  bool _isHeaderOrBalanceLine(String text) {
    final upper = text.toUpperCase();
    return upper.contains('BALANCE BROUGHT FORWARD') ||
        upper.contains('BALANCE CARRIED FORWARD') ||
        upper.contains('TOTAL PAID OUT') ||
        upper.contains('TOTAL PAID IN') ||
        upper.contains('PAYMENT TYPE AND DETAILS') ||
        upper == 'DATE' ||
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
        .replaceAll(
            RegExp(r'^(?:VIS|DD|TR|BP|TFR|CHQ|OBP|CR|DR|\)\)\))\s+'), '')
        .replaceAll(RegExp(r'\b(LONDON|BRISTOL|SOUTHAMPTON|AVON)\b'), '')
        .replaceAll(RegExp(r'\d{6,}'), '')
        .replaceAll(RegExp(r'\bBACS PAYMENT\b'), '')
        .replaceAll(RegExp(r'\bBIB\b'), '')
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
            upperText.contains('YOUR CHARITABLE BANK ACCOUNT') ||
            upperText.contains('BUSINESS BANKING') ||
            upperText.contains('HSBC UK BANK'));
  }

  @override
  DateTime? parseDate(String dateString) {
    return _parseStatementDate(dateString);
  }

  @override
  double? parseAmount(String amountString) {
    return _parseAmountSafely(amountString);
  }

  @override
  List<List<String>> extractTableData(String pdfText) {
    // Not needed with spatial extraction
    return [];
  }

  // Expose for testing
  static RegExp get transactionRowPattern => RegExp(r''); // Not used anymore
}

// lib/core/services/parser/custom_parser.dart

import 'dart:io';
import 'package:budget_audit/core/services/parser/parser_mixin.dart';
import 'package:uuid/uuid.dart';
import '../../models/client_models.dart';
import 'parser_interface.dart';

/// Parser for custom/generic bank statements
///
/// This parser attempts to handle statements from unknown banks
/// by looking for common patterns across different statement formats.
///
/// Expected Minimum Structure:
/// - Some form of date column (various formats accepted)
/// - Description/vendor column
/// - Amount column (may be combined or separate debit/credit)
///
/// This parser is more lenient and uses heuristics to identify:
/// - Transaction tables (by finding repeating patterns)
/// - Date formats (tries multiple common formats)
/// - Amount formats (handles various currency symbols and separators)
class CustomParser with ParserMixin implements StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.custom;

  /// Checkpoints to verify in PDF:
  /// 1. At least one table-like structure
  /// 2. Repeating date patterns
  /// 3. Repeating number patterns (amounts)
  /// 4. Minimum 3 columns detected
  ///
  /// This is more lenient than institution-specific parsers
  @override
  Future<ValidationResult> validateDocument(
    File pdfFile, {
    String? password,
  }) async {
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
    // TODO: Implement custom validation
    //
    // Strategy:
    // 1. Extract all text
    // 2. Look for tabular data (aligned columns, repeating patterns)
    // 3. Try to identify date column (test multiple formats)
    // 4. Try to identify amount column (look for currency patterns)
    // 5. If both found, consider it parseable

    return const ValidationResult.success();
  }

  @override
  Future<ParseResult> parseDocument(
    File pdfFile,
    UploadedDocument documentMetadata, {
    String? password,
  }) async {
    // TODO: Implement custom parsing
    //
    // Strategy:
    // 1. Extract table data using heuristics
    // 2. Identify which columns contain dates, vendors, amounts
    // 3. Parse each row using flexible patterns
    // 4. Apply confidence scoring (warn user about uncertain parses)
    // 5. Return best-effort results

    return ParseResult(
      success: true,
      transactions: _generateSampleTransactions(documentMetadata),
      document: documentMetadata,
    );
  }

  @override
  bool containsInstitutionMarkers(String pdfText) {
    // Custom parser doesn't look for specific markers
    // Just check if it looks like a financial document
    final financialKeywords = [
      'statement',
      'account',
      'balance',
      'transaction',
      'debit',
      'credit',
      'date',
    ];

    final lowerText = pdfText.toLowerCase();
    return financialKeywords.any((keyword) => lowerText.contains(keyword));
  }

  @override
  List<List<String>> extractTableData(String pdfText) {
    // TODO: Implement intelligent table detection
    // Look for patterns of aligned text that repeats
    return [];
  }

  @override
  String normalizeVendorName(String rawVendor) {
    // Generic cleaning
    return rawVendor
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  @override
  DateTime? parseDate(String dateString) {
    // Try multiple common date formats
    final formats = [
      _tryParseDDMMYYYY,
      _tryParseDDMMMYYYY,
      _tryParseYYYYMMDD,
      _tryParseMMDDYYYY,
    ];

    for (final format in formats) {
      final result = format(dateString);
      if (result != null) return result;
    }

    return null;
  }

  DateTime? _tryParseDDMMYYYY(String dateString) {
    try {
      final parts = dateString.split(RegExp(r'[/\-.]'));
      if (parts.length != 3) return null;

      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return null;
    }
  }

  DateTime? _tryParseDDMMMYYYY(String dateString) {
    final months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    try {
      final parts = dateString.toLowerCase().split(' ');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = months[parts[1].substring(0, 3)];
      final year = int.parse(parts[2]);

      if (month == null) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  DateTime? _tryParseYYYYMMDD(String dateString) {
    try {
      final parts = dateString.split(RegExp(r'[/\-.]'));
      if (parts.length != 3) return null;

      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }

  DateTime? _tryParseMMDDYYYY(String dateString) {
    try {
      final parts = dateString.split(RegExp(r'[/\-.]'));
      if (parts.length != 3) return null;

      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  double? parseAmount(String amountString) {
    // Remove all currency symbols and separators
    final cleaned = amountString.replaceAll(RegExp(r'[^\d.\-+]'), '').trim();

    try {
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  List<ParsedTransaction> _generateSampleTransactions(
    UploadedDocument document,
  ) {
    final uuid = const Uuid();
    return List.generate(
      8,
      (index) => ParsedTransaction(
        id: uuid.v4(),
        date: DateTime.now().subtract(Duration(days: index * 2)),
        vendorName: 'Greggs PLC',
        amount: -2.90,
        useMemory: true,
      ),
    );
  }
}

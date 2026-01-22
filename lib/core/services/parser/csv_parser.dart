// lib/core/services/parser/csv_parser.dart

import 'dart:io';
import 'package:csv/csv.dart';
import 'parser_interface.dart';
import '../../models/client_models.dart';
import 'package:uuid/uuid.dart';

/// Parser for CSV (Comma-Separated Values) format files
///
/// Supports various CSV formats with flexible column mapping
class CSVParser extends StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.csv;

  // Common column name variations
  static const dateColumns = [
    'date',
    'transaction date',
    'posted date',
    'value date',
    'trans date'
  ];
  static const descriptionColumns = [
    'description',
    'memo',
    'details',
    'narrative',
    'transaction details'
  ];
  static const vendorColumns = [
    'vendor',
    'payee',
    'merchant',
    'name',
    'counterparty'
  ];
  static const amountColumns = ['amount', 'value', 'transaction amount'];
  static const debitColumns = [
    'debit',
    'withdrawal',
    'money out',
    'withdrawn',
    'dr'
  ];
  static const creditColumns = [
    'credit',
    'deposit',
    'money in',
    'paid in',
    'cr'
  ];

  @override
  Future<ValidationResult> validateDocument(
    File file, {
    String? password,
  }) async {
    try {
      final content = await file.readAsString();

      // Try to parse as CSV
      final csvData = const CsvToListConverter().convert(
        content,
        eol: '\n',
        shouldParseNumbers: false,
      );

      if (csvData.isEmpty) {
        return const ValidationResult.failure(
          error: 'CSV file is empty',
          type: ValidationErrorType.invalidFormat,
        );
      }

      if (csvData.length < 2) {
        return const ValidationResult.failure(
          error: 'CSV file must have at least a header row and one data row',
          type: ValidationErrorType.invalidFormat,
        );
      }

      // Validate headers
      final headers =
          csvData.first.map((e) => e.toString().toLowerCase().trim()).toList();
      final missingCheckpoints = <String>[];
      print("Captured headers: ${headers}");

      // Check for date column
      if (!_hasAnyColumn(headers, dateColumns)) {
        missingCheckpoints
            .add('Date column (e.g., "Date", "Transaction Date")');
      }

      // Check for amount columns (either combined or debit/credit)
      final hasAmount = _hasAnyColumn(headers, amountColumns);
      final hasDebitCredit = _hasAnyColumn(headers, debitColumns) &&
          _hasAnyColumn(headers, creditColumns);

      if (!hasAmount && !hasDebitCredit) {
        missingCheckpoints
            .add('Amount column (e.g., "Amount", "Debit/Credit")');
      }

      // Check for description or vendor column (at least one)
      if (!_hasAnyColumn(headers, descriptionColumns) &&
          !_hasAnyColumn(headers, vendorColumns)) {
        missingCheckpoints.add('Description or Vendor column');
      }

      if (missingCheckpoints.isNotEmpty) {
        return ValidationResult.failure(
          error:
              'Missing required CSV columns: ${missingCheckpoints.join(", ")}',
          missing: missingCheckpoints,
          type: ValidationErrorType.missingRequiredFields,
        );
      }

      return const ValidationResult.success();
    } catch (e) {
      return ValidationResult.failure(
        error: 'Error reading CSV file: $e',
        type: ValidationErrorType.fileReadError,
      );
    }
  }

  @override
  Future<ParseResult> parseDocument(
    File file,
    UploadedDocument documentMetadata, {
    String? password,
  }) async {
    try {
      final content = await file.readAsString();

      // Parse CSV
      final csvData = const CsvToListConverter().convert(
        content,
        eol: '\n',
        shouldParseNumbers: false,
      );

      if (csvData.length < 2) {
        return ParseResult(
          success: false,
          errorMessage:
              'CSV file must have at least a header row and one data row',
          transactions: const [],
          document: documentMetadata,
        );
      }

      // Get headers and create column mapping
      final headers =
          csvData.first.map((e) => e.toString().toLowerCase().trim()).toList();
      final columnMap = _createColumnMapping(headers);

      // Parse transactions
      final transactions = <ParsedTransaction>[];
      const uuid = Uuid();

      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];

        if (row.isEmpty ||
            row.every((cell) => cell.toString().trim().isEmpty)) {
          continue; // Skip empty rows
        }

        try {
          final transaction = _parseRow(row, columnMap, uuid);
          if (transaction != null) {
            transactions.add(transaction);
          }
        } catch (e) {
          // Skip rows that fail to parse
          continue;
        }
      }

      if (transactions.isEmpty) {
        return ParseResult(
          success: false,
          errorMessage: 'No valid transactions found in CSV file',
          transactions: const [],
          document: documentMetadata,
        );
      }

      return ParseResult(
        success: true,
        transactions: transactions,
        document: documentMetadata,
      );
    } catch (e) {
      return ParseResult(
        success: false,
        errorMessage: 'Error parsing CSV file: $e',
        transactions: const [],
        document: documentMetadata,
      );
    }
  }

  /// Checks if any column name from the list exists in headers
  bool _hasAnyColumn(List<String> headers, List<String> columnNames) {
    return columnNames.any((name) => headers.contains(name));
  }

  /// Creates a mapping of column types to their indices
  Map<String, int> _createColumnMapping(List<String> headers) {
    final map = <String, int>{};

    for (int i = 0; i < headers.length; i++) {
      final header = headers[i];

      // Date column
      if (dateColumns.contains(header)) {
        map['date'] = i;
      }
      // Description column
      else if (descriptionColumns.contains(header)) {
        map['description'] = i;
      }
      // Vendor column
      else if (vendorColumns.contains(header)) {
        map['vendor'] = i;
      }
      // Amount column
      else if (amountColumns.contains(header)) {
        map['amount'] = i;
      }
      // Debit column
      else if (debitColumns.contains(header)) {
        map['debit'] = i;
      }
      // Credit column
      else if (creditColumns.contains(header)) {
        map['credit'] = i;
      }
    }

    return map;
  }

  /// Parses a single CSV row into a ParsedTransaction
  ParsedTransaction? _parseRow(
    List<dynamic> row,
    Map<String, int> columnMap,
    Uuid uuid,
  ) {
    // Extract date
    final dateIdx = columnMap['date'];
    if (dateIdx == null || dateIdx >= row.length) return null;

    final dateStr = row[dateIdx].toString().trim();
    if (dateStr.isEmpty) return null;

    final date = _parseDate(dateStr);

    // Extract amount
    double amount;
    if (columnMap.containsKey('amount')) {
      final amountIdx = columnMap['amount']!;
      if (amountIdx >= row.length) return null;

      final amountStr = row[amountIdx].toString().trim();
      if (amountStr.isEmpty) return null;

      amount = _parseAmount(amountStr);
    } else if (columnMap.containsKey('debit') &&
        columnMap.containsKey('credit')) {
      // Handle debit/credit columns
      final debitIdx = columnMap['debit']!;
      final creditIdx = columnMap['credit']!;

      final debitStr = row[debitIdx].toString().trim();
      final creditStr = row[creditIdx].toString().trim();

      if (debitStr.isEmpty && creditStr.isEmpty) return null;

      final debit = debitStr.isNotEmpty ? _parseAmount(debitStr) : 0.0;
      final credit = creditStr.isNotEmpty ? _parseAmount(creditStr) : 0.0;

      // Debit is negative (expense), credit is positive (income)
      amount = credit - debit;
    } else {
      return null; // No amount information
    }

    // Extract vendor name
    String vendorName = 'Unknown';
    if (columnMap.containsKey('vendor')) {
      final vendorIdx = columnMap['vendor']!;
      if (vendorIdx < row.length) {
        final vendor = row[vendorIdx].toString().trim();
        if (vendor.isNotEmpty) {
          vendorName = vendor;
        }
      }
    }

    // Extract description
    String? description;
    if (columnMap.containsKey('description')) {
      final descIdx = columnMap['description']!;
      if (descIdx < row.length) {
        final desc = row[descIdx].toString().trim();
        if (desc.isNotEmpty) {
          description = desc;
        }
      }
    }

    // If no vendor was found, try to use description as vendor
    if (vendorName == 'Unknown' && description != null) {
      vendorName =
          description.split(' ').take(3).join(' '); // Use first few words
    }

    // Determine if transaction should be ignored (income or transfers)
    final shouldIgnore = amount > 0;

    return ParsedTransaction(
      id: uuid.v4(),
      date: date,
      originalDescription: description,
      vendorName: vendorName,
      amount: amount, // Keep negative for expenses, positive for income
      ignoreTransaction: shouldIgnore,
      useMemory: true,
    );
  }

  /// Parses date from various common formats
  DateTime _parseDate(String dateStr) {
    // Try common date formats
    final formats = [
      // ISO format: 2024-08-02
      RegExp(r'^(\d{4})-(\d{2})-(\d{2})'),
      // US format: 08/02/2024 or 8/2/2024
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})'),
      // UK format: 02/08/2024 or 2/8/2024
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})'),
      // Format: 02-Aug-2024
      RegExp(r'^(\d{1,2})-([A-Za-z]{3})-(\d{4})'),
    ];

    for (final format in formats) {
      final match = format.firstMatch(dateStr);
      if (match != null) {
        try {
          if (dateStr.contains('-') && dateStr.split('-')[0].length == 4) {
            // ISO format
            return DateTime.parse(dateStr.split(' ')[0]);
          } else if (dateStr.contains('/')) {
            // Try MM/DD/YYYY first (US format)
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              final month = int.tryParse(parts[0]);
              final day = int.tryParse(parts[1]);
              final year = int.tryParse(parts[2]);

              if (month != null && day != null && year != null) {
                // If month > 12, it's probably DD/MM/YYYY
                if (month > 12) {
                  return DateTime(year, day, month);
                }
                return DateTime(year, month, day);
              }
            }
          }
        } catch (e) {
          // Continue to next format
        }
      }
    }

    // Fallback: return current date
    return DateTime.now();
  }

  /// Parses amount from string, handling currency symbols and formatting
  double _parseAmount(String amountStr) {
    // Remove currency symbols, commas, and spaces
    String cleaned = amountStr.replaceAll(RegExp(r'[£$€¥,\s]'), '').trim();

    // Handle parentheses for negative amounts
    if (cleaned.startsWith('(') && cleaned.endsWith(')')) {
      cleaned = '-${cleaned.substring(1, cleaned.length - 1)}';
    }

    return double.tryParse(cleaned) ?? 0.0;
  }
}

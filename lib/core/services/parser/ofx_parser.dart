// lib/core/services/parser/ofx_parser.dart

import 'dart:io';
import 'package:xml/xml.dart';
import 'parser_interface.dart';
import '../../models/client_models.dart';
import 'package:uuid/uuid.dart';

/// Parser for OFX (Open Financial Exchange) format files
///
/// Handles both OFX v1 (SGML-like) and OFX v2 (XML) formats
class OfxParser extends StatementParser {
  @override
  FinancialInstitution get institution => FinancialInstitution.ofx;

  @override
  Future<ValidationResult> validateDocument(
    File file, {
    String? password,
  }) async {
    try {
      final content = await file.readAsString();

      // Check for OFX header
      if (!content.contains('OFXHEADER:')) {
        return const ValidationResult.failure(
          error: 'Missing OFXHEADER - not a valid OFX file',
          missing: ['OFXHEADER'],
          type: ValidationErrorType.invalidFormat,
        );
      }

      // Check for essential OFX tags
      final missingCheckpoints = <String>[];

      if (!content.contains('<OFX>')) {
        missingCheckpoints.add('<OFX>');
      }

      // Check for either bank or credit card transactions
      final hasBankTransactions = content.contains('<BANKMSGSRSV1>') ||
          content.contains('<BANKTRANLIST>');
      final hasCreditTransactions = content.contains('<CREDITCARDMSGSRSV1>');

      if (!hasBankTransactions && !hasCreditTransactions) {
        missingCheckpoints
            .add('Transaction data (BANKMSGSRSV1 or CREDITCARDMSGSRSV1)');
      }

      if (missingCheckpoints.isNotEmpty) {
        return ValidationResult.failure(
          error:
              'Missing required OFX elements: ${missingCheckpoints.join(", ")}',
          missing: missingCheckpoints,
          type: ValidationErrorType.missingRequiredFields,
        );
      }

      return const ValidationResult.success();
    } catch (e) {
      return ValidationResult.failure(
        error: 'Error reading OFX file: $e',
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

      // Split header and body
      final parts = _splitHeaderAndBody(content);
      final header = parts['header']!;
      final body = parts['body']!;

      // Convert SGML-like OFX to proper XML if needed
      final xmlContent = _convertToXml(body);

      // Parse XML
      final document = XmlDocument.parse(xmlContent);
      final ofxElement = document.findAllElements('OFX').first;

      // Extract transactions
      final transactions = <ParsedTransaction>[];

      // Try bank transactions
      transactions.addAll(_parseBankTransactions(ofxElement, documentMetadata));

      // Try credit card transactions
      transactions
          .addAll(_parseCreditCardTransactions(ofxElement, documentMetadata));

      if (transactions.isEmpty) {
        return ParseResult(
          success: false,
          errorMessage: 'No transactions found in OFX file',
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
        errorMessage: 'Error parsing OFX file: $e',
        transactions: const [],
        document: documentMetadata,
      );
    }
  }

  /// Splits OFX content into header and body
  Map<String, String> _splitHeaderAndBody(String content) {
    final lines = content.split('\n');
    int bodyStartIndex = 0;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('<OFX>')) {
        bodyStartIndex = i;
        break;
      }
    }

    final header = lines.sublist(0, bodyStartIndex).join('\n');
    final body = lines.sublist(bodyStartIndex).join('\n');

    return {'header': header, 'body': body};
  }

  /// Converts SGML-like OFX format to proper XML
  String _convertToXml(String sgmlContent) {
    // OFX v1 uses SGML-like format without closing tags
    // We need to add closing tags for XML parsing

    String result = sgmlContent;

    // Add XML declaration if not present
    if (!result.trim().startsWith('<?xml')) {
      result = '<?xml version="1.0" encoding="UTF-8"?>\n$result';
    }

    // Handle unclosed tags - add closing tags
    // This is a simplified approach; robust OFX parsers handle this more thoroughly
    final lines = result.split('\n');
    final processedLines = <String>[];
    final tagStack = <String>[];

    for (var line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) continue;

      // Opening tag
      if (trimmed.startsWith('<') &&
          !trimmed.startsWith('</') &&
          !trimmed.startsWith('<?') &&
          !trimmed.endsWith('/>')) {
        final tagMatch = RegExp(r'<([A-Z][A-Z0-9._]*)', caseSensitive: true)
            .firstMatch(trimmed);

        if (tagMatch != null) {
          final tagName = tagMatch.group(1)!;

          // Check if this line has content after the tag
          final contentAfterTag = trimmed.substring(tagMatch.end).trim();

          if (contentAfterTag.isEmpty) {
            // Opening tag only
            processedLines.add(line);
            tagStack.add(tagName);
          } else {
            // Tag with content on same line
            processedLines.add(line);
            // Check if next line is a closing tag or another opening tag
            // If it's not a child tag, we need to close this one
          }
        }
      }
      // Closing tag
      else if (trimmed.startsWith('</')) {
        final tagMatch = RegExp(r'</([A-Z][A-Z0-9._]*)>').firstMatch(trimmed);

        if (tagMatch != null) {
          final tagName = tagMatch.group(1)!;

          // Close any open tags until we find the matching one
          while (tagStack.isNotEmpty && tagStack.last != tagName) {
            final unclosedTag = tagStack.removeLast();
            processedLines.add('  ' * tagStack.length + '</$unclosedTag>');
          }

          if (tagStack.isNotEmpty && tagStack.last == tagName) {
            tagStack.removeLast();
          }

          processedLines.add(line);
        }
      }
      // Content line or self-closing
      else {
        processedLines.add(line);
      }
    }

    // Close any remaining open tags
    while (tagStack.isNotEmpty) {
      final unclosedTag = tagStack.removeLast();
      processedLines.add('  ' * tagStack.length + '</$unclosedTag>');
    }

    return processedLines.join('\n');
  }

  /// Parses bank account transactions
  List<ParsedTransaction> _parseBankTransactions(
    XmlElement ofxElement,
    UploadedDocument documentMetadata,
  ) {
    final transactions = <ParsedTransaction>[];

    try {
      final bankMsgs = ofxElement.findAllElements('BANKMSGSRSV1');
      if (bankMsgs.isEmpty) return transactions;

      for (var stmtTrnRs in bankMsgs.first.findAllElements('STMTTRNRS')) {
        final stmtRs = stmtTrnRs.findElements('STMTRS').first;
        final tranList = stmtRs.findElements('BANKTRANLIST').first;

        for (var stmtTrn in tranList.findAllElements('STMTTRN')) {
          final transaction = _parseTransaction(stmtTrn, documentMetadata);
          if (transaction != null) {
            transactions.add(transaction);
          }
        }
      }
    } catch (e) {
      // If parsing fails, return what we have
    }

    return transactions;
  }

  /// Parses credit card transactions
  List<ParsedTransaction> _parseCreditCardTransactions(
    XmlElement ofxElement,
    UploadedDocument documentMetadata,
  ) {
    final transactions = <ParsedTransaction>[];

    try {
      final ccMsgs = ofxElement.findAllElements('CREDITCARDMSGSRSV1');
      if (ccMsgs.isEmpty) return transactions;

      for (var stmtTrnRs in ccMsgs.first.findAllElements('CCSTMTTRNRS')) {
        final stmtRs = stmtTrnRs.findElements('CCSTMTRS').first;
        final tranList = stmtRs.findElements('BANKTRANLIST').first;

        for (var stmtTrn in tranList.findAllElements('STMTTRN')) {
          final transaction = _parseTransaction(stmtTrn, documentMetadata);
          if (transaction != null) {
            transactions.add(transaction);
          }
        }
      }
    } catch (e) {
      // If parsing fails, return what we have
    }

    return transactions;
  }

  /// Parses a single transaction element
  ParsedTransaction? _parseTransaction(
    XmlElement stmtTrn,
    UploadedDocument documentMetadata,
  ) {
    try {
      final trnType = _getElementText(stmtTrn, 'TRNTYPE');
      final dtPosted = _getElementText(stmtTrn, 'DTPOSTED');
      final trnAmt = _getElementText(stmtTrn, 'TRNAMT');
      final fitId = _getElementText(stmtTrn, 'FITID');
      final name = _getElementText(stmtTrn, 'NAME');
      final memo = _getElementText(stmtTrn, 'MEMO');
      bool ignoreTransaction = false;

      if (dtPosted == null || trnAmt == null) {
        return null;
      }

      final date = _parseOfxDate(dtPosted);
      double amount = double.tryParse(trnAmt) ?? 0.0;

      // Combine name and memo for description
      final description = [name, memo]
          .where((s) => s != null && s.isNotEmpty)
          .join(' - ')
          .trim();

      //! I am forcing only expenditure to be returned (incomes are ignored but recorded)
      if (_determineTransactionType(trnType, amount) ==
          TransactionType.income) {
        ignoreTransaction = true;
      } else if (_determineTransactionType(trnType, amount) ==
          TransactionType.expense) {
        ignoreTransaction = false;
        amount = amount * (-1);
      } else {
        return null;
      }
      return ParsedTransaction(
        id: const Uuid().v4(),
        date: date,
        originalDescription: description.isNotEmpty ? description : null,
        vendorName: name ?? 'Unknown',
        amount: amount,
        useMemory: true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets text content from an XML element
  String? _getElementText(XmlElement parent, String tagName) {
    final elements = parent.findElements(tagName);
    if (elements.isEmpty) return null;
    return elements.first.innerText.trim();
  }

  /// Parses OFX date format (YYYYMMDDHHMMSS.XXX[TZ])
  DateTime _parseOfxDate(String ofxDate) {
    // Remove timezone and fractional seconds
    final dateStr = ofxDate.split('[').first.split('.').first;

    try {
      // Parse YYYYMMDDHHMMSS format
      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));

      int hour = 0, minute = 0, second = 0;

      if (dateStr.length >= 10) {
        hour = int.parse(dateStr.substring(8, 10));
      }
      if (dateStr.length >= 12) {
        minute = int.parse(dateStr.substring(10, 12));
      }
      if (dateStr.length >= 14) {
        second = int.parse(dateStr.substring(12, 14));
      }

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }

  /// Determines transaction type from OFX type and amount
  TransactionType _determineTransactionType(String? trnType, double amount) {
    if (trnType == null) {
      return amount >= 0 ? TransactionType.income : TransactionType.expense;
    }

    switch (trnType.toUpperCase()) {
      case 'CREDIT':
      case 'DEP':
      case 'DEPOSIT':
        return TransactionType.income;
      case 'DEBIT':
      case 'CHECK':
      case 'ATM':
      case 'POS':
      case 'PAYMENT':
        return TransactionType.expense;
      case 'XFER':
        return TransactionType.transfer;
      default:
        return amount >= 0 ? TransactionType.income : TransactionType.expense;
    }
  }
}

/// Transaction type enumeration
enum TransactionType {
  income,
  expense,
  transfer,
}

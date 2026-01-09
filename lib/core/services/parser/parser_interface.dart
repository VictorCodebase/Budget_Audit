// lib/core/services/parser/parser_interface.dart

import 'dart:io';
import '../../models/client_models.dart';

/// Abstract base class for all bank statement parsers
///
/// Each parser implementation must:
/// 1. Validate the PDF structure to ensure it can be parsed
/// 2. Extract transactions from the PDF document
/// 3. Handle institution-specific formats and quirks
abstract class StatementParser {
  /// The financial institution this parser handles
  FinancialInstitution get institution;

  /// Validates whether this parser can successfully parse the given PDF
  ///
  /// This method should check for:
  /// - Required column headers (e.g., "Date", "Description", "Amount")
  /// - Expected table structure
  /// - Institution-specific markers (logos, account number formats)
  /// - Page layout compatibility
  ///
  /// Returns [ValidationResult] indicating:
  /// - canParse: true if all checkpoints are found
  /// - errorMessage: description of what's missing or incompatible
  /// - missingCheckpoints: list of specific elements that couldn't be found
  ///
  /// Example checkpoints for Equity Bank:
  /// - "Transaction Date" column header
  /// - "Value Date" column header
  /// - "Description" column header
  /// - "Withdrawal" column header
  /// - "Deposit" column header
  /// - "Balance" column header
  /// - Account number format: "XXXX-XXXX-XXXX"
  Future<ValidationResult> validateDocument(
    File pdfFile, {
    String? password,
  });

  /// Extracts transactions from the PDF document
  ///
  /// Prerequisites:
  /// - validateDocument() must return success before calling this
  /// - PDF must be unlocked (password provided if required)
  ///
  /// Returns [ParseResult] containing:
  /// - success: whether parsing completed without errors
  /// - transactions: list of extracted ParsedTransaction objects
  /// - errorMessage: details if parsing failed partway through
  ///
  /// Implementation requirements:
  /// 1. Read PDF content (text extraction)
  /// 2. Locate transaction table boundaries
  /// 3. Parse each row into fields (date, vendor, amount, etc.)
  /// 4. Handle multi-page statements
  /// 5. Clean and normalize data:
  ///    - Parse dates to DateTime
  ///    - Extract numeric amounts (handle currency symbols)
  ///    - Normalize vendor names (trim, remove extra spaces)
  /// 6. Filter out:
  ///    - Summary rows (totals, balances)
  ///    - Header/footer repetitions
  ///    - Non-transaction content
  ///
  /// Note: Do NOT access the database in this method.
  /// Return in-memory ParsedTransaction objects only.
  Future<ParseResult> parseDocument(
    File pdfFile,
    UploadedDocument documentMetadata, {
    String? password,
  });

}

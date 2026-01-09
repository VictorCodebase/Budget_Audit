// lib/core/services/document_service.dart

import 'dart:io';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';
import '../models/client_models.dart';
import 'parser/parser_factory.dart';
import 'parser/parser_interface.dart';

/// Service for handling document upload, validation, and parsing
class DocumentService {
  final Logger _logger = Logger('DocumentService');
  final Uuid _uuid = const Uuid();

  /// Creates an UploadedDocument from file metadata
  UploadedDocument createUploadedDocument({
    required String fileName,
    required String filePath,
    String? password,
    required int ownerParticipantId,
    required FinancialInstitution institution,
  }) {
    return UploadedDocument(
      id: _uuid.v4(),
      fileName: fileName,
      filePath: filePath,
      password: password,
      ownerParticipantId: ownerParticipantId,
      institution: institution,
      uploadedAt: DateTime.now(),
    );
  }

  /// Validates that a document can be parsed by the selected parser
  Future<ValidationResult> validateDocument(
    UploadedDocument document,
  ) async {
    try {
      _logger.info('Validating document: ${document.fileName}');

      final file = File(document.filePath);
      if (!await file.exists()) {
        return const ValidationResult.failure(
          error: 'File not found. Please upload the document again.',
          type: ValidationErrorType.fileNotFound,
        );
      }

      // Get appropriate parser
      final parser = ParserFactory.getParser(document.institution);

      // Validate with parser
      final result = await parser.validateDocument(
        file,
        password: document.password,
      );

      if (result.canParse) {
        _logger.info('Document validation successful: ${document.fileName}');
      } else {
        _logger.warning(
          'Document validation failed: ${document.fileName}. '
          'Reason: ${result.errorMessage}',
        );
      }

      return result;
    } catch (e, st) {
      _logger.severe('Error validating document', e, st);
      return ValidationResult.failure(
        error: 'An error occurred while validating the document: $e',
      );
    }
  }

  /// Parses a document and extracts transactions
  Future<ParseResult> parseDocument(
    UploadedDocument document,
  ) async {
    try {
      _logger.info('Parsing document: ${document.fileName}');

      final file = File(document.filePath);
      if (!await file.exists()) {
        return ParseResult(
          success: false,
          errorMessage: 'File not found. Please upload the document again.',
          transactions: const [],
          document: document,
        );
      }

      // Get appropriate parser
      final parser = ParserFactory.getParser(document.institution);

      // Parse document
      final result = await parser.parseDocument(
        file,
        document,
        password: document.password,
      );

      if (result.success) {
        // Filter out ignored transactions (income)
        final filteredTransactions =
            result.transactions.where((txn) => !txn.ignoreTransaction).toList();

        _logger.info(
          'Document parsed successfully: ${document.fileName}. '
          'Found ${result.transactions.length} total, '
          'kept ${filteredTransactions.length} non-ignored transactions.',
        );

        return ParseResult(
          success: true,
          transactions: filteredTransactions,
          document: document,
          errorMessage: null,
        );
      } else {
        _logger.warning(
          'Document parsing failed: ${document.fileName}. '
          'Reason: ${result.errorMessage}',
        );
      }

      return result;
    } catch (e, st) {
      _logger.severe('Error parsing document', e, st);
      return ParseResult(
        success: false,
        errorMessage: 'An error occurred while parsing the document: $e',
        transactions: const [],
        document: document,
      );
    }
  }

  /// Cleans up a document file from storage
  Future<void> cleanupDocument(UploadedDocument document) async {
    try {
      final file = File(document.filePath);
      if (await file.exists()) {
        await file.delete();
        _logger.info('Cleaned up document: ${document.fileName}');
      }
    } catch (e, st) {
      _logger.warning(
          'Failed to cleanup document: ${document.fileName}', e, st);
      // Non-critical error, don't throw
    }
  }

  /// Validates that a file is a valid PDF
  bool isValidPdf(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;

      // Check file extension
      if (!filePath.toLowerCase().endsWith('.pdf')) return false;

      // Read first few bytes to check PDF header
      final bytes = file.readAsBytesSync();
      if (bytes.length < 5) return false;

      // PDF files start with %PDF
      final header = String.fromCharCodes(bytes.take(4));
      return header == '%PDF';
    } catch (e) {
      _logger.warning('Error checking PDF validity: $e');
      return false;
    }
  }

  /// Gets a human-readable file size
  String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();

      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }
}

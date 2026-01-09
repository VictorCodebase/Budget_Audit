import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/services/document_service.dart';
import 'package:budget_audit/core/services/document_service.dart';

void main() {
  late DocumentService documentService;

  setUp(() {
    documentService = DocumentService();
  });

  group('DocumentService - parseDocument (Filtering)', () {
    test('should filter out transactions marked as ignoreTransaction',
        () async {
      // 1. Arrange
      // We'll use a real file if available, or mock if we had a mocking framework.
      // Since we want to test the filtering in DocumentService, we can use
      // the existing test files and check the filtered output.

      final mpesaFile = File(
          'test/resources/Statement_All_Transactions_20251101_20251125[1].pdf');

      if (!mpesaFile.existsSync()) {
        print('Skipping DocumentService test: M-PESA sample not found');
        return;
      }

      final document = UploadedDocument(
        id: 'test-mpesa',
        fileName: 'mpesa.pdf',
        filePath: mpesaFile.absolute.path,
        ownerParticipantId: 1,
        institution: FinancialInstitution.mpesa,
        uploadedAt: DateTime.now(),
      );

      // 2. Act
      final result = await documentService.parseDocument(document);

      // 3. Assert
      expect(result.success, isTrue);

      // M-PESA parser marks income as ignored.
      // The sample file has income transactions.
      // We verify that NONE of the returned transactions are marked as ignoreTransaction
      // because DocumentService should have filtered them out.
      for (final txn in result.transactions) {
        expect(txn.ignoreTransaction, isFalse,
            reason:
                'Transaction ${txn.vendorName} should not have been returned if ignored');
        expect(txn.amount, isNegative,
            reason:
                'Only expenses (negative amounts) should remain for M-PESA');
      }

      print(
          'DocumentService filtered ${result.transactions.length} transactions from M-PESA statement');
    });

    test('should filter out credit transactions from HSBC statements',
        () async {
      final hsbcFile = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!hsbcFile.existsSync()) {
        print('Skipping DocumentService test: HSBC sample not found');
        return;
      }

      final document = UploadedDocument(
        id: 'test-hsbc',
        fileName: 'hsbc.pdf',
        filePath: hsbcFile.absolute.path,
        ownerParticipantId: 1,
        institution: FinancialInstitution.hsbc,
        uploadedAt: DateTime.now(),
      );

      // 2. Act
      final result = await documentService.parseDocument(document);

      // 3. Assert
      expect(result.success, isTrue);

      // Our HSBC parser update marks CR as ignoreTransaction.
      // DocumentService should filter them.
      for (final txn in result.transactions) {
        expect(txn.ignoreTransaction, isFalse);
        expect(txn.amount, isNegative,
            reason: 'Only debit transactions should remains for HSBC');
      }

      print(
          'DocumentService filtered ${result.transactions.length} transactions from HSBC statement');
    });
  });
}

import 'dart:io';

import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/services/document_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters M-PESA income transactions from parsed expenses', () async {
    final file = File(
      'test/resources/Statement_All_Transactions_20251101_20251125[1].pdf',
    );
    expect(file.existsSync(), isTrue, reason: 'PDF fixture is required');

    final document = UploadedDocument(
      id: 'test-mpesa',
      fileName: 'statement.pdf',
      filePath: file.path,
      ownerParticipantId: 1,
      institution: FinancialInstitution.mpesa,
      uploadedAt: DateTime(2025, 11, 25),
    );

    final result = await DocumentService().parseDocument(document);

    expect(result.success, isTrue, reason: result.errorMessage);
    expect(result.transactions, isNotEmpty);
    expect(result.transactions.every((transaction) {
      return !transaction.ignoreTransaction && transaction.amount.isNegative;
    }), isTrue);
  });
}

import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/features/home/home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final document = UploadedDocument(
    id: 'document-1',
    fileName: 'statement.pdf',
    filePath: '/tmp/statement.pdf',
    ownerParticipantId: 1,
    institution: FinancialInstitution.mpesa,
    uploadedAt: DateTime(2025),
  );

  test('ignored transactions count as handled and not unassigned', () {
    final group = DocumentTransactionGroup(
      document: document,
      transactions: [
        ParsedTransaction(
          id: 'transaction-1',
          date: DateTime(2025),
          vendorName: 'Deposit',
          amount: 100,
          ignoreTransaction: true,
        ),
      ],
    );

    expect(group.hasAllAccountsAssigned, isTrue);
    expect(group.unassignedCount, 0);
  });

  test('transactions without an assigned account remain unassigned', () {
    final group = DocumentTransactionGroup(
      document: document,
      transactions: [
        ParsedTransaction(
          id: 'transaction-1',
          date: DateTime(2025),
          vendorName: 'Groceries',
          amount: -25,
        ),
      ],
    );

    expect(group.hasAllAccountsAssigned, isFalse);
    expect(group.unassignedCount, 1);
  });
}

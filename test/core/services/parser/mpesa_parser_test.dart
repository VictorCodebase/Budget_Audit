import 'dart:io';

import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/services/parser/mpesa_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MPesaParser parser;

  setUp(() {
    parser = MPesaParser();
  });

  group('MPesaParser helpers', () {
    test('normalizes M-PESA vendor patterns', () {
      expect(
        parser.normalizeVendorName(
          'Customer Payment to Small Business to 0716***929 - ALICE NJERI IRUNGU',
        ),
        'ALICE NJERI IRUNGU',
      );
      expect(
        parser.normalizeVendorName(
          'Business Payment from 300600 - Equity Bulk Account via API',
        ),
        'Equity Bulk Account via API',
      );
      expect(
        parser.normalizeVendorName(
          'Customer Bundle Purchase with Fuliza to 4093441 - SAFARICOM DATA BUNDLES',
        ),
        'Safaricom Data Bundles',
      );
      expect(
        parser.normalizeVendorName('OD Loan Repayment to 232323'),
        'M-PESA Overdraft',
      );
    });

    test('parses amounts with currency symbols and separators', () {
      expect(parser.parseAmount('1,100.00'), 1100.00);
      expect(parser.parseAmount('KSh 50.00'), 50.00);
      expect(parser.parseAmount('ksh 50.00'), 50.00);
      expect(parser.parseAmount('300'), 300.00);
      expect(parser.parseAmount('invalid'), isNull);
    });

    test('parses ISO date and time', () {
      final date = parser.parseDate('2025-11-24 19:53:55');

      expect(date, isNotNull);
      expect(date?.year, 2025);
      expect(date?.month, 11);
      expect(date?.day, 24);
      expect(date?.hour, 19);
    });
  });

  test('parses completed income and expense transactions from a statement',
      () async {
    final file = File(
      'test/resources/Statement_All_Transactions_20251101_20251125[1].pdf',
    );
    expect(file.existsSync(), isTrue, reason: 'PDF fixture is required');

    const institution = FinancialInstitution.mpesa;
    final metadata = UploadedDocument(
      id: '1',
      fileName: 'statement.pdf',
      filePath: file.path,
      ownerParticipantId: 1,
      institution: institution,
      uploadedAt: DateTime(2025, 11, 25),
    );

    final result = await parser.parseDocument(file, metadata);

    expect(result.success, isTrue, reason: result.errorMessage);
    expect(result.transactions, isNotEmpty);

    final expense = result.transactions.firstWhere(
      (transaction) => transaction.vendorName == 'M-PESA Charge',
    );
    expect(expense.amount, -7.0);
    expect(expense.date.year, 2025);

    final income = result.transactions.firstWhere(
      (transaction) =>
          transaction.amount > 0 &&
          transaction.originalDescription!
              .contains('Business Payment from 300600'),
    );
    expect(income.amount, 1100.0);
    expect(income.ignoreTransaction, isTrue);
  });
}

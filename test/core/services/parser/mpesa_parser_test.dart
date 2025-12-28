import 'dart:io';

import 'package:budget_audit/core/models/client_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_audit/core/services/parser/mpesa_parser.dart';

void main() {
  late MPesaParser parser;

  // setUp runs before EVERY single test.
  // It ensures we have a fresh instance of the parser.
  setUp(() {
    parser = MPesaParser();
  });

  group('MPesaParser - Logic Helpers', () {
    // TEST 1: Check if vendor names are cleaned correctly
    test('normalizeVendorName extracts clean names from M-PESA patterns', () {
      // 1. ARRANGE (The inputs)
      const input1 =
          "Customer Payment to Small Business to 0716***929 - ALICE NJERI IRUNGU";
      const input2 =
          "Business Payment from 300600 - Equity Bulk Account via API";
      const input3 =
          "Customer Bundle Purchase with Fuliza to 4093441 - SAFARICOM DATA BUNDLES";
      const input4 = "OD Loan Repayment to 232323 - M-PESA Overdraw";

      // 2. ACT (Run the function)
      final result1 = parser.normalizeVendorName(input1);
      final result2 = parser.normalizeVendorName(input2);
      final result3 = parser.normalizeVendorName(input3);
      final result4 = parser.normalizeVendorName(input4);

      // 3. ASSERT (Check if output matches expectation)
      expect(result1, equals("ALICE NJERI IRUNGU"));
      expect(result2, equals("Equity Bulk Account via API"));
      expect(result3, equals("Safaricom Data Bundles"));
      expect(result4, equals("M-PESA Overdraft"));
    });

    // TEST 2: Check amount parsing
    test('parseAmount handles commas and currency symbols', () {
      expect(parser.parseAmount("1,100.00"), equals(1100.00));
      expect(parser.parseAmount("KSh 50.00"), equals(50.00));
      expect(parser.parseAmount("300"), equals(300.00));
      expect(parser.parseAmount("invalid"), isNull);
    });

    // TEST 3: Check Date parsing
    test('parseDate handles ISO format correctly', () {
      final date = parser.parseDate("2025-11-24 19:53:55");

      expect(date, isNotNull);
      expect(date?.year, 2025);
      expect(date?.month, 11);
      expect(date?.day, 24);
      expect(date?.hour, 19);
    });
  });

  group('MPesaParser - Full Document Parsing', () {
    test('parseDocument extracts income and expense correctly', () async {
      // 1. ARRANGE
      // Point to the sample file you placed in test/resources
      final file = File(
          'test/resources/Statement_All_Transactions_20251101_20251125[1].pdf');

      // Ensure the file exists before running the test
      if (!file.existsSync()) {
        print(
            'Skipping PDF test: sample_mpesa.pdf not found in test/resources');
        return;
      }

      const FinancialInstitution institution = FinancialInstitution.mpesa;

      final metadata = UploadedDocument(
        id: '1',
        fileName: 'test.pdf',
        filePath: "./sample/path",
        ownerParticipantId: 1,
        institution: institution,
        uploadedAt: DateTime.now(),
      );

      // 2. ACT
      final result = await parser.parseDocument(file, metadata);

      // 3. ASSERT
      expect(result.success, isTrue);
      expect(result.transactions, isNotEmpty);

      // Let's find a specific transaction from your image/data
      // "Customer Transfer of Funds Charge" -> 7.00 Withdrawn
      final expenseTx = result.transactions.firstWhere(
        (t) => t.amount < 0 && t.vendorName.contains('M-PESA Charge'),
        orElse: () => throw Exception("Expense transaction not found"),
      );

      expect(expenseTx.amount, equals(-7.00)); // Should be negative
      expect(expenseTx.date.year, 2025);

      // "Business Payment from Equity" -> 1,100.00 Paid In
      final incomeTx = result.transactions.firstWhere(
        (t) => t.amount > 0 && t.vendorName.contains('Equity'),
        orElse: () => throw Exception("Income transaction not found"),
      );

      expect(incomeTx.amount, equals(1100.00)); // Should be positive
    });
  });

  group('MPesaParser - Full Document Parsing', () {
    test('parseDocument extracts income and expense correctly', () async {
      // 1. ARRANGE
      // Update this path and filename to match your exact setup!
      final file = File(
          'test/resources/Statement_All_Transactions_20251101_20251125[1].pdf');

      if (!file.existsSync()) {
        // This message ensures the test runner knows why we skipped
        fail('Skipping PDF test: Test file not found at ${file.path}');
      }

      const FinancialInstitution institution = FinancialInstitution.mpesa;

      final metadata = UploadedDocument(
        id: '1',
        fileName: 'test.pdf',
        filePath: "./sample/path",
        ownerParticipantId: 1,
        institution: institution,
        uploadedAt: DateTime.now(),
      );
      // 2. ACT
      final result = await parser.parseDocument(file, metadata);

      // 3. ASSERTIONS

      // A. Check for overall success and quantity
      expect(result.success, isTrue,
          reason: 'Parser should report successful extraction');
      expect(result.transactions, isNotEmpty,
          reason: 'Should find at least one transaction');
      expect(result.transactions.length, greaterThanOrEqualTo(2),
          reason: 'Should find multiple transactions in the sample');

      // B. Verify the specific EXPENSE transaction (M-PESA Charge)
      final expenseTx = result.transactions.firstWhere(
        (t) => t.vendorName == 'M-PESA Charge',
        orElse: () => throw Exception("M-PESA Charge transaction not found"),
      );

      // Assert that the amount is correctly negated (expense)
      expect(expenseTx.amount, equals(-7.0),
          reason: 'Expense amount must be negative and correct.');
      expect(expenseTx.date.year, equals(2025));

      // C. Verify a specific INCOME transaction (from your raw data snippet,
      // let's assume one is 1,100.00 from Equity as seen in the screenshot)
      final incomeTx = result.transactions.firstWhere(
        (t) =>
            t.amount > 0 &&
            t.originalDescription!.contains('Business Payment from 300600'),
        orElse: () => throw Exception("Income transaction (Equity) not found"),
      );

      // Assert that the amount is correctly positive (income)
      expect(incomeTx.amount, equals(1100.00),
          reason: 'Income amount must be positive and correct.');
    });
  });
}

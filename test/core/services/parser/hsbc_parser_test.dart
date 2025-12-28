// test/core/services/parser/hsbc_parser_test.dart

import 'dart:io';
import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/services/parser/hsbc_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HSBCParser parser;

  setUp(() {
    parser = HSBCParser();
  });

  group('HSBCParser - Institution', () {
    test('should return correct institution', () {
      expect(parser.institution, equals(FinancialInstitution.hsbc));
    });
  });

  group('HSBCParser - Validation', () {
    test('should validate authentic HSBC statement successfully', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final result = await parser.validateDocument(file);

      expect(result.canParse, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.missingCheckpoints, isEmpty);
    });

    test('should fail validation for non-HSBC document', () async {
      // This would be a different bank's statement
      final file = File('test/resources/non-hsbc-statement.pdf');

      if (await file.exists()) {
        final result = await parser.validateDocument(file);

        expect(result.canParse, isFalse);
        expect(result.errorMessage, isNotNull);
        expect(result.missingCheckpoints, contains('HSBC branding'));
      }
    });

    test('should fail validation for missing required headers', () async {
      // Create a PDF that has HSBC branding but missing transaction table
      final file = File('test/resources/hsbc-incomplete.pdf');

      if (await file.exists()) {
        final result = await parser.validateDocument(file);

        expect(result.canParse, isFalse);
        expect(result.missingCheckpoints, isNotEmpty);
      }
    });

    test('should handle password-protected PDFs', () async {
      final file = File('test/resources/hsbc-protected.pdf');

      if (await file.exists()) {
        // Try without password - should fail
        final resultNoPassword = await parser.validateDocument(file);
        expect(resultNoPassword.canParse, isFalse);

        // Try with wrong password - should fail
        final resultWrongPassword = await parser.validateDocument(
          file,
          password: 'wrongpassword',
        );
        expect(resultWrongPassword.canParse, isFalse);

        // Try with correct password - should succeed
        final resultCorrectPassword = await parser.validateDocument(
          file,
          password: 'correctpassword',
        );
        expect(resultCorrectPassword.canParse, isTrue);
      }
    });
  });

  group('HSBCParser - Transaction Parsing', () {
    test('should extract all transactions from August 2024 statement',
        () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.transactions, isNotEmpty);

      // Based on the provided document, we expect these transactions:
      // 1. PLAYDALE (DR) - 11,852.74
      // 2. PLAYDALE PAYMENT CHARGE (DR) - 17.00
      // 3. HMRC PAYE/NIC (DR) - 76.40
      // 4. Peak Landscape (DR) - 690.00
      // 5. Therasa Garrod (DR) - 306.48
      // 6. CALVER GALA ASSOCI (CR) - 1,250.00
      // 7. CONE M & T (CR) - 20.00

      expect(result.transactions.length, greaterThanOrEqualTo(7));
    });

    test('should correctly parse debit transactions as negative', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      // Find a DR transaction
      final debitTransaction = result.transactions.firstWhere(
        (t) => t.originalDescription!.contains('PLAYDALE'),
        orElse: () => throw Exception('No PLAYDALE transaction found'),
      );

      expect(debitTransaction.amount, isNegative);
      expect(debitTransaction.amount, closeTo(-11852.74, 0.01));
    });

    test('should correctly parse credit transactions as positive', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      // Find a CR transaction
      final creditTransaction = result.transactions.firstWhere(
        (t) => t.originalDescription!.contains('CALVER GALA'),
        orElse: () => throw Exception('No CALVER GALA transaction found'),
      );

      expect(creditTransaction.amount, isPositive);
      expect(creditTransaction.amount, closeTo(1250.00, 0.01));
    });

    test('should separate payment charges as individual transactions',
        () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      // Should have separate PLAYDALE transaction and PAYMENT CHARGE
      final playdaleTrans = result.transactions.where(
        (t) => t.originalDescription!.contains('PLAYDALE'),
      );

      final chargeTrans = result.transactions.where(
        (t) => t.vendorName!.toLowerCase().contains('payment charge'),
      );

      expect(playdaleTrans, isNotEmpty);
      expect(chargeTrans, isNotEmpty);
    });

    test('should parse dates to epoch milliseconds', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      for (final transaction in result.transactions) {
        expect(transaction.date, isNotNull);
        expect(transaction.date, isA<DateTime>());

        // Check that date is reasonable (year 2024)
        expect(transaction.date.year, equals(2024));
        expect(transaction.date.month, equals(8)); // August
      }
    });

    test('should normalize vendor names correctly', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
       id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      // Check that vendor names don't contain reference codes
      for (final transaction in result.transactions) {
        expect(
            transaction.vendorName, isNot(contains(RegExp(r'[A-Z0-9]{10,}'))));
        expect(transaction.vendorName, isNot(startsWith('DR ')));
        expect(transaction.vendorName, isNot(startsWith('CR ')));
      }
    });

    test('should handle multi-page statements', () async {
      final file = File('test/resources/hsbc-multipage.pdf');

      if (await file.exists()) {
        final metadata = UploadedDocument(
          id: 'test-doc-2',
          filePath: file.path,
          fileName: 'hsbc-statement-aug-2024.pdf',
          ownerParticipantId: 1,
          uploadedAt: DateTime.now(),
          institution: FinancialInstitution.hsbc,
        );

        final result = await parser.parseDocument(file, metadata);

        expect(result.success, isTrue);
        expect(result.transactions, isNotEmpty);
      }
    });

    test('should assign unique IDs to each transaction', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      final ids = result.transactions.map((t) => t.id).toSet();

      // All IDs should be unique
      expect(ids.length, equals(result.transactions.length));
    });

    test('should set useMemory to false for all transactions', () async {
      final file = File('test/resources/hsbc-statement-aug-2024.pdf');

      if (!await file.exists()) {
        fail('Test file not found at: ${file.path}');
      }

      final metadata = UploadedDocument(
        id: 'test-doc-1',
        filePath: file.path,
        fileName: 'hsbc-statement-aug-2024.pdf',
        ownerParticipantId: 1,
        uploadedAt: DateTime.now(),
        institution: FinancialInstitution.hsbc,
      );

      final result = await parser.parseDocument(file, metadata);

      for (final transaction in result.transactions) {
        expect(transaction.useMemory, isFalse);
      }
    });
  });

  group('HSBCParser - Date Parsing', () {
    test('should parse date format "02 Aug 24"', () {
      final date = parser.parseDate('02 Aug 24');

      expect(date, isNotNull);
      expect(date!.day, equals(2));
      expect(date.month, equals(8));
      expect(date.year, equals(2024));
    });

    test('should parse date format "2 Aug 24" (single digit)', () {
      final date = parser.parseDate('2 Aug 24');

      expect(date, isNotNull);
      expect(date!.day, equals(2));
      expect(date.month, equals(8));
      expect(date.year, equals(2024));
    });

    test('should parse date format "31 Jul 24"', () {
      final date = parser.parseDate('31 Jul 24');

      expect(date, isNotNull);
      expect(date!.day, equals(31));
      expect(date.month, equals(7));
      expect(date.year, equals(2024));
    });

    test('should return null for invalid date', () {
      final date = parser.parseDate('invalid date');
      expect(date, isNull);
    });
  });

  group('HSBCParser - Amount Parsing', () {
    test('should parse amount with commas', () {
      final amount = parser.parseAmount('11,852.74');

      expect(amount, isNotNull);
      expect(amount, closeTo(11852.74, 0.01));
    });

    test('should parse amount without commas', () {
      final amount = parser.parseAmount('306.48');

      expect(amount, isNotNull);
      expect(amount, closeTo(306.48, 0.01));
    });

    test('should parse amount with currency symbols', () {
      final amount1 = parser.parseAmount('£1,250.00');
      final amount2 = parser.parseAmount('KES 20.00');

      expect(amount1, isNotNull);
      expect(amount1, closeTo(1250.00, 0.01));
      expect(amount2, isNotNull);
      expect(amount2, closeTo(20.00, 0.01));
    });

    test('should return null for invalid amount', () {
      final amount = parser.parseAmount('not a number');
      expect(amount, isNull);
    });
  });

  group('HSBCParser - Vendor Name Normalization', () {
    test('should remove reference codes', () {
      final normalized =
          parser.normalizeVendorName('PLAYDALE RBD02084IVJPTAV4');

      expect(normalized, equals('PLAYDALE'));
      expect(normalized, isNot(contains('RBD02084IVJPTAV4')));
    });

    test('should remove DR/CR prefixes', () {
      final normalized1 = parser.normalizeVendorName('DR PLAYDALE');
      final normalized2 = parser.normalizeVendorName('CR CALVER GALA ASSOCI');

      expect(normalized1, isNot(startsWith('DR')));
      expect(normalized2, isNot(startsWith('CR')));
    });

    test('should trim extra whitespace', () {
      final normalized = parser.normalizeVendorName('  Peak  Landscape  ');

      expect(normalized, equals('Peak Landscape'));
    });

    test('should handle vendor names with BP prefix', () {
      final normalized = parser.normalizeVendorName('BP Calver PC 1');

      expect(normalized, equals('Calver PC 1'));
    });
  });

  group('HSBCParser - Institution Markers', () {
    test('should detect HSBC in text', () {
      final text = 'HSBC UK Bank plc Statement';
      expect(parser.containsInstitutionMarkers(text), isTrue);
    });

    test('should detect hsbc in lowercase', () {
      final text = 'Visit www.hsbc.co.uk for more info';
      expect(parser.containsInstitutionMarkers(text), isTrue);
    });

    test('should return false for non-HSBC text', () {
      final text = 'Equity Bank Statement';
      expect(parser.containsInstitutionMarkers(text), isFalse);
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:budget_audit/core/models/client_models.dart';
import 'package:budget_audit/core/services/parser/csv_parser.dart';
import 'package:budget_audit/core/services/parser/equity_parser.dart';
import 'package:budget_audit/core/services/parser/mpesa_parser.dart';
import 'package:budget_audit/core/services/parser/ofx_parser.dart';
import 'package:budget_audit/core/services/parser/parser_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'existing parsers match the fixture goldens',
    () async {
      final List<
        ({
          String fixture,
          String golden,
          StatementParser parser,
          FinancialInstitution institution,
        })
      >
      cases = [
        (
          fixture: 'test/fixtures/Equity_Statement_sample_redacted.pdf',
          golden: 'test/golden/Equity_Statement_sample_redacted.json',
          parser: EquityParser(),
          institution: FinancialInstitution.equity,
        ),
        (
          fixture: 'test/fixtures/MPESA_Statement_sample_redacted.pdf',
          golden: 'test/golden/MPESA_Statement_sample_redacted.json',
          parser: MPesaParser(),
          institution: FinancialInstitution.mpesa,
        ),
        (
          fixture:
              'test/fixtures/Equity_Statement_2026-03-02_to_2026-04-01.csv',
          golden:
              'test/golden/Equity_Statement_2026-03-02_to_2026-04-01.csv.json',
          parser: CSVParser(),
          institution: FinancialInstitution.csv,
        ),
        (
          fixture: 'test/fixtures/MPESA_Statement_2026-07-01_to_2026-07-18.csv',
          golden:
              'test/golden/MPESA_Statement_2026-07-01_to_2026-07-18.csv.json',
          parser: CSVParser(),
          institution: FinancialInstitution.csv,
        ),
        (
          fixture:
              'test/fixtures/Equity_Statement_2026-03-02_to_2026-04-01.ofx',
          golden:
              'test/golden/Equity_Statement_2026-03-02_to_2026-04-01.ofx.json',
          parser: OFXParser(),
          institution: FinancialInstitution.ofx,
        ),
        (
          fixture: 'test/fixtures/MPESA_Statement_2026-07-01_to_2026-07-18.ofx',
          golden:
              'test/golden/MPESA_Statement_2026-07-01_to_2026-07-18.ofx.json',
          parser: OFXParser(),
          institution: FinancialInstitution.ofx,
        ),
      ];

      for (final item in cases) {
        final fixture = File(item.fixture);
        expect(fixture.existsSync(), isTrue, reason: item.fixture);
        final metadata = UploadedDocument(
          id: item.fixture,
          fileName: fixture.uri.pathSegments.last,
          filePath: fixture.path,
          ownerParticipantId: 1,
          institution: item.institution,
          uploadedAt: DateTime.utc(2026),
        );
        final result = await item.parser.parseDocument(fixture, metadata);
        final actual = {
          'success': result.success,
          'errorMessage': result.errorMessage,
          'transactions': [
            for (final transaction in result.transactions)
              {
                'date': transaction.date.toIso8601String(),
                'vendorName': transaction.vendorName,
                'amount': transaction.amount,
                'ignoreTransaction': transaction.ignoreTransaction,
                'originalDescription': transaction.originalDescription,
                'useMemory': transaction.useMemory,
              },
          ],
        };
        final expected = jsonDecode(await File(item.golden).readAsString());

        expect(actual, expected, reason: item.fixture);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generic OFX rule preserves FITID and matches legacy dates and amounts',
    () {
      final rule = const RuleLoader().loadString(
        File('assets/rules/ofx_generic.json').readAsStringSync(),
      );
      final cases = [
        (
          fixture:
              'test/fixtures/Equity_Statement_2026-03-02_to_2026-04-01.ofx',
          golden:
              'test/golden/Equity_Statement_2026-03-02_to_2026-04-01.ofx.json',
        ),
        (
          fixture: 'test/fixtures/MPESA_Statement_2026-07-01_to_2026-07-18.ofx',
          golden:
              'test/golden/MPESA_Statement_2026-07-01_to_2026-07-18.ofx.json',
        ),
      ];

      for (final item in cases) {
        final document = const OfxExtractor().extractFile(File(item.fixture));
        final result = const RuleEngine().interpretOfx(rule, document);
        final golden =
            jsonDecode(File(item.golden).readAsStringSync())
                as Map<String, dynamic>;
        final expectedTransactions = golden['transactions'] as List;

        expect(result.errors, isEmpty, reason: item.fixture);
        expect(result.rows, hasLength(expectedTransactions.length));
        expect(golden['success'], isTrue);
        expect(document.fields[rule.fields['ending'] as String], isNotEmpty);
        expect(
          result.rows.map((row) => row.ref).toList(),
          document.transactions
              .map((transaction) => transaction['FITID'])
              .toList(),
        );
        expect(result.rows.every((row) => row.ref?.isNotEmpty == true), isTrue);

        final actualParity = result.rows
            .map(
              (row) => {
                'date': row.date.toIso8601String().substring(0, 19),
                'amountMinor': row.amountMinor,
              },
            )
            .toList();
        final expectedParity = expectedTransactions
            .map(
              (transaction) => {
                'date': (transaction['date'] as String).substring(0, 19),
                'amountMinor': ((transaction['amount'] as num).abs() * 100)
                    .round(),
              },
            )
            .toList();
        expect(actualParity, expectedParity, reason: item.fixture);

        final signedSourceAmounts = document.transactions
            .map((transaction) => parseMinorUnits(transaction['TRNAMT']!)!)
            .toList();
        final signedParsedAmounts = result.rows
            .map(
              (row) => row.direction == TransactionDirection.debit
                  ? -row.amountMinor
                  : row.amountMinor,
            )
            .toList();
        expect(signedParsedAmounts, signedSourceAmounts);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

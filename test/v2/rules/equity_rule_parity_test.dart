import 'dart:convert';
import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:budget_audit/v2/adapters/pdf_positioned_words.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Equity PDF rule matches legacy transaction dates and amounts',
    () {
      final rule = const RuleLoader().loadString(
        File('assets/rules/equity.json').readAsStringSync(),
      );
      final fixture = File(
        'test/fixtures/Equity_Statement_sample_redacted.pdf',
      );
      final words = PdfPositionedWordAdapter().extract(fixture);
      final result = const RuleEngine().interpretPositionedWords(rule, words);

      expect(result.errors, isEmpty);
      expect(result.rows, isNotEmpty);
      expect(
        result.rows.last.vendorRaw.toLowerCase(),
        isNot(contains('promptly advised')),
      );

      final engine = const RuleEngine();
      final normalizedVendors = result.rows
          .map((row) => engine.normalizeVendor(rule, row.vendorRaw))
          .toSet();
      expect(
        normalizedVendors,
        containsAll(['M-PESA', 'Bank Charges', 'Card Purchase']),
      );

      final actual = result.rows
          .map(
            (row) => {
              'date': row.date.toIso8601String().substring(0, 10),
              'signedAmountMinor': row.direction == TransactionDirection.debit
                  ? -row.amountMinor
                  : row.amountMinor,
            },
          )
          .toList();
      final golden =
          jsonDecode(
                File(
                  'test/golden/Equity_Statement_sample_redacted.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(golden['success'], isTrue);
      final expected = (golden['transactions'] as List)
          .map(
            (transaction) => {
              'date': (transaction['date'] as String).substring(0, 10),
              'signedAmountMinor': ((transaction['amount'] as num) * 100)
                  .round(),
            },
          )
          .toList();

      expect(actual, expected);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

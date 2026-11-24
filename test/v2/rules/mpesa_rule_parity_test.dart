 import 'dart:convert';
import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:budget_audit/v2/adapters/pdf_positioned_words.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'M-PESA PDF rule captures Paid In and Withdrawn',
    () {
      final rule = const RuleLoader().loadString(
        File('assets/rules/mpesa.json').readAsStringSync(),
      );
      final fixture = File('test/fixtures/MPESA_Statement_sample_redacted.pdf');
      final words = PdfPositionedWordAdapter().extract(fixture);
      final result = const RuleEngine().interpretPositionedWords(rule, words);

      expect(result.errors, isEmpty);
      expect(result.rows, isNotEmpty);
      final paidIn = result.rows
          .where((row) => row.direction == TransactionDirection.credit)
          .toList();
      final withdrawn = result.rows
          .where((row) => row.direction == TransactionDirection.debit)
          .toList();
      expect(paidIn, isNotEmpty);
      expect(withdrawn, isNotEmpty);
      expect(result.rows.first.amountMinor, 13700);
      expect(result.rows.first.direction, TransactionDirection.credit);

      final legacyGolden =
          jsonDecode(
                File(
                  'test/golden/MPESA_Statement_sample_redacted.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(legacyGolden['transactions'], isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

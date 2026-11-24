import 'dart:convert';
import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'generic CSV rule parses and fully reconciles the Equity CSV fixture',
    () {
      final rule = const RuleLoader().loadString(
        File('assets/rules/csv_generic.json').readAsStringSync(),
      );
      final fixture = File(
        'test/fixtures/Equity_Statement_2026-03-02_to_2026-04-01.csv',
      );
      final document = const CsvExtractor().extractFile(fixture);
      final result = const RuleEngine().interpretCsv(rule, document);

      expect(result.errors, isEmpty);
      expect(result.rows, hasLength(7));

      final openingRecord = document.rows.firstWhere(
        (row) => row['Particulars'] == 'Balance Brought Forward',
      );
      final opening = parseCrDrBalance(openingRecord['Balance']!);
      final ending = parseCrDrBalance(document.rows.last['Balance']!);
      expect(opening, isNotNull);
      expect(ending, isNotNull);

      final reconciliation = const RuleEngine().reconcile(
        result,
        openingBalanceMinor: opening,
        endingBalanceMinor: ending,
      );
      expect(reconciliation.passed, isTrue);

      final golden =
          jsonDecode(
                File(
                  'test/golden/Equity_Statement_2026-03-02_to_2026-04-01.csv.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(golden['success'], isFalse);
      expect(golden['transactions'], isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  test('Equity rule loads with debit and credit columns', () {
    final ruleFile = File('../../assets/rules/equity.json');
    expect(ruleFile.existsSync(), isTrue);

    final rule = const RuleLoader().loadString(ruleFile.readAsStringSync());
    expect(rule.institution, 'Equity Bank');
    expect(rule.fields['money_out'], 'Money Out');
    expect(rule.fields['money_in'], 'Money In');
  });

  test('Equity redacted CSV golden has opening balance and rows', () {
    final golden = File(
      '../../test/golden/Equity_Statement_2026-03-02_to_2026-04-01.csv',
    );
    expect(golden.existsSync(), isTrue);

    final lines = golden.readAsLinesSync();
    expect(lines.first, contains('Money Out'));
    expect(
      lines.any((line) => line.contains('Balance Brought Forward')),
      isTrue,
    );
  });
}

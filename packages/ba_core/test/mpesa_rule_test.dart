import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  test('M-PESA rule loads and captures Paid In', () {
    final ruleFile = File('../../assets/rules/mpesa.json');
    expect(ruleFile.existsSync(), isTrue);

    final rule = const RuleLoader().loadString(ruleFile.readAsStringSync());
    expect(rule.institution, 'M-PESA');
    expect(rule.fields['paid_in'], 'Paid In');
    expect(rule.direction, 'drcr_column');
  });

  test('M-PESA redacted CSV golden has expected paid-in rows', () {
    final golden = File(
      '../../test/golden/MPESA_Statement_2026-07-01_to_2026-07-18.csv',
    );
    expect(golden.existsSync(), isTrue);

    final lines = golden.readAsLinesSync();
    expect(lines, isNotEmpty);
    expect(lines.first, contains('Paid In'));
    expect(
      lines.where((line) => line.contains(',Completed,')).length,
      greaterThan(1),
    );
  });
}

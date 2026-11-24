import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  test('extracts quoted CSV fields and headers', () {
    const source =
        'Date,Details,Amount\n2026-07-18,"Shop, Branch","1,234.56"\n';
    final document = const CsvExtractor().extract(source);
    expect(document.headers, ['Date', 'Details', 'Amount']);
    expect(document.rows, hasLength(1));
    expect(document.rows.first['Details'], 'Shop, Branch');
    expect(document.rows.first['Amount'], '1,234.56');
  });

  test('matches M-PESA redacted CSV fixture row shape', () {
    final file = File(
      '../../test/fixtures/MPESA_Statement_2026-07-01_to_2026-07-18.csv',
    );
    final document = const CsvExtractor().extractFile(file);
    expect(document.headers, contains('Paid In'));
    expect(document.headers, contains('Withdrawn'));
    expect(document.rows, isNotEmpty);
  });

  test('generic CSV rule loads', () {
    final ruleFile = File('../../assets/rules/csv_generic.json');
    final rule = const RuleLoader().loadString(ruleFile.readAsStringSync());
    expect(rule.extractor, 'csv');
  });
}

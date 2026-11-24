import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

Map<String, dynamic> sampleRule() => {
  'institution': 'Test Bank',
  'rule_version': 1,
  'engine_min': 1,
  'extractor': 'csv',
  'detect': {
    'headers': ['Date', 'Amount'],
  },
  'layout': {'header_row': 0},
  'direction': 'signed',
  'fields': {'date': 'Date', 'vendor': 'Details', 'amount': 'Amount'},
  'keep_rows': [],
  'skip_rows_containing': ['Balance Brought Forward'],
  'vendor': [],
};

void main() {
  test('loads and round trips a valid rule', () {
    final rule = const RuleLoader().loadJson(sampleRule());
    expect(rule.institution, 'Test Bank');
    expect(rule.toJson(), sampleRule());
  });

  test('rejects invalid rules with clear fields', () {
    final invalid = sampleRule()..remove('institution');
    expect(
      () => const RuleLoader().loadJson(invalid),
      throwsA(
        isA<RuleValidationException>().having(
          (error) => error.message,
          'message',
          contains('institution'),
        ),
      ),
    );
  });

  test('rejects invalid direction', () {
    final invalid = sampleRule()..['direction'] = 'loop';
    expect(
      () => const RuleLoader().loadJson(invalid),
      throwsA(isA<RuleValidationException>()),
    );
  });

  test('rejects malformed JSON', () {
    expect(() => loadRuleJson('{'), throwsA(isA<RuleValidationException>()));
  });
}

import 'dart:convert';

class RuleValidationException implements Exception {
  final String message;
  const RuleValidationException(this.message);
  @override
  String toString() => 'RuleValidationException: $message';
}

class BankRule {
  final String institution;
  final int ruleVersion;
  final int engineMin;
  final String extractor;
  final Map<String, dynamic> detect;
  final Map<String, dynamic> layout;
  final String direction;
  final Map<String, dynamic> fields;
  final List<dynamic> keepRows;
  final List<String> skipRowsContaining;
  final List<Map<String, dynamic>> vendor;

  const BankRule({
    required this.institution,
    required this.ruleVersion,
    required this.engineMin,
    required this.extractor,
    required this.detect,
    required this.layout,
    required this.direction,
    required this.fields,
    required this.keepRows,
    required this.skipRowsContaining,
    required this.vendor,
  });

  factory BankRule.fromJson(Map<String, dynamic> json) {
    final errors = validateRuleMap(json);
    if (errors.isNotEmpty) {
      throw RuleValidationException(errors.join('; '));
    }
    return BankRule(
      institution: json['institution'] as String,
      ruleVersion: json['rule_version'] as int,
      engineMin: json['engine_min'] as int,
      extractor: json['extractor'] as String,
      detect: Map<String, dynamic>.from(json['detect'] as Map),
      layout: Map<String, dynamic>.from(json['layout'] as Map),
      direction: json['direction'] as String,
      fields: Map<String, dynamic>.from(json['fields'] as Map),
      keepRows: List<dynamic>.from(json['keep_rows'] as List),
      skipRowsContaining: (json['skip_rows_containing'] as List).cast<String>(),
      vendor: (json['vendor'] as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'institution': institution,
    'rule_version': ruleVersion,
    'engine_min': engineMin,
    'extractor': extractor,
    'detect': detect,
    'layout': layout,
    'direction': direction,
    'fields': fields,
    'keep_rows': keepRows,
    'skip_rows_containing': skipRowsContaining,
    'vendor': vendor,
  };
}

List<String> validateRuleMap(Map<String, dynamic> json) {
  final errors = <String>[];
  void requiredType(String key, Type type) {
    if (!json.containsKey(key)) {
      errors.add('missing required field: $key');
    } else if (json[key].runtimeType != type) {
      errors.add('$key must be ${type.toString()}');
    }
  }

  requiredType('institution', String);
  requiredType('rule_version', int);
  requiredType('engine_min', int);
  requiredType('extractor', String);
  for (final key in ['detect', 'layout', 'fields']) {
    if (!json.containsKey(key)) {
      errors.add('missing required field: $key');
    } else if (json[key] is! Map) {
      errors.add('$key must be an object');
    }
  }
  requiredType('direction', String);
  if (json.containsKey('direction') &&
      !const {
        'columns',
        'signed',
        'drcr_column',
        'balance_delta',
      }.contains(json['direction'])) {
    errors.add('invalid direction: ${json['direction']}');
  }
  for (final key in ['keep_rows', 'skip_rows_containing', 'vendor']) {
    if (!json.containsKey(key)) {
      errors.add('missing required field: $key');
    } else if (json[key] is! List) {
      errors.add('$key must be an array');
    }
  }
  return errors;
}

class RuleLoader {
  const RuleLoader();

  BankRule loadString(String source) {
    dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } catch (_) {
      throw const RuleValidationException('invalid JSON');
    }
    if (decoded is! Map) {
      throw const RuleValidationException('rule root must be a JSON object');
    }
    return BankRule.fromJson(Map<String, dynamic>.from(decoded));
  }

  BankRule loadJson(Map<String, dynamic> json) => BankRule.fromJson(json);
}

BankRule loadRuleJson(String source) => const RuleLoader().loadString(source);

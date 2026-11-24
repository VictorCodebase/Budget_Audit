import '../date/date_parser.dart';
import '../extract/csv/csv_extractor.dart';
import '../extract/ofx/ofx_extractor.dart';
import '../models/parsed_row.dart';
import '../money/minor_units.dart';
import '../reconcile/reconciler.dart';
import '../rules/rule.dart';
import 'header_table.dart';

class RuleExecutionResult {
  final List<ParsedRow> rows;
  final List<String> errors;

  const RuleExecutionResult({required this.rows, required this.errors});

  bool get succeeded => errors.isEmpty;
}

class RuleEngine {
  const RuleEngine();

  RuleExecutionResult interpretPositionedWords(
    BankRule rule,
    List<PositionedWord> words,
  ) {
    final headers = rule.layout['header_labels'];
    final rowStartPattern = rule.layout['row_start'];
    final rowStartColumn =
        rule.layout['row_start_column'] ?? rule.fields['date'];
    final continuationColumn =
        rule.fields['vendor_raw'] ?? rule.fields['vendor'];
    if (headers is! List ||
        headers.any((value) => value is! String) ||
        rowStartPattern is! String ||
        rowStartColumn is! String) {
      return const RuleExecutionResult(
        rows: [],
        errors: ['PDF rule layout needs header_labels, row_start and date'],
      );
    }

    final records = const HeaderTableInterpreter().interpret(
      words,
      headers: headers.cast<String>(),
      rowStartPattern: rowStartPattern,
      rowStartColumn: rowStartColumn,
      continuationColumn: continuationColumn is String
          ? continuationColumn
          : null,
      skipLinesContaining: rule.skipRowsContaining,
    );
    return interpretRecords(rule, _inheritFields(rule, records));
  }

  RuleExecutionResult interpretCsv(BankRule rule, CsvDocument document) =>
      interpretRecords(rule, document.rows);

  RuleExecutionResult interpretOfx(BankRule rule, OfxDocument document) =>
      interpretRecords(rule, document.transactions);

  RuleExecutionResult interpretRecords(
    BankRule rule,
    Iterable<Map<String, String>> records,
  ) {
    final rows = <ParsedRow>[];
    final errors = <String>[];
    int? previousBalance;

    for (var index = 0; index < records.length; index++) {
      final record = records.elementAt(index);
      if (_shouldSkip(rule, record)) continue;

      final rawDate = _fieldValue(rule, record, 'date');
      final date = rawDate == null
          ? null
          : parseStatementDate(rawDate) ??
                parseStatementDate(_cleanDate(rawDate));
      if (date == null) {
        errors.add(
          rawDate == null
              ? 'row ${index + 1}: missing date field'
              : 'row ${index + 1}: invalid date format',
        );
        continue;
      }

      final rawBalance = _fieldValue(rule, record, 'balance');
      final balance = rawBalance == null ? null : parseCrDrBalance(rawBalance);
      final amount = _amountFor(
        rule,
        record,
        previousBalance: previousBalance,
        currentBalance: balance,
      );
      if (balance != null) previousBalance = balance;
      if (amount.error != null) {
        errors.add('row ${index + 1}: ${amount.error}');
        continue;
      }
      if (amount.minor == null || amount.minor == 0) continue;

      final rawVendor = _fieldValue(
        rule,
        record,
        'vendor_raw',
        fallbackKey: 'vendor',
      );
      final ref = _fieldValue(rule, record, 'source_ref');
      rows.add(
        ParsedRow(
          ref: ref?.isEmpty == true ? null : ref,
          date: date,
          vendorRaw: rawVendor ?? '',
          amountMinor: amount.minor!.abs(),
          direction: amount.direction!,
          balanceMinor: balance,
        ),
      );
    }
    return RuleExecutionResult(rows: rows, errors: errors);
  }

  String normalizeVendor(BankRule rule, String rawVendor) {
    for (final step in rule.vendor) {
      final contains = step['contains'];
      if (contains is String &&
          rawVendor.toLowerCase().contains(contains.toLowerCase())) {
        return (step['normalize'] as String?) ?? rawVendor;
      }
      final pattern = step['match'];
      if (pattern is String &&
          RegExp(pattern, caseSensitive: false).hasMatch(rawVendor)) {
        final replacement = step['normalize'];
        return replacement == 'Preserve'
            ? rawVendor
            : (replacement as String? ?? rawVendor);
      }
    }
    return rawVendor;
  }

  ReconciliationResult reconcile(
    RuleExecutionResult result, {
    int? openingBalanceMinor,
    int? endingBalanceMinor,
    ReconciliationLevel level = ReconciliationLevel.full,
  }) {
    if (result.errors.isNotEmpty) {
      return ReconciliationResult(
        passed: false,
        level: level,
        failureMessage: result.errors.join('; '),
      );
    }
    return const Reconciler().reconcile(
      result.rows,
      openingBalanceMinor: openingBalanceMinor,
      endingBalanceMinor: endingBalanceMinor,
      level: level,
    );
  }

  bool _shouldSkip(BankRule rule, Map<String, String> record) {
    final values = record.values.join(' ').toLowerCase();
    if (rule.skipRowsContaining.any(
      (pattern) => values.contains(pattern.toLowerCase()),
    )) {
      return true;
    }
    if (rule.keepRows.isEmpty) return false;
    return !rule.keepRows.any(
      (pattern) => pattern is String && values.contains(pattern.toLowerCase()),
    );
  }

  Iterable<Map<String, String>> _inheritFields(
    BankRule rule,
    List<Map<String, String>> records,
  ) sync* {
    final configured = rule.layout['inherit_previous'];
    if (configured is! List || configured.any((value) => value is! String)) {
      yield* records;
      return;
    }

    final previous = <String, String>{};
    for (final record in records) {
      final inherited = Map<String, String>.of(record);
      for (final field in configured.cast<String>()) {
        if ((inherited[field]?.trim().isEmpty ?? true) &&
            previous.containsKey(field)) {
          inherited[field] = previous[field]!;
        }
      }
      for (final field in configured.cast<String>()) {
        final value = inherited[field]?.trim();
        if (value != null && value.isNotEmpty) previous[field] = value;
      }
      yield inherited;
    }
  }

  String? _fieldValue(
    BankRule rule,
    Map<String, String> record,
    String field, {
    String? fallbackKey,
  }) {
    final configured =
        rule.fields[field] ??
        (fallbackKey == null ? null : rule.fields[fallbackKey]);
    if (configured == null) return null;
    final choices = configured is List
        ? configured.whereType<String>()
        : configured is String
        ? [configured]
        : const <String>[];
    for (final choice in choices) {
      for (final entry in record.entries) {
        if (entry.key.toLowerCase() != choice.toLowerCase()) continue;
        final value = entry.value.trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  _ParsedAmount _amountFor(
    BankRule rule,
    Map<String, String> record, {
    int? previousBalance,
    int? currentBalance,
  }) {
    if (rule.direction == 'signed') {
      final raw = _fieldValue(rule, record, 'amount');
      final signedMinor = raw == null ? null : parseMinorUnits(raw);
      if (signedMinor == null) {
        return const _ParsedAmount(error: 'missing or invalid amount');
      }
      return _ParsedAmount(
        minor: signedMinor.abs(),
        direction: signedMinor < 0
            ? TransactionDirection.debit
            : TransactionDirection.credit,
      );
    }

    if (rule.direction == 'balance_delta') {
      if (previousBalance == null || currentBalance == null) {
        return const _ParsedAmount(
          error: 'balance_delta requires consecutive balances',
        );
      }
      final delta = currentBalance - previousBalance;
      return _ParsedAmount(
        minor: delta.abs(),
        direction: delta < 0
            ? TransactionDirection.debit
            : TransactionDirection.credit,
      );
    }

    final debitRaw =
        _fieldValue(rule, record, 'debit') ??
        _fieldValue(rule, record, 'money_out') ??
        _fieldValue(rule, record, 'withdrawn');
    final creditRaw =
        _fieldValue(rule, record, 'credit') ??
        _fieldValue(rule, record, 'money_in') ??
        _fieldValue(rule, record, 'paid_in');
    final debit = debitRaw == null ? 0 : parseMinorUnits(debitRaw)?.abs();
    final credit = creditRaw == null ? 0 : parseMinorUnits(creditRaw)?.abs();
    if ((debitRaw != null && debit == null) ||
        (creditRaw != null && credit == null)) {
      return const _ParsedAmount(error: 'invalid debit or credit amount');
    }
    if (debit == null && credit == null) {
      final signedRaw = _fieldValue(rule, record, 'amount');
      final signed = signedRaw == null ? null : parseMinorUnits(signedRaw);
      if (signed == null) {
        return const _ParsedAmount(error: 'missing amount columns');
      }
      return _ParsedAmount(
        minor: signed.abs(),
        direction: signed < 0
            ? TransactionDirection.debit
            : TransactionDirection.credit,
      );
    }
    if ((debit ?? 0) > 0 && (credit ?? 0) > 0) {
      return const _ParsedAmount(error: 'debit and credit are both populated');
    }
    if ((debit ?? 0) > 0) {
      return _ParsedAmount(minor: debit, direction: TransactionDirection.debit);
    }
    if ((credit ?? 0) > 0) {
      return _ParsedAmount(
        minor: credit,
        direction: TransactionDirection.credit,
      );
    }
    return const _ParsedAmount(minor: 0);
  }

  String _cleanDate(String raw) => raw
      .replaceAllMapped(RegExp(r'\s*([:/-])\s*'), (match) => match.group(1)!)
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class _ParsedAmount {
  final int? minor;
  final TransactionDirection? direction;
  final String? error;

  const _ParsedAmount({this.minor, this.direction, this.error});
}

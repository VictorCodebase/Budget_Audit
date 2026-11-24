import '../models/parsed_row.dart';
import '../money/minor_units.dart';

enum ReconciliationLevel { full, partial, none }

class ReconciliationResult {
  final bool passed;
  final ReconciliationLevel level;
  final int? expectedMinor;
  final int? actualMinor;
  final String? failureMessage;

  const ReconciliationResult({
    required this.passed,
    required this.level,
    this.expectedMinor,
    this.actualMinor,
    this.failureMessage,
  });

  bool get isValid => passed;
}

class Reconciler {
  const Reconciler();

  ReconciliationResult reconcile(
    List<ParsedRow> rows, {
    int? openingBalanceMinor,
    int? endingBalanceMinor,
    ReconciliationLevel level = ReconciliationLevel.full,
  }) {
    if (level == ReconciliationLevel.none) {
      return const ReconciliationResult(
        passed: true,
        level: ReconciliationLevel.none,
      );
    }

    if (level == ReconciliationLevel.partial) {
      if (openingBalanceMinor == null || endingBalanceMinor == null) {
        return const ReconciliationResult(
          passed: false,
          level: ReconciliationLevel.partial,
          failureMessage: 'Opening and ending balances are required',
        );
      }
      final actual =
          openingBalanceMinor +
          rows.fold<int>(
            0,
            (sum, row) =>
                sum +
                (row.direction == TransactionDirection.credit
                    ? row.amountMinor.abs()
                    : -row.amountMinor.abs()),
          );
      return ReconciliationResult(
        passed: actual == endingBalanceMinor,
        level: level,
        expectedMinor: endingBalanceMinor,
        actualMinor: actual,
        failureMessage: actual == endingBalanceMinor
            ? null
            : 'Opening balance plus transactions does not equal ending balance',
      );
    }

    if (openingBalanceMinor != null) {
      var running = openingBalanceMinor;
      for (final row in rows) {
        running += row.direction == TransactionDirection.credit
            ? row.amountMinor.abs()
            : -row.amountMinor.abs();
        if (row.balanceMinor != null && running != row.balanceMinor) {
          return ReconciliationResult(
            passed: false,
            level: level,
            expectedMinor: row.balanceMinor,
            actualMinor: running,
            failureMessage: 'Running balance changed',
          );
        }
      }
      if (endingBalanceMinor != null && running != endingBalanceMinor) {
        return ReconciliationResult(
          passed: false,
          level: level,
          expectedMinor: endingBalanceMinor,
          actualMinor: running,
          failureMessage: 'Ending balance changed',
        );
      }
    } else {
      final firstWithBalance = rows.indexWhere(
        (row) => row.balanceMinor != null,
      );
      if (firstWithBalance >= 0) {
        final first = rows[firstWithBalance];
        var running =
            first.balanceMinor! -
            (first.direction == TransactionDirection.credit
                ? first.amountMinor.abs()
                : -first.amountMinor.abs());
        for (final row in rows.skip(firstWithBalance)) {
          running += row.direction == TransactionDirection.credit
              ? row.amountMinor.abs()
              : -row.amountMinor.abs();
          if (row.balanceMinor != null && running != row.balanceMinor) {
            return ReconciliationResult(
              passed: false,
              level: level,
              expectedMinor: row.balanceMinor,
              actualMinor: running,
              failureMessage: 'Running balance changed',
            );
          }
        }
      }
    }
    return const ReconciliationResult(
      passed: true,
      level: ReconciliationLevel.full,
    );
  }
}

int? parseCrDrBalance(String raw, {String? indicator}) {
  final minor = parseMinorUnits(raw);
  if (minor == null) return null;
  final isDr =
      indicator?.trim().toUpperCase() == 'DR' ||
      raw.trim().toUpperCase().endsWith('DR');
  return isDr ? -minor.abs() : minor.abs();
}

ReconciliationResult reconcile(
  List<ParsedRow> rows, {
  int? openingBalanceMinor,
  int? endingBalanceMinor,
  ReconciliationLevel level = ReconciliationLevel.full,
}) {
  return const Reconciler().reconcile(
    rows,
    openingBalanceMinor: openingBalanceMinor,
    endingBalanceMinor: endingBalanceMinor,
    level: level,
  );
}

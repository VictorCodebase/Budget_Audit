import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

ParsedRow row(int amount, TransactionDirection direction, {int? balance}) {
  return ParsedRow(
    date: DateTime.utc(2026),
    vendorRaw: 'Test',
    amountMinor: amount,
    direction: direction,
    balanceMinor: balance,
  );
}

void main() {
  test('full reconciliation detects altered balance', () {
    final result = reconcile([
      row(1000, TransactionDirection.credit, balance: 11000),
    ], openingBalanceMinor: 10000);
    expect(result.passed, isTrue);

    final altered = reconcile([
      row(1000, TransactionDirection.credit, balance: 12000),
    ], openingBalanceMinor: 10000);
    expect(altered.passed, isFalse);
  });

  test('Cr and Dr balances are signed consistently', () {
    expect(parseCrDrBalance('1,000.00', indicator: 'Cr'), 100000);
    expect(parseCrDrBalance('1,000.00', indicator: 'Dr'), -100000);
  });

  test('OFX partial reconciliation uses opening and ending balances', () {
    final result = reconcile(
      [
        row(2000, TransactionDirection.credit),
        row(500, TransactionDirection.debit),
      ],
      openingBalanceMinor: 10000,
      endingBalanceMinor: 11500,
      level: ReconciliationLevel.partial,
    );
    expect(result.passed, isTrue);
  });

  test('none reconciliation requires no balance', () {
    expect(reconcile([], level: ReconciliationLevel.none).passed, isTrue);
  });
}

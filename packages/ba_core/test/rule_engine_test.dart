import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  test('M-PESA rule preserves both paid-in and withdrawn amounts', () {
    final rule = const RuleLoader().loadString(
      File('../../assets/rules/mpesa.json').readAsStringSync(),
    );
    final result = const RuleEngine().interpretRecords(rule, [
      {
        'Receipt No': 'RCPT-1',
        'Completion Time': '2026-07-18 12:29:10',
        'Details': 'OverDraft of Credit Party',
        'Transaction Status': 'Completed',
        'Paid In': '137.00',
        'Withdrawn': '',
        'Balance': '',
      },
      {
        'Receipt No': 'RCPT-2',
        'Completion Time': '2026-07-18 12:29:11',
        'Details': 'Send Money',
        'Transaction Status': 'Completed',
        'Paid In': '',
        'Withdrawn': '130.00',
        'Balance': '',
      },
    ]);

    expect(result.errors, isEmpty);
    expect(result.rows, hasLength(2));
    expect(result.rows.first.direction, TransactionDirection.credit);
    expect(result.rows.first.amountMinor, 13700);
    expect(result.rows.first.ref, 'RCPT-1');
    expect(result.rows.last.direction, TransactionDirection.debit);
    expect(result.rows.last.amountMinor, 13000);
  });

  test('positioned words combine split headers and wrapped details', () {
    final rule = const RuleLoader().loadString(
      File('../../assets/rules/mpesa.json').readAsStringSync(),
    );
    final positioned = [
      const PositionedWord(text: 'Receipt', x: 0, y: 0, width: 35, height: 8),
      const PositionedWord(text: 'No.', x: 36, y: 0, width: 15, height: 8),
      const PositionedWord(
        text: 'Completion',
        x: 60,
        y: 0,
        width: 60,
        height: 8,
      ),
      const PositionedWord(text: 'Time', x: 121, y: 0, width: 25, height: 8),
      const PositionedWord(text: 'Details', x: 160, y: 0, width: 40, height: 8),
      const PositionedWord(
        text: 'Transaction',
        x: 210,
        y: 0,
        width: 65,
        height: 8,
      ),
      const PositionedWord(text: 'Status', x: 276, y: 0, width: 35, height: 8),
      const PositionedWord(text: 'Paid', x: 330, y: 0, width: 24, height: 8),
      const PositionedWord(text: 'In', x: 355, y: 0, width: 10, height: 8),
      const PositionedWord(
        text: 'Withdrawn',
        x: 385,
        y: 0,
        width: 55,
        height: 8,
      ),
      const PositionedWord(text: 'Balance', x: 460, y: 0, width: 42, height: 8),
      const PositionedWord(text: 'RCPT-1', x: 0, y: 20, width: 40, height: 8),
      const PositionedWord(
        text: '2026-07-18',
        x: 60,
        y: 20,
        width: 60,
        height: 8,
      ),
      const PositionedWord(
        text: '12:29:10',
        x: 121,
        y: 20,
        width: 35,
        height: 8,
      ),
      const PositionedWord(
        text: 'OverDraft',
        x: 160,
        y: 20,
        width: 55,
        height: 8,
      ),
      const PositionedWord(
        text: 'of Credit Party',
        x: 160,
        y: 30,
        width: 90,
        height: 8,
      ),
      const PositionedWord(
        text: 'Completed',
        x: 276,
        y: 20,
        width: 55,
        height: 8,
      ),
      const PositionedWord(text: '137.00', x: 330, y: 20, width: 40, height: 8),
    ];

    final result = const RuleEngine().interpretPositionedWords(
      rule,
      positioned,
    );
    expect(result.errors, isEmpty);
    expect(result.rows, hasLength(1));
    expect(result.rows.single.date, DateTime.utc(2026, 7, 18, 12, 29, 10));
    expect(result.rows.single.vendorRaw, 'OverDraft of Credit Party');
    expect(result.rows.single.direction, TransactionDirection.credit);
    expect(result.rows.single.amountMinor, 13700);
  });

  test('invalid populated amounts are surfaced', () {
    final rule = const RuleLoader().loadString(
      File('../../assets/rules/mpesa.json').readAsStringSync(),
    );
    final result = const RuleEngine().interpretRecords(rule, [
      {
        'Receipt No': 'RCPT-1',
        'Completion Time': '2026-07-18 12:29:10',
        'Details': 'Payment',
        'Transaction Status': 'Completed',
        'Paid In': 'not-money',
        'Withdrawn': '',
      },
    ]);

    expect(result.rows, isEmpty);
    expect(result.errors, hasLength(1));
  });
}

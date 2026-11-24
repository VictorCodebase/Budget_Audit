import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

PositionedWord word(String text, double x, double y) =>
    PositionedWord(text: text, x: x, y: y, width: 20, height: 10);

void main() {
  test('handles reordered columns and wrapped details', () {
    final words = [
      word('Date', 10, 10),
      word('Details', 100, 10),
      word('Amount', 200, 10),
      word('05-03-2026', 10, 30),
      word('Shop', 100, 30),
      word('payment', 100, 40),
      word('209.00', 200, 30),
      word('06-03-2026', 10, 50),
      word('', 100, 50),
      word('30.00', 200, 50),
    ];
    final rows = interpretHeaderTable(
      words,
      headers: ['Date', 'Details', 'Amount'],
      rowStartPattern: r'^\d{2}-\d{2}-\d{4}$',
    );
    expect(rows, hasLength(2));
    expect(rows.first['Details'], contains('Shop payment'));
    expect(rows.last['Amount'], '30.00');
  });

  test('empty cell does not create a phantom row', () {
    final words = [
      word('Date', 10, 10),
      word('Amount', 200, 10),
      word('05-03-2026', 10, 30),
      word('209.00', 200, 30),
    ];
    final rows = interpretHeaderTable(
      words,
      headers: ['Date', 'Amount'],
      rowStartPattern: r'^\d{2}-\d{2}-\d{4}$',
    );
    expect(rows, hasLength(1));
    expect(rows.first['Amount'], '209.00');
  });
}

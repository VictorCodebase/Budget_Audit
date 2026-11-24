import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

PositionedWord word(String text, double x, double y) =>
    PositionedWord(text: text, x: x, y: y, width: 20, height: 10);

void main() {
  test('handles reordered columns and wrapped details', () {
    final words = [
      word('Date', 10, 100),
      word('Details', 100, 100),
      word('Amount', 200, 100),
      word('05-03-2026', 10, 80),
      word('Shop', 100, 80),
      word('payment', 100, 70),
      word('209.00', 200, 80),
      word('06-03-2026', 10, 60),
      word('', 100, 60),
      word('30.00', 200, 60),
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
      word('Date', 10, 100),
      word('Amount', 200, 100),
      word('05-03-2026', 10, 80),
      word('209.00', 200, 80),
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

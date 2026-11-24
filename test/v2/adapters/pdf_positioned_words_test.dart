import 'dart:io';

import 'package:budget_audit/v2/adapters/pdf_positioned_words.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts positioned words from a redacted fixture', () {
    final fixture = File('test/fixtures/Equity_Statement_sample_redacted.pdf');
    expect(fixture.existsSync(), isTrue);

    final words = PdfPositionedWordAdapter().extract(fixture);

    expect(words, isNotEmpty);
    expect(words.first.x, greaterThanOrEqualTo(0));
    expect(words.first.y, greaterThanOrEqualTo(0));
  });
}

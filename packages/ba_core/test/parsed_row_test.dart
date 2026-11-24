import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  group('minor-unit money', () {
    test('parses thousands and decimal formats', () {
      expect(parseMinorUnits('1,234.56'), 123456);
      expect(parseMinorUnits('1.234,56'), 123456);
      expect(parseMinorUnits('1 234.5'), 123450);
    });

    test('rounds and handles negatives', () {
      expect(parseMinorUnits('12.345'), 1235);
      expect(parseMinorUnits('-12.34'), -1234);
      expect(parseMinorUnits('(12.34)'), -1234);
      expect(parseMinorUnits('CR 10.00'), 1000);
      expect(parseMinorUnits('10.00 DR'), -1000);
    });
  });

  group('date parsing', () {
    test('supports statement and OFX formats', () {
      expect(
        parseStatementDate('2026-07-18 12:29:10'),
        DateTime.utc(2026, 7, 18, 12, 29, 10),
      );
      expect(parseStatementDate('18-07-2026'), DateTime.utc(2026, 7, 18));
      expect(
        parseStatementDate('20260718122910[3:EAT]'),
        DateTime.utc(2026, 7, 18, 12, 29, 10),
      );
    });
  });
}

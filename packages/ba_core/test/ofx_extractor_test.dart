import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  test('extracts unclosed SGML tags and date suffixes', () {
    const source = '''
<OFX>
<STMTTRN>
<TRNTYPE>DEBIT
<TRNAMT>-130.00
<DTPOSTED>20260718122910[3:EAT]
<FITID>UGIATBMA60-20260718122910-2
<NAME>Customer Payment
</STMTTRN>
''';
    final document = const OfxExtractor().extract(source);
    expect(document.transactions, hasLength(1));
    expect(document.transactions.first['FITID'], 'UGIATBMA60-20260718122910-2');
    expect(
      document.transactions.first['source_ref'],
      'UGIATBMA60-20260718122910-2',
    );
    expect(document.transactions.first['DTPOSTED'], '20260718122910');
  });

  test('extracts M-PESA and Equity redacted OFX fixtures', () {
    final mpesa = File(
      '../../test/golden/MPESA_Statement_2026-07-01_to_2026-07-18.ofx',
    );
    final equity = File(
      '../../test/golden/Equity_Statement_2026-03-02_to_2026-04-01.ofx',
    );
    expect(const OfxExtractor().extractFile(mpesa).transactions, isNotEmpty);
    expect(const OfxExtractor().extractFile(equity).transactions, isNotEmpty);
  });

  test('generic OFX rule loads', () {
    final rule = const RuleLoader().loadString(
      File('../../assets/rules/ofx_generic.json').readAsStringSync(),
    );
    expect(rule.extractor, 'ofx');
  });
}

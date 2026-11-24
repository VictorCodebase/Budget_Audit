import 'dart:io';

class OfxDocument {
  final List<Map<String, String>> transactions;
  final Map<String, String> fields;

  const OfxDocument({required this.transactions, required this.fields});
}

class OfxExtractor {
  const OfxExtractor();

  OfxDocument extract(String source) {
    final fields = _scanFields(source);
    final transactions = <Map<String, String>>[];
    final startPattern = RegExp(r'<STMTTRN\s*>', caseSensitive: false);
    final startMatches = startPattern.allMatches(source).toList();
    for (var index = 0; index < startMatches.length; index++) {
      final start = startMatches[index].end;
      final end = index + 1 < startMatches.length
          ? startMatches[index + 1].start
          : source.indexOf('</STMTRS>', start);
      final block = source.substring(start, end >= start ? end : source.length);
      final transaction = _scanFields(block);
      if (transaction.isNotEmpty) {
        if (transaction['FITID'] != null) {
          transaction['source_ref'] = transaction['FITID']!;
        }
        transactions.add(transaction);
      }
    }
    return OfxDocument(transactions: transactions, fields: fields);
  }

  OfxDocument extractFile(File file) => extract(file.readAsStringSync());

  Map<String, String> _scanFields(String source) {
    final result = <String, String>{};
    final tag = RegExp(
      r'<([A-Za-z][A-Za-z0-9._]*?)>([^<\r\n]*)',
      caseSensitive: false,
    );
    for (final match in tag.allMatches(source)) {
      final name = match.group(1)!.toUpperCase();
      var value = match.group(2)!.trim();
      if (name == 'DTPOSTED' || name == 'DTSTART' || name == 'DTEND') {
        value = value.replaceFirst(RegExp(r'\[.*$', caseSensitive: false), '');
      }
      result[name] = value;
    }
    return result;
  }
}

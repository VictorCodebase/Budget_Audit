import 'dart:io';

class CsvDocument {
  final List<String> headers;
  final List<Map<String, String>> rows;

  const CsvDocument({required this.headers, required this.rows});
}

class CsvExtractor {
  const CsvExtractor();

  CsvDocument extract(String source) {
    final parsed = _parseCsv(source);
    if (parsed.isEmpty) return const CsvDocument(headers: [], rows: []);
    final headers = parsed.first.map((value) => value.trim()).toList();
    final rows = <Map<String, String>>[];
    for (var index = 1; index < parsed.length; index++) {
      final values = parsed[index];
      if (values.isEmpty || values.every((value) => value.trim().isEmpty)) {
        continue;
      }
      final row = <String, String>{};
      for (var column = 0; column < headers.length; column++) {
        row[headers[column]] = column < values.length
            ? values[column].trim()
            : '';
      }
      rows.add(row);
    }
    return CsvDocument(headers: headers, rows: rows);
  }

  CsvDocument extractFile(File file) => extract(file.readAsStringSync());

  List<List<String>> _parseCsv(String source) {
    final records = <List<String>>[];
    var record = <String>[];
    var field = StringBuffer();
    var inQuotes = false;
    for (var index = 0; index < source.length; index++) {
      final char = source[index];
      if (char == '"') {
        if (inQuotes && index + 1 < source.length && source[index + 1] == '"') {
          field.write('"');
          index++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        record.add(field.toString());
        field = StringBuffer();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' &&
            index + 1 < source.length &&
            source[index + 1] == '\n') {
          index++;
        }
        record.add(field.toString());
        field = StringBuffer();
        if (record.any((value) => value.isNotEmpty)) {
          records.add(record);
        }
        record = [];
      } else {
        field.write(char);
      }
    }
    record.add(field.toString());
    if (record.any((value) => value.isNotEmpty)) {
      records.add(record);
    }
    return records;
  }
}

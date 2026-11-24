class PositionedWord {
  final String text;
  final double x;
  final double y;
  final double width;
  final double height;
  final int page;

  const PositionedWord({
    required this.text,
    required this.x,
    required this.y,
    this.width = 0,
    this.height = 0,
    this.page = 0,
  });

  double get right => x + width;
  double get centerX => x + width / 2;
  double get centerY => y + height / 2;
}

class HeaderTableInterpreter {
  const HeaderTableInterpreter();

  List<Map<String, String>> interpret(
    List<PositionedWord> words, {
    required List<String> headers,
    required String rowStartPattern,
    double yTolerance = 3,
  }) {
    if (words.isEmpty) return const [];
    final pageWords = words
        .where((word) => word.page == words.first.page)
        .toList();
    final headerY = <String, double>{};
    for (final header in headers) {
      final matches = pageWords.where(
        (word) => word.text.trim().toLowerCase() == header.trim().toLowerCase(),
      );
      if (matches.isNotEmpty) {
        headerY[header] = matches
            .map((word) => word.centerY)
            .reduce((a, b) => a < b ? a : b);
      }
    }
    if (headerY.isEmpty) return const [];

    final headerWords = pageWords.where(
      (word) =>
          headerY.values.any((y) => (word.centerY - y).abs() <= yTolerance * 3),
    );
    final ranges = <String, List<PositionedWord>>{};
    for (final entry in headerY.entries) {
      ranges[entry.key] = headerWords
          .where(
            (word) =>
                (word.centerY - entry.value).abs() <= yTolerance * 3 &&
                word.text.trim().toLowerCase().contains(
                  entry.key.toLowerCase(),
                ),
          )
          .toList();
    }

    final content = pageWords.where(
      (word) => !headerY.values.any(
        (y) => (word.centerY - y).abs() <= yTolerance * 3,
      ),
    );
    final grouped = <double, List<PositionedWord>>{};
    for (final word in content) {
      double? key;
      for (final existing in grouped.keys) {
        if ((existing - word.centerY).abs() <= yTolerance) {
          key = existing;
          break;
        }
      }
      key ??= word.centerY;
      grouped.putIfAbsent(key, () => []).add(word);
    }

    final rowStart = RegExp(rowStartPattern);
    final orderedRows = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final rows = <Map<String, String>>[];
    var current = <String, String>{};
    for (final entry in orderedRows) {
      final line = entry.value..sort((a, b) => a.centerX.compareTo(b.centerX));
      String columnFor(PositionedWord word) {
        for (final header in headers) {
          final matches = pageWords.where(
            (candidate) =>
                candidate.text.trim().toLowerCase() ==
                header.trim().toLowerCase(),
          );
          if (matches.isNotEmpty) {
            final center = matches.first.centerX;
            final nearestCenter = headers.map((candidate) {
              final candidateMatches = pageWords.where(
                (item) =>
                    item.text.trim().toLowerCase() ==
                    candidate.trim().toLowerCase(),
              );
              return candidateMatches.isEmpty
                  ? double.infinity
                  : candidateMatches.first.centerX;
            }).toList();
            final distance = (word.centerX - center).abs();
            if (distance <=
                nearestCenter
                        .map((value) => (word.centerX - value).abs())
                        .reduce((a, b) => a < b ? a : b) +
                    0.01) {
              return header;
            }
          }
        }
        return headers.first;
      }

      final cellValues = <String, List<String>>{};
      for (final word in line) {
        final column = columnFor(word);
        cellValues.putIfAbsent(column, () => []).add(word.text);
      }
      final lineMap = {
        for (final entry in cellValues.entries)
          entry.key: entry.value.join(' ').trim(),
      };
      final startColumn = headers.first;
      final startValue = lineMap[startColumn] ?? '';
      if (rowStart.hasMatch(startValue)) {
        if (current.isNotEmpty) rows.add(Map.of(current));
        current = lineMap;
      } else if (current.isNotEmpty) {
        for (final entry in lineMap.entries) {
          current.update(
            entry.key,
            (value) => '$value ${entry.value}'.trim(),
            ifAbsent: () => entry.value,
          );
        }
      } else {
        current = lineMap;
      }
    }
    if (current.isNotEmpty) rows.add(current);
    return rows;
  }
}

List<Map<String, String>> interpretHeaderTable(
  List<PositionedWord> words, {
  required List<String> headers,
  required String rowStartPattern,
}) => const HeaderTableInterpreter().interpret(
  words,
  headers: headers,
  rowStartPattern: rowStartPattern,
);

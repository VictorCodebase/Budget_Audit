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
    String? rowStartColumn,
    String? continuationColumn,
    List<String> numericColumns = const [],
    List<String> skipLinesContaining = const [],
    double yTolerance = 3,
  }) {
    if (words.isEmpty || headers.isEmpty) return const [];
    final rows = <Map<String, String>>[];
    final pages = words.map((word) => word.page).toSet().toList()..sort();
    final rowStart = RegExp(rowStartPattern);

    for (final page in pages) {
      final pageWords = words.where((word) => word.page == page).toList();
      final lines = _groupLines(pageWords, yTolerance);
      final headerLineIndex = _findHeaderLine(lines, headers);
      if (headerLineIndex < 0) continue;

      final anchors = _findHeaderAnchors(lines[headerLineIndex], headers);
      if (anchors.isEmpty) continue;
      final sortedAnchors = anchors.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final startHeader = rowStartColumn ?? headers.first;
      var current = <String, String>{};

      for (final line in lines.skip(headerLineIndex + 1)) {
        final cells = _assignCells(
          line.words,
          sortedAnchors,
          numericColumns: numericColumns,
          continuationColumn: continuationColumn,
        );
        final lineText = cells.values.join(' ').toLowerCase();
        if (skipLinesContaining.any(
          (pattern) => lineText.contains(pattern.toLowerCase()),
        )) {
          continue;
        }
        final startValue = cells[startHeader] ?? '';
        if (rowStart.hasMatch(startValue)) {
          if (current.isNotEmpty) rows.add(Map.of(current));
          current = cells;
        } else if (current.isNotEmpty) {
          final continuation = continuationColumn == null
              ? cells
              : {
                  if (cells[continuationColumn] case final value?)
                    continuationColumn: value,
                };
          for (final entry in continuation.entries) {
            current.update(
              entry.key,
              (value) => _joinCell(value, entry.value),
              ifAbsent: () => entry.value,
            );
          }
        }
      }
      if (current.isNotEmpty) rows.add(current);
    }

    return rows;
  }

  List<_PositionedLine> _groupLines(
    List<PositionedWord> words,
    double tolerance,
  ) {
    final ordered = words.toList()
      ..sort((a, b) {
        final yOrder = a.centerY.compareTo(b.centerY);
        return yOrder == 0 ? a.centerX.compareTo(b.centerX) : yOrder;
      });
    final lines = <_PositionedLine>[];
    for (final word in ordered) {
      if (word.text.trim().isEmpty) continue;
      _PositionedLine? line;
      for (final candidate in lines.reversed) {
        if ((candidate.centerY - word.centerY).abs() <= tolerance) {
          line = candidate;
          break;
        }
        if (word.centerY - candidate.centerY > tolerance) break;
      }
      if (line == null) {
        lines.add(_PositionedLine([word]));
      } else {
        line.words.add(word);
        line.recalculateY();
      }
    }
    for (final line in lines) {
      line.words.sort((a, b) => a.centerX.compareTo(b.centerX));
    }
    lines.sort((a, b) => a.centerY.compareTo(b.centerY));
    return lines;
  }

  int _findHeaderLine(List<_PositionedLine> lines, List<String> headers) {
    var bestIndex = -1;
    var bestMatches = 0;
    for (var index = 0; index < lines.length; index++) {
      final found = _findHeaderAnchors(lines[index], headers).length;
      if (found > bestMatches) {
        bestMatches = found;
        bestIndex = index;
      }
    }
    return bestMatches >= 2 ? bestIndex : -1;
  }

  Map<String, double> _findHeaderAnchors(
    _PositionedLine line,
    List<String> headers,
  ) {
    final result = <String, double>{};
    final visible = line.words
        .where((word) => word.text.trim().isNotEmpty)
        .toList();
    for (final header in headers) {
      final expected = _normalizeHeader(header);
      for (var start = 0; start < visible.length; start++) {
        final buffer = StringBuffer();
        for (var end = start; end < visible.length && end < start + 5; end++) {
          buffer.write(visible[end].text);
          if (_normalizeHeader(buffer.toString()) == expected) {
            final left = visible[start].x;
            final right = visible[end].right;
            result[header] = (left + right) / 2;
            break;
          }
        }
        if (result.containsKey(header)) break;
      }
    }
    return result;
  }

  Map<String, String> _assignCells(
    List<PositionedWord> words,
    List<MapEntry<String, double>> anchors, {
    List<String> numericColumns = const [],
    String? continuationColumn,
  }) {
    final cells = <String, List<PositionedWord>>{};
    for (final word in words) {
      var index = 0;
      while (index < anchors.length - 1) {
        final boundary = (anchors[index].value + anchors[index + 1].value) / 2;
        if (word.centerX < boundary) break;
        index++;
      }
      cells.putIfAbsent(anchors[index].key, () => []).add(word);
    }
    if (continuationColumn != null) {
      for (final column in numericColumns) {
        final values = cells[column];
        if (values == null) continue;
        final amounts = values.where(_isNumericAmountWord).toList();
        final details = values.where((word) => !_isNumericAmountWord(word));
        if (amounts.isEmpty) {
          cells.remove(column);
        } else {
          cells[column] = amounts;
          if (details.isNotEmpty) {
            cells.putIfAbsent(continuationColumn, () => []).addAll(details);
          }
        }
      }
    }
    return {
      for (final entry in cells.entries)
        entry.key: _cleanCell(
          (entry.value..sort((a, b) => a.centerX.compareTo(b.centerX)))
              .map((word) => word.text)
              .join(' '),
        ),
    };
  }

  bool _isNumericAmountWord(PositionedWord word) => RegExp(
    r'^[+-]?(?:\d{1,3}(?:,\d{3})+|\d+)(?:\.\d{1,2})?$',
  ).hasMatch(word.text.trim());

  String _normalizeHeader(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String _cleanCell(String value) => value
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAllMapped(RegExp(r'\s+([,.:;!?])'), (match) => match.group(1)!)
      .replaceAllMapped(RegExp(r'\s+([-/:])\s+'), (match) => match.group(1)!)
      .trim();

  String _joinCell(String left, String right) {
    if (left.isEmpty) return right;
    if (right.isEmpty) return left;
    return _cleanCell('$left $right');
  }
}

class _PositionedLine {
  final List<PositionedWord> words;
  double centerY;

  _PositionedLine(this.words) : centerY = words.first.centerY;

  void recalculateY() {
    centerY =
        words.map((word) => word.centerY).reduce((a, b) => a + b) /
        words.length;
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

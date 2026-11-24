DateTime? parseStatementDate(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;
  text = text.replaceAll(RegExp(r'\[\d+:[A-Z]+\]$', caseSensitive: false), '');

  DateTime? tryBuild(List<int> parts, {bool yearFirst = false}) {
    final y = yearFirst ? parts[0] : parts[2];
    final m = yearFirst ? parts[1] : parts[1];
    final d = yearFirst ? parts[2] : parts[0];
    if (parts.length < 3) return null;
    final hour = parts.length > 3 ? parts[3] : 0;
    final minute = parts.length > 4 ? parts[4] : 0;
    final second = parts.length > 5 ? parts[5] : 0;
    final result = DateTime.utc(y, m, d, hour, minute, second);
    return result.year == y && result.month == m && result.day == d
        ? result
        : null;
  }

  final ofx = RegExp(r'^(\d{4})(\d{2})(\d{2})(\d{2})?(\d{2})?(\d{2})?');
  final ofxMatch = ofx.firstMatch(text);
  if (ofxMatch != null) {
    final values = ofxMatch
        .groups([1, 2, 3, 4, 5, 6])
        .whereType<String>()
        .map(int.parse)
        .toList();
    final result = tryBuild(values, yearFirst: true);
    if (result != null) return result;
  }

  final numeric = RegExp(
    r'^(\d{1,4})[-/.](\d{1,2})[-/.](\d{1,4})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?',
  );
  final match = numeric.firstMatch(text);
  if (match != null) {
    final values = match
        .groups([1, 2, 3, 4, 5, 6])
        .whereType<String>()
        .map(int.parse)
        .toList();
    if (values[0] >= 1000) {
      return tryBuild(values, yearFirst: true);
    }
    return tryBuild(values);
  }
  return null;
}

DateTime? parseDate(String raw) => parseStatementDate(raw);

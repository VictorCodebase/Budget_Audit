int? parseMinorUnits(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;

  final negative =
      text.startsWith('-') ||
      (text.startsWith('(') && text.endsWith(')')) ||
      text.toUpperCase().contains('DR');
  text = text
      .replaceAll(RegExp(r'[A-Za-z\s£$€KES]', caseSensitive: false), '')
      .replaceAll(RegExp(r"['_]"), '')
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll('+', '')
      .replaceAll('-', '')
      .trim();
  if (text.isEmpty) return null;

  if (text.contains('.') && text.contains(',')) {
    final decimalSeparatorIndex = text.lastIndexOf(RegExp(r'[.,]'));
    final separator = text[decimalSeparatorIndex];
    text = text
        .replaceAll(separator == '.' ? ',' : '.', '')
        .replaceAll(separator, '.');
  } else if (text.contains(',') && !text.contains('.')) {
    final commaIndex = text.lastIndexOf(',');
    final fractionLength = text.length - commaIndex - 1;
    if (fractionLength <= 2) {
      text = text.replaceAll(',', '.');
    } else {
      text = text.replaceAll(',', '');
    }
  }

  final parts = text.split('.');
  if (parts.length > 2) return null;
  final whole = parts.first.replaceAll(RegExp(r'[^\d]'), '');
  var fraction = parts.length == 2
      ? parts.last.replaceAll(RegExp(r'[^\d]'), '')
      : '';
  if (whole.isEmpty) return null;

  var fractionDigits = fraction.padRight(2, '0');
  var roundUp = fraction.length > 2 && int.parse(fraction[2]) >= 5;
  if (fractionDigits.length > 2) {
    fractionDigits = fractionDigits.substring(0, 2);
  }
  var minor =
      int.parse(whole) * 100 +
      int.parse(fractionDigits.padRight(2, '0')) +
      (roundUp ? 1 : 0);
  if (negative) minor = -minor;
  return minor;
}

int? parseMoneyMinor(String raw) => parseMinorUnits(raw);

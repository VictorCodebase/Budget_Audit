enum TransactionDirection { debit, credit }

class ParsedRow {
  final String? ref;
  final DateTime date;
  final String vendorRaw;
  final int amountMinor;
  final TransactionDirection direction;
  final int? balanceMinor;

  const ParsedRow({
    this.ref,
    required this.date,
    required this.vendorRaw,
    required this.amountMinor,
    required this.direction,
    this.balanceMinor,
  });

  String? get sourceRef => ref;
}

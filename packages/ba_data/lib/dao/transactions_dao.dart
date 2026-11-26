import 'package:drift/drift.dart';

import '../schema/database.dart';

class TransactionsDao {
  TransactionsDao(this.db);

  final AppDatabase db;

  Future<int> create({
    required String id,
    required int date,
    required String vendorId,
    required String categoryId,
    required int amountMinor,
    required String note,
    String? sourceRef,
    required bool isManual,
    required int updatedAt,
  }) async {
    if (sourceRef != null) {
      final existing = await (db.select(
        db.transactions,
      )..where((row) => row.sourceRef.equals(sourceRef))).getSingleOrNull();
      if (existing != null) {
        return 0;
      }
    }
    final companion = TransactionsCompanion.insert(
      id: id,
      date: date,
      vendorId: vendorId,
      categoryId: categoryId,
      amountMinor: amountMinor,
      note: note,
      sourceRef: sourceRef == null ? const Value.absent() : Value(sourceRef),
      isManual: isManual,
      updatedAt: updatedAt,
    );
    return db
        .into(db.transactions)
        .insert(companion, mode: InsertMode.insertOrIgnore);
  }

  Future<List<Transaction>> all() {
    return (db.select(
      db.transactions,
    )..where((row) => row.deletedAt.isNull())).get();
  }

  Future<Transaction?> getById(String id) {
    return (db.select(
      db.transactions,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<int> softDelete(String id, int deletedAt) {
    return (db.update(
      db.transactions,
    )..where((row) => row.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }
}

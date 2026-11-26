import 'package:drift/drift.dart';

import '../schema/database.dart';

class VendorsDao {
  VendorsDao(this.db);

  final AppDatabase db;

  Future<int> create({
    required String id,
    required String name,
    required int updatedAt,
  }) {
    return db
        .into(db.vendors)
        .insert(
          VendorsCompanion.insert(id: id, name: name, updatedAt: updatedAt),
        );
  }

  Future<List<Vendor>> all() {
    return db.select(db.vendors).get();
  }

  Future<Vendor?> getById(String id) {
    return (db.select(
      db.vendors,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<int> rename({
    required String id,
    required String name,
    required int updatedAt,
  }) {
    return (db.update(db.vendors)..where((row) => row.id.equals(id))).write(
      VendorsCompanion(name: Value(name), updatedAt: Value(updatedAt)),
    );
  }

  Future<int> delete(String id) {
    return (db.delete(db.vendors)..where((row) => row.id.equals(id))).go();
  }
}

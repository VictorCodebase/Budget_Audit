import 'package:drift/drift.dart';

import '../schema/database.dart';

class VendorDefaultsDao {
  VendorDefaultsDao(this.db);

  final AppDatabase db;

  Future<VendorDefault?> get(String vendorId) {
    return (db.select(
      db.vendorDefaults,
    )..where((row) => row.vendorId.equals(vendorId))).getSingleOrNull();
  }

  Future<VendorDefault> upsert({
    required String vendorId,
    required String categoryId,
    required int usedAt,
  }) async {
    final existing = await get(vendorId);
    if (existing == null) {
      await db
          .into(db.vendorDefaults)
          .insert(
            VendorDefaultsCompanion.insert(
              vendorId: vendorId,
              categoryId: categoryId,
              useCount: 1,
              lastUsed: usedAt,
              updatedAt: usedAt,
            ),
          );
    } else {
      await (db.update(
        db.vendorDefaults,
      )..where((row) => row.vendorId.equals(vendorId))).write(
        VendorDefaultsCompanion(
          categoryId: Value(categoryId),
          useCount: Value(existing.useCount + 1),
          lastUsed: Value(usedAt),
          updatedAt: Value(usedAt),
        ),
      );
    }
    return (await get(vendorId))!;
  }

  Future<int> delete(String vendorId) {
    return (db.delete(
      db.vendorDefaults,
    )..where((row) => row.vendorId.equals(vendorId))).go();
  }
}

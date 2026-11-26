import 'package:drift/drift.dart';

import '../schema/database.dart';

class CategoriesDao {
  CategoriesDao(this.db);

  final AppDatabase db;

  Future<int> create({
    required String id,
    String? groupId,
    required String name,
    required bool isSaving,
    required String color,
    required int updatedAt,
  }) {
    return db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            groupId: groupId == null ? const Value.absent() : Value(groupId),
            name: name,
            isSaving: isSaving,
            color: color,
            updatedAt: updatedAt,
          ),
        );
  }

  Future<List<Category>> all({bool includeArchived = false}) {
    final query = db.select(db.categories)
      ..where(
        (row) =>
            includeArchived ? const Constant(true) : row.archivedAt.isNull(),
      );
    return query.get();
  }

  Future<Category?> getById(String id) {
    return (db.select(
      db.categories,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<int> updateCategory({
    required String id,
    String? groupId,
    String? name,
    bool? isSaving,
    String? color,
    required int updatedAt,
  }) {
    return (db.update(db.categories)..where((row) => row.id.equals(id))).write(
      CategoriesCompanion(
        groupId: groupId == null
            ? const Value<String?>.absent()
            : Value(groupId),
        name: name == null ? const Value.absent() : Value(name),
        isSaving: isSaving == null ? const Value.absent() : Value(isSaving),
        color: color == null ? const Value.absent() : Value(color),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<int> archive(String id, int archivedAt) {
    return (db.update(db.categories)..where((row) => row.id.equals(id))).write(
      CategoriesCompanion(
        archivedAt: Value(archivedAt),
        updatedAt: Value(archivedAt),
      ),
    );
  }

  Future<int> delete(String id) {
    return (db.delete(db.categories)..where((row) => row.id.equals(id))).go();
  }
}

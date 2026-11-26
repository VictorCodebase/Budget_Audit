import 'package:drift/drift.dart';

import '../schema/database.dart';

class GroupsDao {
  GroupsDao(this.db);

  final AppDatabase db;

  Future<int> create({
    required String id,
    required String name,
    required int sort,
    required String color,
    required int updatedAt,
  }) {
    return db
        .into(db.groups)
        .insert(
          GroupsCompanion.insert(
            id: id,
            name: name,
            sort: sort,
            color: color,
            updatedAt: updatedAt,
          ),
        );
  }

  Future<List<Group>> all({bool includeArchived = false}) {
    final query = db.select(db.groups)
      ..where(
        (row) =>
            includeArchived ? const Constant(true) : row.archivedAt.isNull(),
      );
    return query.get();
  }

  Future<Group?> getById(String id) {
    return (db.select(
      db.groups,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<int> rename({
    required String id,
    required String name,
    required int updatedAt,
  }) {
    return (db.update(db.groups)..where((row) => row.id.equals(id))).write(
      GroupsCompanion(name: Value(name), updatedAt: Value(updatedAt)),
    );
  }

  Future<int> archive(String id, int archivedAt) {
    return (db.update(db.groups)..where((row) => row.id.equals(id))).write(
      GroupsCompanion(
        archivedAt: Value(archivedAt),
        updatedAt: Value(archivedAt),
      ),
    );
  }

  Future<int> delete(String id) {
    return (db.delete(db.groups)..where((row) => row.id.equals(id))).go();
  }
}

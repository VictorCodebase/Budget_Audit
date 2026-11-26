import 'package:ba_data/ba_data.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'sqlite_test_setup.dart';

void main() {
  setUpAll(configureSqliteTestLibrary);
  late AppDatabase database;

  setUp(() {
    database = AppDatabase();
  });

  tearDown(() => database.close());

  test('creates all v2 tables', () async {
    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final names = tables.map((row) => row.read<String>('name')).toSet();

    expect(
      names,
      containsAll({
        'groups',
        'categories',
        'vendors',
        'vendor_defaults',
        'transactions',
        'budgets',
        'budget_lines',
        'sync_state',
        'meta',
      }),
    );
  });

  test('source_ref is unique only for non-null values', () async {
    await database.customStatement(
      "INSERT INTO vendors (id, name, updated_at) "
      "VALUES ('vendor-1', 'Vendor', 100)",
    );
    await database.customStatement(
      "INSERT INTO categories "
      "(id, group_id, name, is_saving, color, archived_at, updated_at) "
      "VALUES ('category-1', NULL, 'Food', 0, '#111111', NULL, 100)",
    );
    await database.customStatement(
      "INSERT INTO transactions "
      "(id, date, vendor_id, category_id, amount_minor, note, source_ref, "
      "is_manual, deleted_at, updated_at) "
      "VALUES ('tx-1', 100, 'vendor-1', 'category-1', 500, '', 'receipt-1', "
      "0, NULL, 100)",
    );

    await expectLater(
      database.customStatement(
        "INSERT INTO transactions "
        "(id, date, vendor_id, category_id, amount_minor, note, source_ref, "
        "is_manual, deleted_at, updated_at) "
        "VALUES ('tx-2', 101, 'vendor-1', 'category-1', 600, '', 'receipt-1', "
        "0, NULL, 101)",
      ),
      throwsA(isA<SqliteException>()),
    );

    await database.customStatement(
      "INSERT INTO transactions "
      "(id, date, vendor_id, category_id, amount_minor, note, source_ref, "
      "is_manual, deleted_at, updated_at) "
      "VALUES ('tx-3', 102, 'vendor-1', 'category-1', 700, '', NULL, "
      "0, NULL, 102)",
    );
    await database.customStatement(
      "INSERT INTO transactions "
      "(id, date, vendor_id, category_id, amount_minor, note, source_ref, "
      "is_manual, deleted_at, updated_at) "
      "VALUES ('tx-4', 103, 'vendor-1', 'category-1', 800, '', NULL, "
      "0, NULL, 103)",
    );
  });

  test('foreign keys reject invalid category references', () async {
    final pragma = await database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(pragma.read<int>('foreign_keys'), 1);
    final ddl = await database
        .customSelect(
          "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'categories'",
        )
        .getSingle();
    expect(ddl.read<String>('sql'), contains('FOREIGN KEY'));

    await expectLater(
      database.customStatement(
        "INSERT INTO categories "
        "(id, group_id, name, is_saving, color, archived_at, updated_at) "
        "VALUES ('category-2', 'missing-group', 'Food', 0, '#111111', NULL, 100)",
      ),
      throwsA(isA<SqliteException>()),
    );
  });
}

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Groups,
  Categories,
  Vendors,
  VendorDefaults,
  Transactions,
  Budgets,
  BudgetLines,
  SyncState,
  Meta,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await customStatement(
          'CREATE TABLE groups ('
          'id TEXT PRIMARY KEY, name TEXT NOT NULL, sort INTEGER NOT NULL, '
          'color TEXT NOT NULL, archived_at INTEGER NULL, '
          'updated_at INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE TABLE categories ('
          'id TEXT PRIMARY KEY, group_id TEXT NULL, name TEXT NOT NULL, '
          'is_saving INTEGER NOT NULL CHECK (is_saving IN (0, 1)), '
          'color TEXT NOT NULL, archived_at INTEGER NULL, '
          'updated_at INTEGER NOT NULL, '
          'FOREIGN KEY (group_id) REFERENCES groups(id))',
        );
        await customStatement(
          'CREATE TABLE vendors ('
          'id TEXT PRIMARY KEY, name TEXT NOT NULL, updated_at INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE TABLE vendor_defaults ('
          'vendor_id TEXT PRIMARY KEY, category_id TEXT NOT NULL, '
          'use_count INTEGER NOT NULL, last_used INTEGER NOT NULL, '
          'updated_at INTEGER NOT NULL, '
          'FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE, '
          'FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE)',
        );
        await customStatement(
          'CREATE TABLE transactions ('
          'id TEXT PRIMARY KEY, date INTEGER NOT NULL, vendor_id TEXT NOT NULL, '
          'category_id TEXT NOT NULL, amount_minor INTEGER NOT NULL, '
          'note TEXT NOT NULL, source_ref TEXT NULL, is_manual INTEGER NOT NULL '
          'CHECK (is_manual IN (0, 1)), deleted_at INTEGER NULL, '
          'updated_at INTEGER NOT NULL, '
          'FOREIGN KEY (vendor_id) REFERENCES vendors(id), '
          'FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT)',
        );
        await customStatement(
          'CREATE TABLE budgets ('
          'id TEXT PRIMARY KEY, name TEXT NOT NULL, period TEXT NOT NULL, '
          'effective_from INTEGER NOT NULL, supersedes_id TEXT NULL, '
          'archived_at INTEGER NULL, updated_at INTEGER NOT NULL, '
          'FOREIGN KEY (supersedes_id) REFERENCES budgets(id))',
        );
        await customStatement(
          'CREATE TABLE budget_lines ('
          'budget_id TEXT NOT NULL, category_id TEXT NOT NULL, '
          'amount_minor INTEGER NOT NULL, PRIMARY KEY (budget_id, category_id), '
          'FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE, '
          'FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT)',
        );
        await customStatement(
          'CREATE TABLE sync_state ('
          'chunk_id TEXT PRIMARY KEY, base_version INTEGER NOT NULL, '
          'dirty INTEGER NOT NULL CHECK (dirty IN (0, 1)), '
          'last_synced INTEGER NULL)',
        );
        await customStatement(
          'CREATE TABLE meta ('
          'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS '
          'unique_transactions_source_ref '
          'ON transactions(source_ref) WHERE source_ref IS NOT NULL',
        );
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

import 'package:drift/drift.dart';

class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sort => integer()();
  TextColumn get color => text()();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'groups';
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().nullable().references(Groups, #id)();
  TextColumn get name => text()();
  BoolColumn get isSaving => boolean()();
  TextColumn get color => text()();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'categories';
}

class Vendors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'vendors';
}

class VendorDefaults extends Table {
  TextColumn get vendorId =>
      text().references(Vendors, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();
  IntColumn get useCount => integer()();
  IntColumn get lastUsed => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {vendorId};

  @override
  String get tableName => 'vendor_defaults';
}

class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get date => integer()();
  TextColumn get vendorId => text().references(Vendors, #id)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  IntColumn get amountMinor => integer()();
  TextColumn get note => text()();
  TextColumn get sourceRef => text().nullable()();
  BoolColumn get isManual => boolean()();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'transactions';
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get period => text()();
  IntColumn get effectiveFrom => integer()();
  TextColumn get supersedesId =>
      text().nullable().references(Budgets, #id)();
  IntColumn get archivedAt => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String get tableName => 'budgets';
}

class BudgetLines extends Table {
  TextColumn get budgetId =>
      text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  IntColumn get amountMinor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {budgetId, categoryId};

  @override
  String get tableName => 'budget_lines';
}

class SyncState extends Table {
  TextColumn get chunkId => text()();
  IntColumn get baseVersion => integer()();
  BoolColumn get dirty => boolean()();
  IntColumn get lastSynced => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {chunkId};

  @override
  String get tableName => 'sync_state';
}

class Meta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  String get tableName => 'meta';
}

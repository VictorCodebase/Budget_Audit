import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'dart:io';
import '../context.dart' as context;

//import '../models/models.dart';

part 'database.g.dart'; // generated db

@drift.DataClassName('Participant')
class Participants extends drift.Table {
  drift.IntColumn get participantId => integer().autoIncrement()();

  drift.TextColumn get firstName => text().withLength(min: 1, max: 255)();

  drift.TextColumn get lastName => text().withLength(max: 255).nullable()();

  drift.TextColumn get nickName => text().withLength(max: 100).nullable()();

  drift.TextColumn get role => text().withLength(min: 1, max: 255)();

  drift.TextColumn get email => text().withLength(min: 1, max: 255).unique()();

  drift.TextColumn get pwdhash => text().withLength(min: 60, max: 60)();

//@override
//Set<drift.Column> get primaryKey => {participantId};
}

@drift.DataClassName('Category')
class Categories extends drift.Table {
  drift.IntColumn get categoryId => integer().autoIncrement()();

  drift.IntColumn get templateId =>
      integer().references(Templates, #templateId)();

  drift.TextColumn get categoryName => text().withLength(min: 1, max: 100)();

  drift.TextColumn get colorHex => text().withLength(min: 7, max: 7)();

  @override
  List<Set<drift.Column>> get uniqueKeys => [
        {templateId, categoryName},
      ];
//@override
//Set<drift.Column> get primaryKey => {categoryId};
}

@drift.DataClassName('Template')
class Templates extends drift.Table {
  drift.IntColumn get templateId => integer().autoIncrement()();

  drift.IntColumn get syncId =>
      integer().nullable().references(SyncLog, #syncId)();

  drift.TextColumn get spreadSheetId =>
      text().withLength(max: 250).nullable()();

  drift.TextColumn get templateName => text().withLength(min: 1, max: 100)();

  drift.IntColumn get creatorParticipantId =>
      integer().references(Participants, #participantId)();

  drift.TextColumn get period => text().withLength(min: 1, max: 100)();

  drift.DateTimeColumn get dateCreated => dateTime()();

  drift.IntColumn get timesUsed => integer().nullable()();

//@override
//Set<drift.Column> get primaryKey => {templateId};
}

@drift.DataClassName('Account')
class Accounts extends drift.Table {
  drift.IntColumn get accountId => integer().autoIncrement()();

  drift.IntColumn get categoryId =>
      integer().references(Categories, #categoryId)();

  drift.IntColumn get templateId =>
      integer().references(Templates, #templateId)();

  drift.TextColumn get accountName => text().withLength(min: 1, max: 100)();

  drift.TextColumn get colorHex => text().withLength(min: 7, max: 7)();

  drift.RealColumn get budgetAmount => real()(); // Use real for DECIMAL(10, 2)
  drift.RealColumn get expenditureTotal =>
      real().withDefault(const drift.Constant(0.00)).nullable()();

  drift.IntColumn get responsibleParticipantId =>
      integer().references(Participants, #participantId).nullable()();

  drift.DateTimeColumn get dateCreated => dateTime()();

//@override
//Set<drift.Column> get primaryKey => {accountId};
}

@drift.DataClassName('Vendor')
class Vendors extends drift.Table {
  drift.IntColumn get vendorId => integer().autoIncrement()();

  drift.TextColumn get vendorName => text().withLength(min: 1, max: 250)();

//@override
//Set<drift.Column> get primaryKey => {vendorId};
}

// --- Junction/History/Log Tables ---

@drift.DataClassName('SyncLogEntry')
class SyncLog extends drift.Table {
  drift.IntColumn get syncId => integer().autoIncrement()();

  // Note: TransactionId is nullable here as it might be used for
  // template/other syncs, not just transactions.
  //drift.IntColumn get transactionId => integer().nullable().references(Transactions, #transactionId)();
  drift.TextColumn get syncDirection => text().withLength(min: 1, max: 100)();

  drift.BoolColumn get synced => boolean()();

  drift.BoolColumn get success => boolean()();

  drift.TextColumn get errorMessage => text().nullable()();

  drift.TextColumn get sheetUrl => text()();

  drift.DateTimeColumn get dateSynced => dateTime()();
//drift.IntColumn get associatedTemplate => integer().references(Templates, #templateId)();

//@override
//Set<drift.Column> get primaryKey => {syncId};
}

@drift.DataClassName('Transaction')
class Transactions extends drift.Table {
  drift.IntColumn get transactionId => integer().autoIncrement()();

  drift.IntColumn get syncId => integer().references(SyncLog, #syncId)();

  drift.IntColumn get accountId => integer().references(Accounts, #accountId)();

//! BEWARE: In as much as money in transactions are flagged as ignored, they dont get commited to DB because they are never presented to the user during transaction labelling with accounts (and eventually saved). As such, this can be used for other purposes.
  drift.BoolColumn get isIgnored =>
      boolean().withDefault(const drift.Constant(false))();

  drift.DateTimeColumn get date => dateTime()();

  drift.IntColumn get vendorId => integer().references(Vendors, #vendorId)();

  drift.RealColumn get amount => real()();

  @drift.ReferenceName('transactionOwner')
  drift.IntColumn get participantId =>
      integer().references(Participants, #participantId)();

  @drift.ReferenceName('transactionEditor')
  drift.IntColumn get editorParticipantId =>
      integer().references(Participants, #participantId)();

  drift.TextColumn get reason => text().nullable()();

//@override
//Set<drift.Column> get primaryKey => {transactionId};
}

@drift.DataClassName('VendorMatchHistory')
class VendorMatchHistories extends drift.Table {
  drift.IntColumn get vendorMatchId => integer().autoIncrement()();

  drift.IntColumn get vendorId => integer().references(Vendors, #vendorId)();

  drift.IntColumn get accountId => integer().references(Accounts, #accountId)();

  drift.IntColumn get participantId =>
      integer().references(Participants, #participantId)();

  drift.IntColumn get useCount =>
      integer().withDefault(const drift.Constant(1))();

  drift.DateTimeColumn get lastUsed => dateTime()();

  @override
  List<String> get customConstraints => [
        'UNIQUE (vendor_id, account_id, participant_id)',
      ];
}

@drift.DataClassName('VendorPreference')
class VendorPreferences extends drift.Table {
  drift.IntColumn get vendorPreferenceId => integer().autoIncrement()();

  drift.IntColumn get vendorId => integer().references(Vendors, #vendorId)();

  drift.IntColumn get participantId =>
      integer().references(Participants, #participantId)();

  //@override
  //Set<drift.Column> get primaryKey => {vendorPreferenceId};

  @override
  List<String> get customConstraints => [
        'UNIQUE (vendor_id, participant_id)',
      ];
}

@drift.DataClassName('ParticipantIncome')
class ParticipantIncomes extends drift.Table {
  drift.IntColumn get incomeId => integer().autoIncrement()();

  drift.IntColumn get participantId =>
      integer().references(Participants, #participantId)();

  drift.RealColumn get incomeAmount => real()();

  drift.TextColumn get incomeName => text().withLength(max: 100).nullable()();

  drift.TextColumn get incomeType => text().withLength(min: 1, max: 100)();

  drift.DateTimeColumn get dateReceived =>
      dateTime().clientDefault(() => DateTime.now())();

//@override
//Set<drift.Column> get primaryKey => {incomeId};
}

@drift.DataClassName('TemplateParticipant')
class TemplateParticipants extends drift.Table {
  drift.IntColumn get templateId =>
      integer().references(Templates, #templateId)();

  drift.IntColumn get participantId =>
      integer().references(Participants, #participantId)();

  drift.TextColumn get permissionRole => text().withLength(min: 1, max: 50)();

//@override
//Set<drift.Column> get primaryKey => {templateId, participantId};
}

@drift.DataClassName('ChartSnapshot')
class ChartSnapshots extends drift.Table {
  drift.IntColumn get snapshotId => integer().autoIncrement()();

  drift.TextColumn get name => text().withLength(max: 100).nullable()();

  drift.TextColumn get configuration =>
      text()(); // VAR CHAR will be a Dart String, which maps to TextColumn
  drift.DateTimeColumn get createdAt => dateTime()();

  drift.TextColumn get permissionRole => text().withLength(min: 1, max: 50)();

  drift.IntColumn get associatedTemplate =>
      integer().references(Templates, #templateId)();

//@override
//Set<drift.Column> get primaryKey => {snapshotId};
}

// --- Main Database Class ---

// Extend _$AppDatabase and reference all tables.
@drift.DriftDatabase(
  tables: [
    Participants,
    Categories,
    Accounts,
    Transactions,
    Templates,
    VendorMatchHistories,
    Vendors,
    VendorPreferences,
    ParticipantIncomes,
    TemplateParticipants,
    ChartSnapshots,
    SyncLog
  ],
)

class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    // Read the ENV variable from the loaded dotenv configuration.
    // Default to 'PRODUCTION' for safety if it's not set.
    final isProduction = context.AppContext()
        .isProduction; //TODO: Confirm that it actually recognizes the dev env

    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // This runs only when the database is first created (e.g., fresh install).
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (!isProduction) {
          print("Running DEVELOPMENT migration (deleting all data)...");
          // Use allTables instead of allTablesAndViews
          final allTableNames = allTables.map((e) => e.actualTableName);
          for (final table in allTableNames) {
            await m.deleteTable(table);
          }
          await m.createAll();
          return; // IMPORTANT: Exit here to avoid running production logic.
        }

        // --- BRANCH 2: PRODUCTION MIGRATION ---
        // This logic only runs if ENV is 'PRODUCTION'.
        // It performs a safe, step-by-step data-preserving migration.
        print("Running PRODUCTION migration (preserving data)...");
        for (var version = from; version < to; version++) {
          // Use a switch on the version we are migrating FROM.
          switch (version) {
            case 2: // Migrating from v2 to v3
              await m.addColumn(categories, categories.templateId);
              await customStatement(
                'UPDATE categories SET template_id = 1 WHERE template_id IS NULL',
              );
              break;
            case 3: // Migrating from v3 to v4
              await m.addColumn(accounts, accounts.accountName);

              await customStatement(
                'UPDATE accounts SET account_name = \'Unnamed Account\' WHERE account_name IS NULL',
              );
              break;

            case 4: // Migrating from v4 to v5
              // Use the alterTable function to apply the column change.
              // drift will automatically generate the ALTER TABLE statement
              // to make 'times_used' nullable.
              await m.alterTable(
                TableMigration(
                  templates,
                  columnTransformer: {
                    templates.timesUsed: templates.timesUsed,
                  },
                ),
              );
              await m.alterTable(TableMigration(categories));
              break;

            case 5:
              await m.renameTable(categories, 'categories_old');
              await m.createTable(categories);

              await customStatement('''
                INSERT INTO categories (category_id, template_id, category_name, color_hex)
                SELECT category_id, template_id, category_name, color_hex
                FROM categories_old
              ''');

              await m.deleteTable('categories_old');

              print("Migrated Categories to use composite unique keys.");
              break;

            case 6: // Migrating from v6 to v7
              // Drop the old table
              await m.deleteTable('transaction_edit_histories');
              // Create the new table
              await m.createTable(vendorMatchHistories);
              print(
                  "Replaced TransactionEditHistories with VendorMatchHistories.");
              break;

            case 7: // Migrating from v7 to v8
              await m.alterTable(
                TableMigration(
                  accounts,
                  columnTransformer: {
                    accounts.responsibleParticipantId:
                        accounts.responsibleParticipantId,
                  },
                ),
              );
              print(
                  "Migrated Accounts: responsibleParticipantId is now nullable.");
              break;

            case 8: // Migrating from v8 to v9
              await m.addColumn(templates, templates.period);
              print("Migrated Templates: Added 'period' column.");
              break;
          }
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys if you're using them. This is good practice.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

// Optional: Define DAOs here or in separate files
// (e.g., ParticipantDao, BudgetDao, etc.)
// @override
// List<DatabaseAccessor<AppDatabase>> get uses => [ParticipantDao, ...];
}

drift.LazyDatabase _openConnection() {
  return drift.LazyDatabase(() async {
    // Use a reliable application data directory
    final appSupportDir = await getApplicationSupportDirectory();
    final dbPath = p.join(appSupportDir.path, 'budget_audit', 'db.sqlite');

    // Ensure parent directory exists
    await Directory(p.dirname(dbPath)).create(recursive: true);

    // Optional: set SQLite temp directory
    if (Platform.isAndroid || Platform.isIOS) {
      final cacheBase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cacheBase;
    }

    //print("Opening DB at: $dbPath");
    return NativeDatabase.createInBackground(File(dbPath));
  });
}

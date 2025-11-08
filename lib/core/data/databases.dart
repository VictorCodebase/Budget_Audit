import  'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
//import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'dart:io';

//import '../models/models.dart';

part 'databases.g.dart'; // generated db

@drift.DataClassName('Participant')
class Participants extends drift.Table {
  drift.IntColumn get participantId => integer().autoIncrement()();
  drift.TextColumn get firstName => text().withLength(min: 1, max: 255)();
  drift.TextColumn get lastName => text().withLength(max: 255).nullable()();
  drift.TextColumn get nickName => text().withLength(max: 100).nullable()();
  drift.TextColumn get role => text().withLength(min: 1, max: 255)();
  drift.TextColumn get email => text().withLength(min: 1, max: 255).unique()();
  drift.TextColumn get pwdhash => text().withLength(min: 60, max: 60)(); //TODO: Ensure the hashing algorithm gets the correct char length

  //@override
  //Set<drift.Column> get primaryKey => {participantId};
}

@drift.DataClassName('Category')
class Categories extends drift.Table {
  drift.IntColumn get categoryId => integer().autoIncrement()();
  drift.TextColumn get categoryName => text().withLength(min: 1, max: 100).unique()();
  drift.TextColumn get colorHex => text().withLength(min: 7, max: 7)();

  //@override
  //Set<drift.Column> get primaryKey => {categoryId};
}

@drift.DataClassName('Template')
class Templates extends drift.Table {
  drift.IntColumn get templateId => integer().autoIncrement()();
  drift.IntColumn get syncId => integer().nullable().references(SyncLog, #syncId)();
  drift.TextColumn get spreadSheetId => text().withLength(max: 250).nullable()();
  drift.TextColumn get templateName => text().withLength(min: 1, max: 100)();
  drift.IntColumn get creatorParticipantId => integer().references(Participants, #participantId)();
  drift.DateTimeColumn get dateCreated => dateTime()();
  drift.IntColumn get timesUsed => integer()();

  //@override
  //Set<drift.Column> get primaryKey => {templateId};
}

@drift.DataClassName('Account')
class Accounts extends drift.Table {
  drift.IntColumn get accountId => integer().autoIncrement()();
  drift.IntColumn get categoryId => integer().references(Categories, #categoryId)();
  drift.IntColumn get templateId => integer().references(Templates, #templateId)();
  drift.TextColumn get colorHex => text().withLength(min: 7, max: 7)();
  drift.RealColumn get budgetAmount => real()(); // Use real for DECIMAL(10, 2)
  drift.RealColumn get expenditureTotal => real().withDefault(const drift.Constant(0.00)).nullable()();
  drift.IntColumn get responsibleParticipantId => integer().references(Participants, #participantId)();
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
  //drift.IntColumn get associatedTemplate => integer().references(Templates, #templateId)();

  //@override
  //Set<drift.Column> get primaryKey => {syncId};
}

@drift.DataClassName('Transaction')
class Transactions extends drift.Table {
  drift.IntColumn get transactionId => integer().autoIncrement()();
  drift.IntColumn get syncId => integer().references(SyncLog, #syncId)();
  drift.IntColumn get accountId => integer().references(Accounts, #accountId)();
  drift.BoolColumn get isIgnored => boolean().withDefault(const drift.Constant(false))();
  drift.DateTimeColumn get date => dateTime()();
  drift.IntColumn get vendorId => integer().references(Vendors, #vendorId)();
  drift.RealColumn get amount => real()();

  @drift.ReferenceName('transactionOwner')
  drift.IntColumn get participantId => integer().references(Participants, #participantId)();

  @drift.ReferenceName('transactionEditor')
  drift.IntColumn get editorParticipantId => integer().references(Participants, #participantId)();
  drift.TextColumn get reason => text().nullable()();

  //@override
//Set<drift.Column> get primaryKey => {transactionId};
}

@drift.DataClassName('TransactionEditHistory')
class TransactionEditHistories extends drift.Table {
  drift.IntColumn get transactionEditId => integer().autoIncrement()();
  drift.IntColumn get editorParticipantId => integer().references(Participants, #participantId)();
  drift.IntColumn get transactionId => integer().references(Transactions, #transactionId)();
  drift.TextColumn get editedField => text().withLength(min: 1, max: 100)();
  drift.TextColumn get originalValue => text().withLength(min: 1, max: 250)();
  drift.TextColumn get newValue => text().withLength(min: 1, max: 250)();
  drift.DateTimeColumn get timeStamp => dateTime()();

  //@override
//Set<drift.Column> get primaryKey => {transactionEditId};
}

@drift.DataClassName('VendorPreference')
class VendorPreferences extends drift.Table {
  drift.IntColumn get vendorPreferenceId => integer().autoIncrement()();
  drift.IntColumn get vendorId => integer().references(Vendors, #vendorId)();
  drift.IntColumn get participantId => integer().references(Participants, #participantId)();

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
  drift.IntColumn get participantId => integer().references(Participants, #participantId)();
  drift.RealColumn get incomeAmount => real()();
  drift.TextColumn get incomeName => text().withLength(max: 100).nullable()();
  drift.TextColumn get incomeType => text().withLength(min: 1, max: 100)();
  drift.DateTimeColumn get dateReceived => dateTime().clientDefault(() => DateTime.now())();

  //@override
//Set<drift.Column> get primaryKey => {incomeId};
}

@drift.DataClassName('TemplateParticipant')
class TemplateParticipants extends drift.Table {
  drift.IntColumn get templateId => integer().references(Templates, #templateId)();
  drift.IntColumn get participantId => integer().references(Participants, #participantId)();
  drift.TextColumn get permissionRole => text().withLength(min: 1, max: 50)();

//@override
//Set<drift.Column> get primaryKey => {templateId, participantId};
}

@drift.DataClassName('ChartSnapshot')
class ChartSnapshots extends drift.Table {
  drift.IntColumn get snapshotId => integer().autoIncrement()();
  drift.TextColumn get name => text().withLength(max: 100).nullable()();
  drift.TextColumn get configuration => text()(); // VAR CHAR will be a Dart String, which maps to TextColumn
  drift.DateTimeColumn get createdAt => dateTime()();
  drift.TextColumn get permissionRole => text().withLength(min: 1, max: 50)();
  drift.IntColumn get associatedTemplate => integer().references(Templates, #templateId)();

  //@override
//Set<drift.Column> get primaryKey => {snapshotId};
}

// --- Main Database Class ---

// Extend _$AppDatabase and reference all tables.
@drift.DriftDatabase(
  tables: [
    Participants, Categories, Accounts, Transactions, Templates,
    TransactionEditHistories, Vendors, VendorPreferences, ParticipantIncomes,
    TemplateParticipants, ChartSnapshots, SyncLog
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; //TODO: Increment this for migrations.

// Optional: Define DAOs here or in separate files
// (e.g., ParticipantDao, BudgetDao, etc.)
// @override
// List<DatabaseAccessor<AppDatabase>> get uses => [ParticipantDao, ...];
}

// Boilerplate to open the database on Flutter platforms
drift.LazyDatabase _openConnection() {
  return drift.LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // For better performance and features on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      // Ensure the sqlite3 library is loaded
      // This part depends on having the sqlite3_flutter_libs package
      // install: flutter pub add sqlite3_flutter_libs
      // await installOnWindows(); // If you need Windows support

      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;
    }
    return NativeDatabase.createInBackground(file);
  });
}
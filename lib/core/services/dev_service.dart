import 'package:budget_audit/core/data/databases.dart';
import 'package:budget_audit/core/context.dart';
import 'package:budget_audit/core/services/service_locator.dart';

class DevService {
  final AppDatabase _db;
  final AppContext _context;

  DevService(this._db, this._context);

  /// Delete EVERY table and recreate them fresh
  Future<void> resetAllTables() async {
    final executor = _db.createMigrator();

    for (final table in _db.allTables) {
      await executor.deleteTable(table.actualTableName);
    }
    await executor.createAll();
  }

  /// Delete a single table (and recreate empty)
  Future<void> resetSingleTable(String tableName) async {
    final executor = _db.createMigrator();
    await executor.deleteTable(tableName);
    await executor.createAll();
  }

  /// Delete all records inside a table
  Future<void> clearTableRecords(String tableName) async {
    await _db.customStatement("DELETE FROM $tableName");
  }

  /// Logs entire table content as a list of rows (Map<String, dynamic>)
  Future<List<Map<String, Object?>>> getTableDump(String tableName) async {
    final result = await _db.customSelect("SELECT * FROM $tableName").get();
    return result.map((r) => r.data).toList();
  }

  /// Dump ALL application context
  Map<String, dynamic> dumpContext() {
    return {
      "hasValidSession": _context.hasValidSession,
      "activeParticipant": _context.currentParticipant,
      "activeTemplate": _context.currentTemplate,
      "activeDisplayName": _context.currentParticipantDisplayName,
    };
  }

  /// List all table names
  List<String> listTables() =>
      _db.allTables.map((t) => t.actualTableName).toList();
}

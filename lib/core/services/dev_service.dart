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
    try {
      // Find the table info object that matches the requested name
      final table = _db.allTables.firstWhere(
        (t) => t.actualTableName == tableName,
        orElse: () => throw Exception("Table $tableName not found"),
      );

      // Use Drift's select API which is safer and returns typed data classes
      final result = await _db.select(table).get();

      // Convert data classes to JSON maps
      // Drift generated classes have a toJson() method
      return result
          .map((row) => (row as dynamic).toJson() as Map<String, Object?>)
          .toList();
    } catch (e) {
      print("Error dumping table $tableName: $e");
      return [];
    }
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

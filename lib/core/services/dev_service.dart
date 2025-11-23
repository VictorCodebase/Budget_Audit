import 'package:budget_audit/core/data/database.dart';
import 'package:budget_audit/core/context.dart';
import 'package:budget_audit/core/services/service_locator.dart';

class DevService {
  final AppDatabase _db;
  final AppContext _context;

  DevService(this._db, this._context);

  /// Delete EVERY table and recreate them fresh
  Future<void> resetAllTables() async {
    try {
      // Disable foreign keys to allow dropping tables in any order
      await _db.customStatement('PRAGMA foreign_keys = OFF');

      final executor = _db.createMigrator();

      for (final table in _db.allTables) {
        await executor.deleteTable(table.actualTableName);
      }
      await executor.createAll();
    } catch (e) {
      print("Error resetting tables: $e");
    } finally {
      // Re-enable foreign keys
      try {
        await _db.customStatement('PRAGMA foreign_keys = ON');
        print("Database tables reset and pragma keys re-enabled");
      } catch (e) {
        print("Error re-enabling foreign keys: $e");
      }
    }
  }

  /// Delete a single table (and recreate empty)
  Future<void> resetSingleTable(String tableName) async {
    try {
      final executor = _db.createMigrator();
      await executor.deleteTable(tableName);
      await executor.createAll();
    } catch (e) {
      print("Error resetting table $tableName: $e");
    }
  }

  /// Delete all records inside a table
  Future<void> clearTableRecords(String tableName) async {
    try {
      await _db.customStatement("DELETE FROM $tableName");
    } catch (e) {
      print("Error clearing table $tableName: $e");
    }
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
      "activeParticipantName": _context.currentParticipantDisplayName,
      "activeTemplate": _context.currentTemplate,
      "activeDisplayName": _context.currentParticipantDisplayName,
    };
  }

  /// List all table names
  List<String> listTables() =>
      _db.allTables.map((t) => t.actualTableName).toList();
}

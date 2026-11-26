import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../schema/database.dart';

class V1MigrationResult {
  const V1MigrationResult({
    required this.groups,
    required this.categories,
    required this.budgets,
    required this.budgetLines,
    required this.transactions,
    required this.vendors,
    required this.vendorDefaults,
    required this.collapsedTransactions,
  });

  final int groups;
  final int categories;
  final int budgets;
  final int budgetLines;
  final int transactions;
  final int vendors;
  final int vendorDefaults;
  final int collapsedTransactions;
}

class V1Migrator {
  V1Migrator(this.destination);

  final AppDatabase destination;

  static String v1DatabasePath(String applicationSupportDirectory) {
    final separator = applicationSupportDirectory.contains('\\') ? '\\' : '/';
    final root = applicationSupportDirectory.replaceAll(RegExp(r'[\\/]$'), '');
    return '$root${separator}budget_audit${separator}db.sqlite';
  }

  Future<V1MigrationResult> migrate(String v1DatabasePath) async {
    final v1 = sqlite3.open(v1DatabasePath, mode: OpenMode.readOnly);
    try {
      final counts = V1MigrationResult(
        groups: await _migrateGroups(v1),
        categories: await _migrateCategories(v1),
        budgets: await _migrateBudgets(v1),
        budgetLines: await _migrateBudgetLines(v1),
        transactions: await _migrateTransactions(v1),
        vendors: await _migrateVendors(v1),
        vendorDefaults: await _migrateVendorDefaults(v1),
        collapsedTransactions: await _countCollapsedTransactions(v1),
      );
      await destination
          .into(destination.meta)
          .insert(
            MetaCompanion.insert(key: 'v1_migrated', value: 'true'),
            mode: InsertMode.insertOrReplace,
          );
      await destination
          .into(destination.meta)
          .insert(
            MetaCompanion.insert(
              key: 'v1_collapsed_transaction_count',
              value: counts.collapsedTransactions.toString(),
            ),
            mode: InsertMode.insertOrReplace,
          );
      return counts;
    } finally {
      v1.dispose();
    }
  }

  bool _tableExists(Database db, String tableName) {
    final result = db.select(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  Future<int> _migrateGroups(Database v1) async {
    if (!_tableExists(v1, 'categories')) return 0;
    final rows = v1.select(
      'SELECT category_id, category_name, color_hex FROM categories',
    );
    var count = 0;
    for (final row in rows) {
      final id = _uuid('group:${row['category_id']}');
      final updatedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
      final inserted = await destination
          .into(destination.groups)
          .insert(
            GroupsCompanion.insert(
              id: id,
              name: _text(row['category_name'], 'Category'),
              sort: count,
              color: _text(row['color_hex'], '#777777'),
              updatedAt: updatedAt,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
    }
    return count;
  }

  String _groupId(Object? categoryId) => _uuid('group:$categoryId');

  String _categoryId(Object? accountId) => _uuid('category:$accountId');

  Future<int> _migrateCategories(Database v1) async {
    if (!_tableExists(v1, 'accounts')) return 0;
    final hasCategoryId = v1
        .select("PRAGMA table_info(accounts)")
        .any((row) => row['name'] == 'category_id');
    if (!hasCategoryId) return 0;

    final rows = v1.select(
      'SELECT account_id, category_id, account_name, color_hex, date_created '
      'FROM accounts',
    );
    var count = 0;
    final seenNames = <String>{};
    for (final row in rows) {
      final accountId = row['account_id'];
      final name = _text(row['account_name'], 'Category');
      final groupId = _groupId(row['category_id']);
      final dedupeKey = '${groupId.toLowerCase()}:${name.toLowerCase().trim()}';
      if (!seenNames.add(dedupeKey)) continue;

      final inserted = await destination
          .into(destination.categories)
          .insert(
            CategoriesCompanion.insert(
              id: _categoryId(accountId),
              groupId: Value(groupId),
              name: name,
              isSaving: false,
              color: _text(row['color_hex'], '#777777'),
              updatedAt: _epochMillis(row['date_created']),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
    }
    return count;
  }

  Future<int> _migrateBudgets(Database v1) async {
    if (!_tableExists(v1, 'templates')) return 0;
    final rows = v1.select(
      'SELECT template_id, template_name, period, date_created '
      'FROM templates ORDER BY date_created ASC, template_id ASC',
    );
    var count = 0;
    String? previousId;
    for (final row in rows) {
      final sourceId = row['template_id'];
      final id = _uuid('budget:$sourceId');
      final effectiveFrom = _epochMillis(row['date_created']);
      final inserted = await destination
          .into(destination.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: id,
              name: _text(row['template_name'], 'Budget'),
              period: _text(row['period'], 'monthly'),
              effectiveFrom: effectiveFrom,
              supersedesId: previousId == null
                  ? const Value.absent()
                  : Value(previousId),
              updatedAt: effectiveFrom,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
      previousId = id;
    }
    return count;
  }

  Future<int> _migrateBudgetLines(Database v1) async {
    if (!_tableExists(v1, 'accounts') || !_tableExists(v1, 'templates')) {
      return 0;
    }
    final rows = v1.select(
      'SELECT template_id, account_id, category_id, budget_amount '
      'FROM accounts',
    );
    var count = 0;
    for (final row in rows) {
      final budgetId = _uuid('budget:${row['template_id']}');
      final categoryId = _categoryId(row['account_id']);
      final amountMinor = _roundMoneyMinor(row['budget_amount']);
      final inserted = await destination
          .into(destination.budgetLines)
          .insert(
            BudgetLinesCompanion.insert(
              budgetId: budgetId,
              categoryId: categoryId,
              amountMinor: amountMinor,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
    }
    return count;
  }

  Future<int> _migrateVendors(Database v1) async {
    if (!_tableExists(v1, 'vendors')) return 0;
    final rows = v1.select('SELECT vendor_id, vendor_name FROM vendors');
    var count = 0;
    for (final row in rows) {
      final updatedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
      final inserted = await destination
          .into(destination.vendors)
          .insert(
            VendorsCompanion.insert(
              id: _uuid('vendor:${row['vendor_id']}'),
              name: _text(row['vendor_name'], 'Vendor'),
              updatedAt: updatedAt,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
    }
    return count;
  }

  Future<int> _migrateTransactions(Database v1) async {
    if (!_tableExists(v1, 'transactions')) return 0;
    final rows = v1.select(
      'SELECT transaction_id, account_id, vendor_id, date, amount '
      'FROM transactions WHERE COALESCE(is_ignored, 0) = 0',
    );
    var count = 0;
    for (final row in rows) {
      final accountId = row['account_id'];
      final vendorId = row['vendor_id'];
      if (accountId == null || vendorId == null) continue;
      final inserted = await destination
          .into(destination.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: _uuid('transaction:${row['transaction_id']}'),
              date: _epochMillis(row['date']),
              vendorId: _uuid('vendor:$vendorId'),
              categoryId: _categoryId(accountId),
              amountMinor: _roundMoneyMinor(row['amount']),
              note: '',
              isManual: false,
              updatedAt: _epochMillis(row['date']),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
    }
    return count;
  }

  Future<int> _migrateVendorDefaults(Database v1) async {
    if (!_tableExists(v1, 'vendor_match_histories')) return 0;
    final rows = v1.select(
      'SELECT vendor_id, account_id, use_count, last_used '
      'FROM vendor_match_histories '
      'ORDER BY vendor_id ASC, use_count DESC, last_used DESC',
    );
    var count = 0;
    final seen = <String>{};
    for (final row in rows) {
      final vendorId = _uuid('vendor:${row['vendor_id']}');
      if (!seen.add(vendorId)) continue;
      final usedAt = _epochMillis(row['last_used']);
      final useCount = (row['use_count'] as num?)?.toInt() ?? 1;
      final inserted = await destination
          .into(destination.vendorDefaults)
          .insert(
            VendorDefaultsCompanion.insert(
              vendorId: vendorId,
              categoryId: _categoryId(row['account_id']),
              useCount: useCount,
              lastUsed: usedAt,
              updatedAt: usedAt,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted > 0) count++;
    }
    return count;
  }

  Future<int> _countCollapsedTransactions(Database v1) async {
    if (!_tableExists(v1, 'transactions') ||
        !_tableExists(v1, 'participants')) {
      return 0;
    }
    final owner = v1.select(
      "SELECT participant_id FROM participants "
      "WHERE LOWER(COALESCE(role, '')) LIKE '%owner%' "
      "ORDER BY participant_id ASC LIMIT 1",
    );
    final ownerId = owner.isEmpty ? null : owner.first['participant_id'];
    if (ownerId == null) return 0;
    final result = v1.select(
      'SELECT COUNT(*) AS count FROM transactions '
      'WHERE participant_id != ?',
      [ownerId],
    );
    return (result.first['count'] as num).toInt();
  }

  int _roundMoneyMinor(Object? value) {
    final amount = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '0') ?? 0;
    return (amount * 100).round();
  }

  int _epochMillis(Object? value) {
    if (value is int) {
      return value < 100000000000 ? value * 1000 : value;
    }
    if (value is double) {
      final millis = value.toInt();
      return millis < 100000000000 ? millis * 1000 : millis;
    }
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return 0;
    }
    final parsedInt = int.tryParse(text);
    if (parsedInt != null) {
      return parsedInt < 100000000000 ? parsedInt * 1000 : parsedInt;
    }
    return DateTime.tryParse(text)?.toUtc().millisecondsSinceEpoch ?? 0;
  }

  String _text(Object? value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _uuid(String key) {
    var hash1 = 0x811c9dc5;
    var hash2 = 0x01000193;
    for (final byte in utf8.encode(key)) {
      hash1 = ((hash1 ^ byte) * 16777619) & 0xffffffff;
      hash2 = ((hash2 ^ byte) * 0x01000193) & 0xffffffff;
    }
    var value = '$hash1:$hash2:$key';
    for (var i = 0; i < 4; i++) {
      var hash = 0x811c9dc5 ^ i;
      for (final byte in utf8.encode(value)) {
        hash = ((hash ^ byte) * 16777619) & 0xffffffff;
      }
      value += ':$hash';
    }
    final hex = value.codeUnits
        .map((unit) => unit.toRadixString(16).padLeft(2, '0'))
        .join();
    final padded = hex.padRight(32, '0').substring(0, 32);
    final chars = padded.split('');
    chars[12] = '4';
    chars[16] = ((int.parse(chars[16], radix: 16) & 0x3) | 0x8).toRadixString(
      16,
    );
    final uuid = chars.join();
    return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-'
        '${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-'
        '${uuid.substring(20)}';
  }
}

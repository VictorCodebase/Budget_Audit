import 'package:drift/drift.dart';

import '../schema/database.dart';

class BudgetsDao {
  BudgetsDao(this.db);

  final AppDatabase db;

  Future<void> create({
    required String id,
    required String name,
    required String period,
    required int effectiveFrom,
    String? supersedesId,
    required int updatedAt,
    required Map<String, int> categoryAmountsMinor,
  }) {
    return db.transaction(() async {
      await db
          .into(db.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: id,
              name: name,
              period: period,
              effectiveFrom: effectiveFrom,
              supersedesId: supersedesId == null
                  ? const Value.absent()
                  : Value(supersedesId),
              updatedAt: updatedAt,
            ),
          );
      for (final entry in categoryAmountsMinor.entries) {
        await db
            .into(db.budgetLines)
            .insert(
              BudgetLinesCompanion.insert(
                budgetId: id,
                categoryId: entry.key,
                amountMinor: entry.value,
              ),
            );
      }
    });
  }

  Future<List<Budget>> all() {
    return db.select(db.budgets).get();
  }

  Future<Budget?> getById(String id) {
    return (db.select(
      db.budgets,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<List<BudgetLine>> linesFor(String budgetId) {
    return (db.select(
      db.budgetLines,
    )..where((row) => row.budgetId.equals(budgetId))).get();
  }
}

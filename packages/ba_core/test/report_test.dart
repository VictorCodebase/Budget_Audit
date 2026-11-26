import 'package:ba_core/ba_core.dart';
import 'package:test/test.dart';

void main() {
  group('BudgetResolver', () {
    test('uses the latest non-archived budget effective on or before date', () {
      final resolver = BudgetResolver();
      final old = BudgetVersion(
        id: 'old',
        effectiveFrom: DateTime.utc(2026, 1),
        lines: const [],
      );
      final newVersion = BudgetVersion(
        id: 'new',
        effectiveFrom: DateTime.utc(2026, 4),
        lines: const [],
      );
      final archived = BudgetVersion(
        id: 'archived',
        effectiveFrom: DateTime.utc(2026, 5),
        archived: true,
        lines: const [],
      );

      expect(
        resolver.resolve(
          date: DateTime.utc(2026, 4, 15),
          budgets: [old, newVersion, archived],
        ),
        same(newVersion),
      );
    });
  });

  group('ReportBuilder', () {
    const category = ReportCategory(id: 'food', name: 'Food', isSaving: false);
    const saving = ReportCategory(
      id: 'savings',
      name: 'Emergency fund',
      isSaving: true,
    );
    const archived = ReportCategory(
      id: 'old',
      name: 'Old category',
      isSaving: false,
      archived: true,
    );

    test('reports unbudgeted spend and set aside separately', () {
      final report = ReportBuilder().build(
        start: DateTime.utc(2026, 1),
        end: DateTime.utc(2026, 1, 31),
        categories: const [category, saving, archived],
        budgets: [
          BudgetVersion(
            id: 'budget',
            effectiveFrom: DateTime.utc(2026, 1),
            lines: const [
              ReportBudgetLine(categoryId: 'food', amountMinor: 10000),
            ],
          ),
        ],
        transactions: [
          ReportTransaction(
            id: '1',
            date: DateTime.utc(2026, 1, 5),
            categoryId: 'food',
            amountMinor: 4000,
          ),
          ReportTransaction(
            id: '2',
            date: DateTime.utc(2026, 1, 6),
            categoryId: 'old',
            amountMinor: 2500,
          ),
          ReportTransaction(
            id: '3',
            date: DateTime.utc(2026, 1, 7),
            categoryId: 'savings',
            amountMinor: 3000,
          ),
        ],
      );

      expect(report.spentMinor, 6500);
      expect(report.setAsideMinor, 3000);
      expect(report.budgetMinor, 10000);
      expect(report.remainingMinor, 3500);
      expect(report.unbudgetedSpendMinor, 2500);
    });

    test('uses the budget version active for each transaction', () {
      final report = ReportBuilder().build(
        start: DateTime.utc(2026, 1),
        end: DateTime.utc(2026, 3, 31),
        categories: const [category],
        budgets: [
          BudgetVersion(
            id: 'old-budget',
            effectiveFrom: DateTime.utc(2026, 1),
            lines: const [
              ReportBudgetLine(categoryId: 'food', amountMinor: 10000),
            ],
          ),
          BudgetVersion(
            id: 'new-budget',
            effectiveFrom: DateTime.utc(2026, 2),
            lines: const [],
          ),
        ],
        transactions: [
          ReportTransaction(
            id: '1',
            date: DateTime.utc(2026, 1, 15),
            categoryId: 'food',
            amountMinor: 2000,
          ),
          ReportTransaction(
            id: '2',
            date: DateTime.utc(2026, 2, 15),
            categoryId: 'food',
            amountMinor: 3000,
          ),
        ],
      );

      expect(report.unbudgetedSpendMinor, 3000);
      expect(report.spentMinor, 5000);
    });

    test('keeps archived category spend in the report', () {
      final report = ReportBuilder().build(
        start: DateTime.utc(2026, 1),
        end: DateTime.utc(2026, 1, 31),
        categories: const [archived],
        budgets: const [],
        transactions: [
          ReportTransaction(
            id: '1',
            date: DateTime.utc(2026, 1, 10),
            categoryId: 'old',
            amountMinor: 1250,
          ),
        ],
      );

      expect(report.spentMinor, 1250);
      expect(report.unbudgetedSpendMinor, 1250);
      expect(report.categories.single.category.archived, isTrue);
    });
  });
}

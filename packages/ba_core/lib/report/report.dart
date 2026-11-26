class ReportCategory {
  final String id;
  final String name;
  final String? groupId;
  final bool isSaving;
  final bool archived;

  const ReportCategory({
    required this.id,
    required this.name,
    this.groupId,
    required this.isSaving,
    this.archived = false,
  });
}

class ReportBudgetLine {
  final String categoryId;
  final int amountMinor;

  const ReportBudgetLine({required this.categoryId, required this.amountMinor});
}

class BudgetVersion {
  final String id;
  final DateTime effectiveFrom;
  final bool archived;
  final List<ReportBudgetLine> lines;

  const BudgetVersion({
    required this.id,
    required this.effectiveFrom,
    this.archived = false,
    required this.lines,
  });
}

class ReportTransaction {
  final String id;
  final DateTime date;
  final String categoryId;
  final int amountMinor;
  final bool deleted;

  const ReportTransaction({
    required this.id,
    required this.date,
    required this.categoryId,
    required this.amountMinor,
    this.deleted = false,
  });
}

class CategoryReport {
  final ReportCategory category;
  final int budgetMinor;
  final int spentMinor;
  final int setAsideMinor;
  final int remainingMinor;

  const CategoryReport({
    required this.category,
    required this.budgetMinor,
    required this.spentMinor,
    required this.setAsideMinor,
    required this.remainingMinor,
  });

  bool get isUnbudgeted =>
      !category.isSaving && budgetMinor == 0 && spentMinor > 0;
}

class Report {
  final DateTime start;
  final DateTime end;
  final int spentMinor;
  final int setAsideMinor;
  final int budgetMinor;
  final int remainingMinor;
  final int unbudgetedSpendMinor;
  final List<CategoryReport> categories;

  const Report({
    required this.start,
    required this.end,
    required this.spentMinor,
    required this.setAsideMinor,
    required this.budgetMinor,
    required this.remainingMinor,
    required this.unbudgetedSpendMinor,
    required this.categories,
  });
}

class BudgetResolver {
  const BudgetResolver();

  BudgetVersion? resolve({
    required DateTime date,
    required List<BudgetVersion> budgets,
  }) {
    BudgetVersion? resolved;
    for (final budget in budgets) {
      if (budget.archived) {
        continue;
      }
      if (budget.effectiveFrom.isAfter(date)) {
        continue;
      }
      if (resolved == null ||
          budget.effectiveFrom.isAfter(resolved.effectiveFrom)) {
        resolved = budget;
      }
    }
    return resolved;
  }

  BudgetVersion? resolveForDate(DateTime date, List<BudgetVersion> budgets) {
    return resolve(date: date, budgets: budgets);
  }
}

class ReportBuilder {
  const ReportBuilder({this.resolver = const BudgetResolver()});

  final BudgetResolver resolver;

  Report build({
    required DateTime start,
    required DateTime end,
    required List<ReportCategory> categories,
    required List<BudgetVersion> budgets,
    required List<ReportTransaction> transactions,
  }) {
    final activeAtEnd = resolver.resolve(date: end, budgets: budgets);
    final budgetAtEnd = activeAtEnd?.lines ?? const <ReportBudgetLine>[];
    final endBudgetByCategory = <String, int>{
      for (final line in budgetAtEnd) line.categoryId: line.amountMinor,
    };

    final spentByCategory = <String, int>{};
    final setAsideByCategory = <String, int>{};
    var spent = 0;
    var setAside = 0;
    var unbudgeted = 0;

    for (final transaction in transactions) {
      if (transaction.deleted ||
          transaction.date.isBefore(start) ||
          transaction.date.isAfter(end)) {
        continue;
      }

      final category = categories
          .where((item) => item.id == transaction.categoryId)
          .cast<ReportCategory?>()
          .firstWhere((item) => item != null, orElse: () => null);
      if (category == null) {
        continue;
      }

      if (category.isSaving) {
        setAsideByCategory.update(
          category.id,
          (value) => value + transaction.amountMinor,
          ifAbsent: () => transaction.amountMinor,
        );
        setAside += transaction.amountMinor;
        continue;
      }

      spentByCategory.update(
        category.id,
        (value) => value + transaction.amountMinor,
        ifAbsent: () => transaction.amountMinor,
      );
      spent += transaction.amountMinor;

      final activeAtTransaction = resolver.resolve(
        date: transaction.date,
        budgets: budgets,
      );
      final hasBudget =
          activeAtTransaction?.lines.any(
            (line) => line.categoryId == category.id && line.amountMinor > 0,
          ) ??
          false;
      if (!hasBudget) {
        unbudgeted += transaction.amountMinor;
      }
    }

    final categoryIds = <String>{
      ...categories.map((category) => category.id),
      ...endBudgetByCategory.keys,
      ...spentByCategory.keys,
      ...setAsideByCategory.keys,
    };
    final categoryReports = <CategoryReport>[];
    var totalBudget = 0;

    for (final categoryId in categoryIds) {
      final category = categories
          .where((item) => item.id == categoryId)
          .cast<ReportCategory?>()
          .firstWhere((item) => item != null, orElse: () => null);
      if (category == null) {
        continue;
      }
      final categoryBudget = endBudgetByCategory[categoryId] ?? 0;
      if (!category.isSaving) {
        totalBudget += categoryBudget;
      }
      final categorySpent = spentByCategory[categoryId] ?? 0;
      final categorySetAside = setAsideByCategory[categoryId] ?? 0;
      categoryReports.add(
        CategoryReport(
          category: category,
          budgetMinor: categoryBudget,
          spentMinor: categorySpent,
          setAsideMinor: categorySetAside,
          remainingMinor: categoryBudget - categorySpent,
        ),
      );
    }
    categoryReports.sort((a, b) => a.category.name.compareTo(b.category.name));

    return Report(
      start: start,
      end: end,
      spentMinor: spent,
      setAsideMinor: setAside,
      budgetMinor: totalBudget,
      remainingMinor: totalBudget - spent,
      unbudgetedSpendMinor: unbudgeted,
      categories: categoryReports,
    );
  }
}

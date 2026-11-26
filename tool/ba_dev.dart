import 'dart:ffi';
import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:ba_data/ba_data.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

void main(List<String> arguments) {
  _configureSqlite();
  final fixture = File(
    arguments.isNotEmpty
        ? arguments[0]
        : 'test/fixtures/MPESA_Statement_2026-07-01_to_2026-07-18.csv',
  );
  final ruleFile = File(
    arguments.length > 1 ? arguments[1] : 'assets/rules/csv_generic.json',
  );

  () async {
    if (!await fixture.exists()) {
      stderr.writeln('Fixture not found: ${fixture.path}');
      exitCode = 1;
      return;
    }
    if (!await ruleFile.exists()) {
      stderr.writeln('Rule not found: ${ruleFile.path}');
      exitCode = 1;
      return;
    }

    final temp = await Directory.systemTemp.createTemp('budget_audit_v2_');
    final dbFile = File('${temp.path}/budget_audit_v2.sqlite');
    final database = AppDatabase(NativeDatabase(dbFile));
    try {
      const now = 1782864000000;
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'dev-category',
              name: 'Daily spending',
              isSaving: false,
              color: '#111111',
              updatedAt: now,
            ),
          );
      await database
          .into(database.budgets)
          .insert(
            BudgetsCompanion.insert(
              id: 'dev-budget',
              name: 'Development budget',
              period: 'month',
              effectiveFrom: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.budgetLines)
          .insert(
            BudgetLinesCompanion.insert(
              budgetId: 'dev-budget',
              categoryId: 'dev-category',
              amountMinor: 100000,
            ),
          );

      final rule = const RuleLoader().loadString(await ruleFile.readAsString());
      final document = const CsvExtractor().extractFile(fixture);
      final execution = const RuleEngine().interpretCsv(rule, document);
      final reconciliation = const Reconciler().reconcile(execution.rows);

      var importedCount = 0;
      var duplicateCount = 0;
      for (var index = 0; index < execution.rows.length; index++) {
        final row = execution.rows[index];
        if (row.direction == TransactionDirection.credit) continue;

        final vendorName = const RuleEngine().normalizeVendor(
          rule,
          row.vendorRaw,
        );
        final vendors = await database.select(database.vendors).get();
        Vendor? vendor;
        for (final candidate in vendors) {
          if (candidate.name.toLowerCase() == vendorName.toLowerCase()) {
            vendor = candidate;
            break;
          }
        }
        if (vendor == null) {
          final vendorId = 'dev-vendor-$index';
          await database
              .into(database.vendors)
              .insert(
                VendorsCompanion.insert(
                  id: vendorId,
                  name: vendorName,
                  updatedAt: now,
                ),
              );
          vendor = await (database.select(
            database.vendors,
          )..where((row) => row.id.equals(vendorId))).getSingle();
        }

        final sourceRef =
            row.sourceRef ??
            'dev:${row.date.millisecondsSinceEpoch}:'
                '$vendorName:${row.amountMinor}:$index';
        final duplicate = await (database.select(
          database.transactions,
        )..where((row) => row.sourceRef.equals(sourceRef))).getSingleOrNull();
        if (duplicate != null) {
          duplicateCount++;
          continue;
        }
        await database
            .into(database.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'dev-transaction-$index',
                date: row.date.millisecondsSinceEpoch,
                vendorId: vendor.id,
                categoryId: 'dev-category',
                amountMinor: row.amountMinor.abs(),
                note: row.vendorRaw,
                sourceRef: Value(sourceRef),
                isManual: false,
                updatedAt: now,
              ),
            );
        importedCount++;
      }

      final transactions = await database.select(database.transactions).get();
      final report = const ReportBuilder().build(
        start: DateTime.utc(2026, 7),
        end: DateTime.utc(2026, 7, 31),
        categories: const [
          ReportCategory(
            id: 'dev-category',
            name: 'Daily spending',
            isSaving: false,
          ),
        ],
        budgets: [
          BudgetVersion(
            id: 'dev-budget',
            effectiveFrom: DateTime.utc(2026, 7),
            lines: const [
              ReportBudgetLine(categoryId: 'dev-category', amountMinor: 100000),
            ],
          ),
        ],
        transactions: transactions
            .map(
              (transaction) => ReportTransaction(
                id: transaction.id,
                date: DateTime.fromMillisecondsSinceEpoch(
                  transaction.date,
                  isUtc: true,
                ),
                categoryId: transaction.categoryId,
                amountMinor: transaction.amountMinor,
              ),
            )
            .toList(),
      );

      stdout.writeln('Database: ${dbFile.path}');
      stdout.writeln('Imported: $importedCount');
      stdout.writeln('Duplicates in import: $duplicateCount');
      stdout.writeln(
        'Reconciliation: ${reconciliation.level.name} '
        '${reconciliation.passed ? 'passed' : 'not applicable'}',
      );
      stdout.writeln('Rows in database: ${transactions.length}');
      stdout.writeln('Spent: ${report.spentMinor} minor units');
      stdout.writeln('Set aside: ${report.setAsideMinor} minor units');
      stdout.writeln('Budget: ${report.budgetMinor} minor units');
      stdout.writeln('Remaining: ${report.remainingMinor} minor units');
      stdout.writeln(
        'Unbudgeted spend: ${report.unbudgetedSpendMinor} minor units',
      );
    } finally {
      await database.close();
      await temp.delete(recursive: true);
    }
  }();
}

void _configureSqlite() {
  open.overrideForAll(() {
    if (Platform.isLinux) {
      for (final path in const [
        'libsqlite3.so',
        'libsqlite3.so.0',
        '/lib64/libsqlite3.so.0',
        '/lib/x86_64-linux-gnu/libsqlite3.so.0',
        '/usr/lib64/libsqlite3.so.0',
        '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
      ]) {
        try {
          return DynamicLibrary.open(path);
        } on ArgumentError {
          // Try the next system location.
        }
      }
    }
    throw ArgumentError('Unable to locate a system SQLite library');
  });
}

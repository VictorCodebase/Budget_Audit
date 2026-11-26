import 'dart:io';

import 'package:ba_core/ba_core.dart';
import 'package:ba_data/ba_data.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../adapters/pdf_positioned_words.dart';

class StatementImportDocument {
  final List<PositionedWord>? positionedWords;
  final CsvDocument? csv;
  final OfxDocument? ofx;

  const StatementImportDocument.positionedWords(this.positionedWords)
    : csv = null,
      ofx = null;

  const StatementImportDocument.csv(this.csv)
    : positionedWords = null,
      ofx = null;

  const StatementImportDocument.ofx(this.ofx)
    : positionedWords = null,
      csv = null;
}

abstract class StatementImportAdapter {
  StatementImportDocument adapt(File file);
}

class BuiltInStatementImportAdapter implements StatementImportAdapter {
  const BuiltInStatementImportAdapter();

  @override
  StatementImportDocument adapt(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (extension == 'csv') {
      return StatementImportDocument.csv(
        const CsvExtractor().extractFile(file),
      );
    }
    if (extension == 'ofx' || extension == 'qfx') {
      return StatementImportDocument.ofx(
        const OfxExtractor().extractFile(file),
      );
    }
    return StatementImportDocument.positionedWords(
      PdfPositionedWordAdapter().extract(file),
    );
  }
}

class VendorSuggestion {
  final String vendorName;
  final String? categoryId;

  const VendorSuggestion({required this.vendorName, this.categoryId});
}

class ImportResult {
  final ReconciliationResult reconciliation;
  final int importedCount;
  final int duplicateCount;
  final int skippedCreditCount;
  final List<String> parseErrors;
  final List<VendorSuggestion> suggestions;

  const ImportResult({
    required this.reconciliation,
    required this.importedCount,
    required this.duplicateCount,
    required this.skippedCreditCount,
    required this.parseErrors,
    required this.suggestions,
  });
}

class ImportService {
  ImportService({
    required this.database,
    this.adapter = const BuiltInStatementImportAdapter(),
    this.ruleEngine = const RuleEngine(),
    this.reconciler = const Reconciler(),
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  final AppDatabase database;
  final StatementImportAdapter adapter;
  final RuleEngine ruleEngine;
  final Reconciler reconciler;
  final Uuid uuid;

  Future<ImportResult> importFixture({
    required File file,
    required BankRule rule,
    String? defaultCategoryId,
    int? openingBalanceMinor,
    int? endingBalanceMinor,
    ReconciliationLevel reconciliationLevel = ReconciliationLevel.full,
  }) async {
    final document = adapter.adapt(file);
    final execution = _execute(rule, document);
    final reconciliation = reconciler.reconcile(
      execution.rows,
      openingBalanceMinor: openingBalanceMinor,
      endingBalanceMinor: endingBalanceMinor,
      level: reconciliationLevel,
    );

    var importedCount = 0;
    var duplicateCount = 0;
    var skippedCreditCount = 0;
    final suggestions = <VendorSuggestion>[];

    for (var index = 0; index < execution.rows.length; index++) {
      final row = execution.rows[index];
      if (row.direction == TransactionDirection.credit) {
        skippedCreditCount++;
        continue;
      }

      final vendorName = ruleEngine.normalizeVendor(rule, row.vendorRaw);
      final vendor = await _findOrCreateVendor(vendorName);
      final defaultCategory = await _vendorDefaultCategory(vendor.id);
      final categoryId = defaultCategory ?? defaultCategoryId;
      suggestions.add(
        VendorSuggestion(vendorName: vendorName, categoryId: categoryId),
      );
      if (categoryId == null) {
        continue;
      }

      final category = await (database.select(
        database.categories,
      )..where((row) => row.id.equals(categoryId))).getSingleOrNull();
      if (category == null) {
        continue;
      }

      final sourceRef =
          row.sourceRef ??
          'import:${file.path}:${row.date.millisecondsSinceEpoch}:'
              '$vendorName:${row.amountMinor}:$index';
      final existing = await (database.select(
        database.transactions,
      )..where((row) => row.sourceRef.equals(sourceRef))).getSingleOrNull();
      if (existing != null) {
        duplicateCount++;
        continue;
      }

      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: uuid.v4(),
              date: row.date.millisecondsSinceEpoch,
              vendorId: vendor.id,
              categoryId: categoryId,
              amountMinor: row.amountMinor.abs(),
              note: row.vendorRaw,
              sourceRef: Value(sourceRef),
              isManual: false,
              updatedAt: row.date.millisecondsSinceEpoch,
            ),
          );
      importedCount++;
    }

    return ImportResult(
      reconciliation: reconciliation,
      importedCount: importedCount,
      duplicateCount: duplicateCount,
      skippedCreditCount: skippedCreditCount,
      parseErrors: execution.errors,
      suggestions: suggestions,
    );
  }

  Future<ImportResult> importDocument({
    required StatementImportDocument document,
    required BankRule rule,
    String? defaultCategoryId,
    int? openingBalanceMinor,
    int? endingBalanceMinor,
    ReconciliationLevel reconciliationLevel = ReconciliationLevel.full,
  }) {
    return _importDocument(
      document: document,
      sourceName: 'document',
      rule: rule,
      defaultCategoryId: defaultCategoryId,
      openingBalanceMinor: openingBalanceMinor,
      endingBalanceMinor: endingBalanceMinor,
      reconciliationLevel: reconciliationLevel,
    );
  }

  RuleExecutionResult _execute(
    BankRule rule,
    StatementImportDocument document,
  ) {
    if (document.positionedWords != null) {
      return ruleEngine.interpretPositionedWords(
        rule,
        document.positionedWords!,
      );
    }
    if (document.csv != null) {
      return ruleEngine.interpretCsv(rule, document.csv!);
    }
    if (document.ofx != null) {
      return ruleEngine.interpretOfx(rule, document.ofx!);
    }
    return const RuleExecutionResult(
      rows: [],
      errors: ['Unsupported statement'],
    );
  }

  Future<ImportResult> _importDocument({
    required StatementImportDocument document,
    required String sourceName,
    required BankRule rule,
    required String? defaultCategoryId,
    required int? openingBalanceMinor,
    required int? endingBalanceMinor,
    required ReconciliationLevel reconciliationLevel,
  }) async {
    final execution = _execute(rule, document);
    final reconciliation = reconciler.reconcile(
      execution.rows,
      openingBalanceMinor: openingBalanceMinor,
      endingBalanceMinor: endingBalanceMinor,
      level: reconciliationLevel,
    );

    var importedCount = 0;
    var duplicateCount = 0;
    var skippedCreditCount = 0;
    final suggestions = <VendorSuggestion>[];

    for (var index = 0; index < execution.rows.length; index++) {
      final row = execution.rows[index];
      if (row.direction == TransactionDirection.credit) {
        skippedCreditCount++;
        continue;
      }
      final vendorName = ruleEngine.normalizeVendor(rule, row.vendorRaw);
      final vendor = await _findOrCreateVendor(vendorName);
      final defaultCategory = await _vendorDefaultCategory(vendor.id);
      final categoryId = defaultCategory ?? defaultCategoryId;
      suggestions.add(
        VendorSuggestion(vendorName: vendorName, categoryId: categoryId),
      );
      if (categoryId == null) continue;

      final category = await (database.select(
        database.categories,
      )..where((row) => row.id.equals(categoryId))).getSingleOrNull();
      if (category == null) continue;

      final sourceRef =
          row.sourceRef ??
          'import:$sourceName:${row.date.millisecondsSinceEpoch}:'
              '$vendorName:${row.amountMinor}:$index';
      final existing = await (database.select(
        database.transactions,
      )..where((row) => row.sourceRef.equals(sourceRef))).getSingleOrNull();
      if (existing != null) {
        duplicateCount++;
        continue;
      }
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: uuid.v4(),
              note: row.vendorRaw,
              date: row.date.millisecondsSinceEpoch,
              vendorId: vendor.id,
              categoryId: categoryId,
              amountMinor: row.amountMinor.abs(),
              sourceRef: Value(sourceRef),
              isManual: false,
              updatedAt: row.date.millisecondsSinceEpoch,
            ),
          );
      importedCount++;
    }

    return ImportResult(
      reconciliation: reconciliation,
      importedCount: importedCount,
      duplicateCount: duplicateCount,
      skippedCreditCount: skippedCreditCount,
      parseErrors: execution.errors,
      suggestions: suggestions,
    );
  }

  Future<Vendor> _findOrCreateVendor(String name) async {
    final vendors = await database.select(database.vendors).get();
    for (final vendor in vendors) {
      if (vendor.name.toLowerCase() == name.toLowerCase()) return vendor;
    }
    final id = uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    await database
        .into(database.vendors)
        .insert(VendorsCompanion.insert(id: id, name: name, updatedAt: now));
    return (await (database.select(
      database.vendors,
    )..where((row) => row.id.equals(id))).getSingle());
  }

  Future<String?> _vendorDefaultCategory(String vendorId) async {
    final defaultRow = await (database.select(
      database.vendorDefaults,
    )..where((row) => row.vendorId.equals(vendorId))).getSingleOrNull();
    return defaultRow?.categoryId;
  }
}

import 'dart:ffi';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';
import 'package:ba_core/ba_core.dart';
import 'package:ba_data/ba_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_audit/v2/services/import_service.dart';

void main() {
  setUpAll(() {
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
  });

  late AppDatabase database;
  late ImportService service;

  setUp(() async {
    database = AppDatabase();
    service = ImportService(database: database);
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'food',
            name: 'Food',
            isSaving: false,
            color: '#000000',
            updatedAt: 0,
          ),
        );
  });

  tearDown(() => database.close());

  test('imports a fixture twice and deduplicates source references', () async {
    final rule = BankRule.fromJson(const {
      'institution': 'Test',
      'rule_version': 1,
      'engine_min': 1,
      'extractor': 'csv',
      'detect': <String, dynamic>{},
      'layout': <String, dynamic>{},
      'direction': 'signed',
      'fields': {
        'date': 'Date',
        'vendor_raw': 'Vendor',
        'amount': 'Amount',
        'source_ref': 'Ref',
      },
      'keep_rows': <dynamic>[],
      'skip_rows_containing': <String>[],
      'vendor': <Map<String, dynamic>>[],
    });
    const document = StatementImportDocument.csv(
      CsvDocument(
        headers: ['Date', 'Vendor', 'Amount', 'Ref'],
        rows: [
          {
            'Date': '2026-01-10',
            'Vendor': 'Cafe',
            'Amount': '-1250',
            'Ref': 'tx-1',
          },
        ],
      ),
    );
    final first = await service.importDocument(
      document: document,
      rule: rule,
      defaultCategoryId: 'food',
    );
    final second = await service.importDocument(
      document: document,
      rule: rule,
      defaultCategoryId: 'food',
    );

    expect(first.importedCount, 1);
    expect(second.importedCount, 0);
    expect(second.duplicateCount, 1);
    expect((await database.select(database.transactions).get()).length, 1);
  });

  test('uses vendor defaults and shows reconciliation status', () async {
    final rule = BankRule.fromJson(const {
      'institution': 'Test',
      'rule_version': 1,
      'engine_min': 1,
      'extractor': 'ofx',
      'detect': <String, dynamic>{},
      'layout': <String, dynamic>{},
      'direction': 'signed',
      'fields': {
        'date': 'DTPOSTED',
        'vendor_raw': 'NAME',
        'amount': 'TRNAMT',
        'source_ref': 'source_ref',
      },
      'keep_rows': <dynamic>[],
      'skip_rows_containing': <String>[],
      'vendor': <Map<String, dynamic>>[],
    });
    const document = StatementImportDocument.ofx(
      OfxDocument(
        transactions: [
          {
            'DTPOSTED': '20260110',
            'NAME': 'Market',
            'TRNAMT': '-1250',
            'source_ref': 'ofx-1',
          },
        ],
        fields: {},
      ),
    );

    final result = await service.importDocument(
      document: document,
      rule: rule,
      defaultCategoryId: 'food',
      reconciliationLevel: ReconciliationLevel.partial,
    );

    expect(result.reconciliation.level, ReconciliationLevel.partial);
    expect(result.reconciliation.passed, isFalse);
    expect(result.suggestions.single.categoryId, 'food');
  });
}

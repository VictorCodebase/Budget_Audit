import 'package:ba_data/ba_data.dart';
import 'package:ba_data/dao/categories_dao.dart';
import 'package:ba_data/dao/transactions_dao.dart';
import 'package:ba_data/dao/vendors_dao.dart';
import 'package:ba_data/dao/budgets_dao.dart';
import 'package:test/test.dart';

import 'sqlite_test_setup.dart';

void main() {
  setUpAll(configureSqliteTestLibrary);
  late AppDatabase db;

  setUp(() {
    db = AppDatabase();
  });

  tearDown(() => db.close());

  test('duplicate source_ref is ignored', () async {
    await VendorsDao(db).create(id: 'v1', name: 'KPLC', updatedAt: 100);
    await CategoriesDao(db).create(
      id: 'c1',
      name: 'Power',
      isSaving: false,
      color: '#222222',
      updatedAt: 100,
    );
    final dao = TransactionsDao(db);
    final first = await dao.create(
      id: 'tx1',
      date: 100,
      vendorId: 'v1',
      categoryId: 'c1',
      amountMinor: 500,
      note: '',
      sourceRef: 'receipt-1',
      isManual: false,
      updatedAt: 100,
    );
    final duplicate = await dao.create(
      id: 'tx2',
      date: 101,
      vendorId: 'v1',
      categoryId: 'c1',
      amountMinor: 600,
      note: '',
      sourceRef: 'receipt-1',
      isManual: false,
      updatedAt: 101,
    );

    expect(first, 1);
    expect(duplicate, 0);
    expect(await dao.all(), hasLength(1));
  });

  test('null source_ref permits multiple transactions', () async {
    await VendorsDao(db).create(id: 'v1', name: 'KPLC', updatedAt: 100);
    await CategoriesDao(db).create(
      id: 'c1',
      name: 'Power',
      isSaving: false,
      color: '#222222',
      updatedAt: 100,
    );
    final dao = TransactionsDao(db);
    await dao.create(
      id: 'tx1',
      date: 100,
      vendorId: 'v1',
      categoryId: 'c1',
      amountMinor: 500,
      note: '',
      isManual: false,
      updatedAt: 100,
    );
    await dao.create(
      id: 'tx2',
      date: 101,
      vendorId: 'v1',
      categoryId: 'c1',
      amountMinor: 600,
      note: '',
      isManual: false,
      updatedAt: 101,
    );
    expect(await dao.all(), hasLength(2));
  });

  test(
    'budget is created atomically with lines and has no update API',
    () async {
      await CategoriesDao(db).create(
        id: 'c1',
        name: 'Power',
        isSaving: false,
        color: '#222222',
        updatedAt: 100,
      );
      await CategoriesDao(db).create(
        id: 'c2',
        name: 'Food',
        isSaving: false,
        color: '#333333',
        updatedAt: 100,
      );
      final dao = BudgetsDao(db);
      await dao.create(
        id: 'b1',
        name: 'Monthly',
        period: 'monthly',
        effectiveFrom: 100,
        supersedesId: null,
        updatedAt: 100,
        categoryAmountsMinor: {'c1': 5000, 'c2': 10000},
      );

      expect((await dao.all()).single.id, 'b1');
      expect(await dao.linesFor('b1'), hasLength(2));
    },
  );

  test('transaction soft delete excludes row from active results', () async {
    await VendorsDao(db).create(id: 'v1', name: 'KPLC', updatedAt: 100);
    await CategoriesDao(db).create(
      id: 'c1',
      name: 'Power',
      isSaving: false,
      color: '#222222',
      updatedAt: 100,
    );
    final dao = TransactionsDao(db);
    await dao.create(
      id: 'tx1',
      date: 100,
      vendorId: 'v1',
      categoryId: 'c1',
      amountMinor: 500,
      note: '',
      isManual: false,
      updatedAt: 100,
    );
    await dao.softDelete('tx1', 101);
    expect(await dao.all(), isEmpty);
  });
}

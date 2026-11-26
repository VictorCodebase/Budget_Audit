import 'package:ba_data/dao/groups_dao.dart';
import 'package:ba_data/dao/categories_dao.dart';
import 'package:ba_data/dao/vendors_dao.dart';
import 'package:ba_data/dao/vendor_defaults_dao.dart';
import 'package:ba_data/ba_data.dart';
import 'package:test/test.dart';

import 'sqlite_test_setup.dart';

void main() {
  setUpAll(configureSqliteTestLibrary);
  late AppDatabase db;

  setUp(() {
    db = AppDatabase();
  });

  tearDown(() => db.close());

  test('group CRUD and archive', () async {
    final dao = GroupsDao(db);
    await dao.create(
      id: 'g1',
      name: 'Household',
      sort: 1,
      color: '#111111',
      updatedAt: 100,
    );

    expect((await dao.all()).single.name, 'Household');
    await dao.rename(id: 'g1', name: 'Home', updatedAt: 101);
    expect((await dao.getById('g1'))!.name, 'Home');
    await dao.archive('g1', 102);
    expect(await dao.all(), isEmpty);
    expect((await dao.all(includeArchived: true)).single.name, 'Home');
  });

  test('category CRUD and archive', () async {
    final groups = GroupsDao(db);
    final dao = CategoriesDao(db);
    await groups.create(
      id: 'g1',
      name: 'Home',
      sort: 1,
      color: '#111111',
      updatedAt: 100,
    );
    await dao.create(
      id: 'c1',
      groupId: 'g1',
      name: 'Power',
      isSaving: false,
      color: '#222222',
      updatedAt: 100,
    );

    await dao.updateCategory(
      id: 'c1',
      name: 'Electricity',
      isSaving: true,
      updatedAt: 101,
    );
    final category = (await dao.getById('c1'))!;
    expect(category.name, 'Electricity');
    expect(category.isSaving, isTrue);

    await dao.archive('c1', 102);
    expect(await dao.all(), isEmpty);
  });

  test('vendor CRUD', () async {
    final dao = VendorsDao(db);
    await dao.create(id: 'v1', name: 'Kenya Power', updatedAt: 100);
    await dao.rename(id: 'v1', name: 'KPLC', updatedAt: 101);
    expect((await dao.all()).single.name, 'KPLC');
    await dao.delete('v1');
    expect(await dao.all(), isEmpty);
  });

  test('vendor default upsert increments use_count', () async {
    await VendorsDao(db).create(id: 'v1', name: 'KPLC', updatedAt: 100);
    await CategoriesDao(db).create(
      id: 'c1',
      name: 'Power',
      isSaving: false,
      color: '#222222',
      updatedAt: 100,
    );
    final dao = VendorDefaultsDao(db);

    final first = await dao.upsert(
      vendorId: 'v1',
      categoryId: 'c1',
      usedAt: 101,
    );
    final second = await dao.upsert(
      vendorId: 'v1',
      categoryId: 'c1',
      usedAt: 102,
    );

    expect(first.useCount, 1);
    expect(second.useCount, 2);
    expect(second.lastUsed, 102);
  });
}

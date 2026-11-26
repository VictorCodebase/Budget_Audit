import 'dart:io';

import 'package:ba_data/ba_data.dart';
import 'package:ba_data/migrator/v1_migrator.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase destination;
  late Directory tempDirectory;
  late String v1Path;

  setUp(() {
    destination = AppDatabase();
    tempDirectory = Directory.systemTemp.createTempSync('ba_v1_migrator_test');
    final v1Directory = Directory('${tempDirectory.path}/budget_audit')
      ..createSync();
    v1Path = '${v1Directory.path}/db.sqlite';
    final v1 = sqlite3.open(v1Path);
    final fixture = File(
      '${Directory.current.parent.parent.path}/test/fixtures/v1/v1_empty.sql',
    );
    v1.execute(fixture.readAsStringSync());
    v1.dispose();
  });

  tearDown(() async {
    await destination.close();
    tempDirectory.deleteSync(recursive: true);
  });

  test(
    'opens the exact V1 path read-only and migration is idempotent',
    () async {
      final before = File(v1Path).readAsBytesSync();
      final migrator = V1Migrator(destination);

      expect(V1Migrator.v1DatabasePath(tempDirectory.path), v1Path);

      final first = await migrator.migrate(v1Path);
      final second = await migrator.migrate(v1Path);
      final after = File(v1Path).readAsBytesSync();

      expect(first.groups, 0);
      expect(first.categories, 0);
      expect(first.budgets, 0);
      expect(first.budgetLines, 0);
      expect(first.transactions, 0);
      expect(first.vendors, 0);
      expect(first.vendorDefaults, 0);
      expect(second.groups, 0);
      expect(after, before);
    },
  );
}

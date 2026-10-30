import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';

void main() {
  sqfliteFfiInit();

  test('SQLite in-memory database opens and closes', () async {
    final helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    final database = await helper.database;

    expect(database.isOpen, isTrue);

    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    expect(
      tables.any((table) => table['name'] == 'focus_presets'),
      isTrue,
    );

    expect(
      tables.any((table) => table['name'] == 'session_logs'),
      isTrue,
    );

    await helper.close();
  });
}
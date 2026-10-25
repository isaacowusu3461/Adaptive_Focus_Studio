
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper databaseHelper;

  setUp(() {
    databaseHelper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  test('creates the focus_presets and session_logs tables', () async {
    final db = await databaseHelper.database;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    final tableNames = tables.map((row) => row['name']).toList();

    expect(
      tableNames,
      contains(DatabaseHelper.presetsTable),
    );

    expect(
      tableNames,
      contains(DatabaseHelper.sessionsTable),
    );
  });

  test('inserts and retrieves a focus preset', () async {
    final db = await databaseHelper.database;

    final id = await db.insert(
      DatabaseHelper.presetsTable,
      {
        'name': 'Algorithms Practice',
        'mood_tag': 'Focused',
        'duration_minutes': 25,
      },
    );

    final results = await db.query(
      DatabaseHelper.presetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    expect(results.length, 1);
    expect(results.first['name'], 'Algorithms Practice');
    expect(results.first['duration_minutes'], 25);
  });

  test('inserts a session log linked to a preset', () async {
    final db = await databaseHelper.database;

    final presetId = await db.insert(
      DatabaseHelper.presetsTable,
      {
        'name': 'Mobile Development',
        'mood_tag': 'Motivated',
        'duration_minutes': 40,
      },
    );

    await db.insert(
      DatabaseHelper.sessionsTable,
      {
        'preset_id': presetId,
        'date': DateTime(2026, 10, 25).toIso8601String(),
        'completed_seconds': 1800,
        'status': 'completed',
        'notes': 'Practiced Flutter',
      },
    );

    final sessions = await db.query(
      DatabaseHelper.sessionsTable,
    );

    expect(sessions.length, 1);
    expect(sessions.first['preset_id'], presetId);
    expect(sessions.first['completed_seconds'], 1800);
  });

  test('deleting a preset also deletes related sessions', () async {
    final db = await databaseHelper.database;

    final presetId = await db.insert(
      DatabaseHelper.presetsTable,
      {
        'name': 'Database Study',
        'mood_tag': 'Focused',
        'duration_minutes': 30,
      },
    );

    await db.insert(
      DatabaseHelper.sessionsTable,
      {
        'preset_id': presetId,
        'date': DateTime(2026, 10, 25).toIso8601String(),
        'completed_seconds': 1200,
        'status': 'completed',
        'notes': '',
      },
    );

    await db.delete(
      DatabaseHelper.presetsTable,
      where: 'id = ?',
      whereArgs: [presetId],
    );

    final sessions = await db.query(
      DatabaseHelper.sessionsTable,
    );

    expect(sessions, isEmpty);
  });

  test('rejects a preset with an invalid duration', () async {
    final db = await databaseHelper.database;

    await expectLater(
      db.insert(
        DatabaseHelper.presetsTable,
        {
          'name': 'Invalid Preset',
          'mood_tag': 'Focused',
          'duration_minutes': -5,
        },
      ),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('rejects a session with an invalid preset ID', () async {
    final db = await databaseHelper.database;

    await expectLater(
      db.insert(
        DatabaseHelper.sessionsTable,
        {
          'preset_id': 999,
          'date': DateTime(2026, 10, 25).toIso8601String(),
          'completed_seconds': 600,
          'status': 'completed',
          'notes': '',
        },
      ),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('rejects negative completed session duration', () async {
    final db = await databaseHelper.database;

    final presetId = await db.insert(
      DatabaseHelper.presetsTable,
      {
        'name': 'Testing',
        'mood_tag': 'Focused',
        'duration_minutes': 25,
      },
    );

    await expectLater(
      db.insert(
        DatabaseHelper.sessionsTable,
        {
          'preset_id': presetId,
          'date': DateTime(2026, 10, 25).toIso8601String(),
          'completed_seconds': -10,
          'status': 'completed',
          'notes': '',
        },
      ),
      throwsA(isA<DatabaseException>()),
    );
  });
}

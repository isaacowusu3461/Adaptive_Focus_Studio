
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/data/services/focus_backup_service.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late FocusBackupService service;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() {
    databaseHelper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    service = FocusBackupService(
      databaseHelper: databaseHelper,
    );
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  Future<void> seedDatabase() async {
    final db = await databaseHelper.database;

    await db.insert(DatabaseHelper.presetsTable, {
      'id': 1,
      'name': 'Morning Study',
      'mood_tag': 'Focused',
      'duration_minutes': 25,
    });

    await db.insert(DatabaseHelper.sessionsTable, {
      'id': 10,
      'preset_id': 1,
      'date': '2026-10-28T10:00:00.000Z',
      'completed_seconds': 1500,
      'status': 'completed',
      'notes': 'Finished',
    });
  }

  test('exports saved presets and sessions', () async {
    await seedDatabase();

    final json = await service.exportJson();
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    expect((decoded['focusPresets'] as List).length, 1);
    expect((decoded['sessionLogs'] as List).length, 1);
  });

  test('restores exported data', () async {
    await seedDatabase();
    final json = await service.exportJson();

    final db = await databaseHelper.database;
    await db.delete(DatabaseHelper.sessionsTable);
    await db.delete(DatabaseHelper.presetsTable);

    final result = await service.importJson(json);

    expect(result.presetCount, 1);
    expect(result.sessionCount, 1);

    final presets = await db.query(DatabaseHelper.presetsTable);
    final sessions = await db.query(DatabaseHelper.sessionsTable);

    expect(presets.length, 1);
    expect(sessions.length, 1);
    expect(sessions.first['preset_id'], 1);
  });

  test('replaces existing records on import', () async {
    await seedDatabase();
    final json = await service.exportJson();

    final db = await databaseHelper.database;

    await db.insert(DatabaseHelper.presetsTable, {
      'id': 2,
      'name': 'Extra Preset',
      'mood_tag': 'Relaxed',
      'duration_minutes': 20,
    });

    await service.importJson(json);

    final presets = await db.query(DatabaseHelper.presetsTable);

    expect(presets.length, 1);
    expect(presets.first['name'], 'Morning Study');
  });

  test('reimporting does not duplicate records', () async {
    await seedDatabase();
    final json = await service.exportJson();

    await service.importJson(json);
    await service.importJson(json);

    final db = await databaseHelper.database;
    final presets = await db.query(DatabaseHelper.presetsTable);
    final sessions = await db.query(DatabaseHelper.sessionsTable);

    expect(presets.length, 1);
    expect(sessions.length, 1);
  });

  test('invalid JSON preserves existing data', () async {
    await seedDatabase();

    await expectLater(
      service.importJson('{invalid'),
      throwsFormatException,
    );

    final db = await databaseHelper.database;
    final presets = await db.query(DatabaseHelper.presetsTable);
    final sessions = await db.query(DatabaseHelper.sessionsTable);

    expect(presets.length, 1);
    expect(sessions.length, 1);
  });

  test('invalid foreign key preserves existing data', () async {
    await seedDatabase();

    final json = await service.exportJson();
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    final sessions = decoded['sessionLogs'] as List;
    (sessions.first as Map<String, dynamic>)['presetId'] = 999;

    await expectLater(
      service.importJson(jsonEncode(decoded)),
      throwsFormatException,
    );

    final db = await databaseHelper.database;
    final saved = await db.query(DatabaseHelper.sessionsTable);

    expect(saved.length, 1);
    expect(saved.first['preset_id'], 1);
  });

  test('empty backup clears both tables', () async {
    await seedDatabase();

    final json = jsonEncode({
      'formatVersion': 1,
      'app': 'Adaptive Focus Studio',
      'exportedAt': DateTime.utc(2026, 10, 28).toIso8601String(),
      'focusPresets': [],
      'sessionLogs': [],
    });

    await service.importJson(json);

    final db = await databaseHelper.database;

    expect(
      await db.query(DatabaseHelper.presetsTable),
      isEmpty,
    );

    expect(
      await db.query(DatabaseHelper.sessionsTable),
      isEmpty,
    );
  });
}

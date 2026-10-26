
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/data/repositories/focus_preset_repository_impl.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper databaseHelper;
  late FocusPresetRepositoryImpl repository;

  setUp(() {
    databaseHelper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    repository = FocusPresetRepositoryImpl(
      databaseHelper: databaseHelper,
    );
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  test('creates and retrieves a focus preset', () async {
    const preset = FocusPreset(
      name: 'Algorithms Practice',
      moodTag: 'Focused',
      durationMinutes: 25,
    );

    final id = await repository.createPreset(preset);
    final savedPreset = await repository.getPresetById(id);

    expect(id, greaterThan(0));
    expect(savedPreset, isNotNull);
    expect(savedPreset!.name, 'Algorithms Practice');
    expect(savedPreset.moodTag, 'Focused');
    expect(savedPreset.durationMinutes, 25);
  });

  test('retrieves all presets in newest-first order', () async {
    await repository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    await repository.createPreset(
      const FocusPreset(
        name: 'Mobile Development',
        moodTag: 'Motivated',
        durationMinutes: 40,
      ),
    );

    final presets = await repository.getAllPresets();

    expect(presets.length, 2);
    expect(presets.first.name, 'Mobile Development');
    expect(presets.last.name, 'Algorithms');
  });

  test('returns null when preset ID does not exist', () async {
    final preset = await repository.getPresetById(999);

    expect(preset, isNull);
  });

  test('updates an existing preset', () async {
    final id = await repository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final updatedRows = await repository.updatePreset(
      FocusPreset(
        id: id,
        name: 'Advanced Algorithms',
        moodTag: 'Motivated',
        durationMinutes: 45,
      ),
    );

    final updatedPreset = await repository.getPresetById(id);

    expect(updatedRows, 1);
    expect(updatedPreset!.name, 'Advanced Algorithms');
    expect(updatedPreset.moodTag, 'Motivated');
    expect(updatedPreset.durationMinutes, 45);
  });

  test('deletes an existing preset', () async {
    final id = await repository.createPreset(
      const FocusPreset(
        name: 'Database Study',
        moodTag: 'Focused',
        durationMinutes: 30,
      ),
    );

    final deletedRows = await repository.deletePreset(id);
    final deletedPreset = await repository.getPresetById(id);

    expect(deletedRows, 1);
    expect(deletedPreset, isNull);
  });

  test('deleting a preset cascades to its session logs', () async {
    final id = await repository.createPreset(
      const FocusPreset(
        name: 'Flutter Practice',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final db = await databaseHelper.database;

    await db.insert(
      DatabaseHelper.sessionsTable,
      {
        'preset_id': id,
        'date': DateTime(2026, 10, 25).toIso8601String(),
        'completed_seconds': 900,
        'status': 'completed',
        'notes': 'Practiced widgets',
      },
    );

    await repository.deletePreset(id);

    final sessions = await db.query(
      DatabaseHelper.sessionsTable,
    );

    expect(sessions, isEmpty);
  });

  test('rejects an empty preset name', () async {
    await expectLater(
      repository.createPreset(
        const FocusPreset(
          name: '   ',
          moodTag: 'Focused',
          durationMinutes: 25,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('rejects an empty mood tag', () async {
    await expectLater(
      repository.createPreset(
        const FocusPreset(
          name: 'Algorithms',
          moodTag: '   ',
          durationMinutes: 25,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('rejects an invalid duration', () async {
    await expectLater(
      repository.createPreset(
        const FocusPreset(
          name: 'Algorithms',
          moodTag: 'Focused',
          durationMinutes: 0,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('rejects an update without a preset ID', () async {
    await expectLater(
      repository.updatePreset(
        const FocusPreset(
          name: 'Algorithms',
          moodTag: 'Focused',
          durationMinutes: 25,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('returns zero when updating a missing preset', () async {
    final rows = await repository.updatePreset(
      const FocusPreset(
        id: 999,
        name: 'Missing Preset',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    expect(rows, 0);
  });

  test('returns zero when deleting a missing preset', () async {
    final rows = await repository.deletePreset(999);

    expect(rows, 0);
  });

  test('rejects an invalid deletion ID', () async {
    await expectLater(
      repository.deletePreset(-1),
      throwsArgumentError,
    );
  });
}

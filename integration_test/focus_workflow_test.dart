import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/data/services/focus_backup_service.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseHelper helper;
  late FocusDependencies dependencies;
  late String databasePath;

  setUp(() async {
    databasePath = path.join(
      await getDatabasesPath(),
      'adaptive_focus_integration_test.db',
    );

    await deleteDatabase(databasePath);

    helper = DatabaseHelper(databasePath: databasePath);

    dependencies = FocusDependencies(databaseHelper: helper);
  });

  tearDown(() async {
    await helper.close();
    await deleteDatabase(databasePath);
  });

  testWidgets('Preset is saved and survives database reopen', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms Practice',
        moodTag: 'Focused',
        durationMinutes: 30,
      ),
    );

    final saved = await dependencies.presetRepository.getPresetById(id);

    expect(saved, isNotNull);
    expect(saved!.name, 'Algorithms Practice');

    await helper.close();

    final reopenedHelper = DatabaseHelper(databasePath: databasePath);

    try {
      final reopenedDependencies = FocusDependencies(
        databaseHelper: reopenedHelper,
      );

      final restored = await reopenedDependencies.presetRepository
          .getPresetById(id);

      expect(restored, isNotNull);
      expect(restored!.name, 'Algorithms Practice');
      expect(restored.durationMinutes, 30);
    } finally {
      await reopenedHelper.close();
    }
  });

  testWidgets('Preset update persists in SQLite', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Flutter Basics',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    await dependencies.updateFocusPreset(
      id: id,
      name: 'Advanced Flutter',
      moodTag: 'Motivated',
      durationMinutes: 45,
    );

    final updated = await dependencies.presetRepository.getPresetById(id);

    expect(updated, isNotNull);
    expect(updated!.name, 'Advanced Flutter');
    expect(updated.moodTag, 'Motivated');
    expect(updated.durationMinutes, 45);
  });

  testWidgets('Completed session appears in history', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Database Revision',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    await dependencies.saveSessionLog(
      presetId: id,
      date: DateTime(2026, 10, 29),
      completedSeconds: 1500,
      status: 'completed',
    );

    final history = await dependencies.sessionRepository.getAllSessions();

    expect(history.length, 1);
    expect(history.first.presetId, id);
    expect(history.first.completedSeconds, 1500);
    expect(history.first.status, 'completed');
  });

  testWidgets('Session Scout uses saved completed sessions', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    for (var i = 0; i < 3; i++) {
      await dependencies.saveSessionLog(
        presetId: id,
        date: DateTime(2026, 10, 20 + i),
        completedSeconds: (20 + i * 5) * 60,
        status: 'completed',
      );
    }

    final recommendation = await dependencies.getSessionScoutRecommendation(
      moodTag: 'Focused',
    );

    expect(recommendation.usedFallback, false);
    expect(recommendation.sessionsUsed, 3);
    expect(recommendation.suggestedMinutes, 25);
  });

  testWidgets('Deleting a preset also deletes related sessions', (
    tester,
  ) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Reading',
        moodTag: 'Relaxed',
        durationMinutes: 30,
      ),
    );

    await dependencies.saveSessionLog(
      presetId: id,
      date: DateTime(2026, 10, 29),
      completedSeconds: 1800,
      status: 'completed',
    );

    await dependencies.presetRepository.deletePreset(id);

    final presets = await dependencies.presetRepository.getAllPresets();
    final sessions = await dependencies.sessionRepository.getAllSessions();

    expect(presets, isEmpty);
    expect(sessions, isEmpty);
  });

  testWidgets('JSON backup restores presets and sessions', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Machine Learning',
        moodTag: 'Focused',
        durationMinutes: 40,
      ),
    );

    await dependencies.saveSessionLog(
      presetId: id,
      date: DateTime(2026, 10, 29),
      completedSeconds: 2400,
      status: 'completed',
    );

    final backupService = FocusBackupService(databaseHelper: helper);

    final json = await backupService.exportJson();

    await dependencies.presetRepository.deletePreset(id);

    expect(await dependencies.presetRepository.getAllPresets(), isEmpty);

    final result = await backupService.importJson(json);

    expect(result.presetCount, 1);
    expect(result.sessionCount, 1);

    final presets = await dependencies.presetRepository.getAllPresets();
    final sessions = await dependencies.sessionRepository.getAllSessions();

    expect(presets.length, 1);
    expect(presets.first.name, 'Machine Learning');

    expect(sessions.length, 1);
    expect(sessions.first.presetId, presets.first.id);
    expect(sessions.first.completedSeconds, 2400);
  });

  testWidgets('Invalid JSON does not remove existing data', (tester) async {
    await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Important Preset',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final backupService = FocusBackupService(databaseHelper: helper);

    await expectLater(
      backupService.importJson('invalid json'),
      throwsA(isA<FormatException>()),
    );

    final presets = await dependencies.presetRepository.getAllPresets();

    expect(presets.length, 1);
    expect(presets.first.name, 'Important Preset');
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_providers.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper helper;
  late FocusDependencies dependencies;
  late ProviderContainer container;

  setUp(() {
    helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    dependencies = FocusDependencies(databaseHelper: helper);

    container = ProviderContainer(
      overrides: [focusDependenciesProvider.overrideWithValue(dependencies)],
    );
  });

  tearDown(() async {
    container.dispose();
    await helper.close();
  });

  test('Preset provider refreshes after deletion', () async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final initial = await container.read(focusPresetsProvider.future);

    expect(initial.length, 1);

    await dependencies.presetRepository.deletePreset(id);

    container.invalidate(focusPresetsProvider);

    final updated = await container.read(focusPresetsProvider.future);

    expect(updated, isEmpty);
  });

  test('Session history refreshes after deletion', () async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Flutter',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final sessionId = await dependencies.saveSessionLog(
      presetId: id,
      date: DateTime(2026, 10, 28),
      completedSeconds: 1500,
      status: 'completed',
    );

    final initial = await container.read(sessionHistoryProvider.future);

    expect(initial.length, 1);

    await dependencies.sessionRepository.deleteSession(sessionId);

    container.invalidate(sessionHistoryProvider);

    final updated = await container.read(sessionHistoryProvider.future);

    expect(updated, isEmpty);
  });

  test('Session Scout falls back when history is deleted', () async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final sessionIds = <int>[];

    for (var i = 0; i < 3; i++) {
      final sessionId = await dependencies.saveSessionLog(
        presetId: id,
        date: DateTime(2026, 10, 20 + i),
        completedSeconds: (20 + i * 5) * 60,
        status: 'completed',
      );

      sessionIds.add(sessionId);
    }

    final before = await container.read(sessionScoutProvider('Focused').future);

    expect(before.usedFallback, false);
    expect(before.sessionsUsed, 3);
    expect(before.suggestedMinutes, 25);

    for (final sessionId in sessionIds) {
      await dependencies.sessionRepository.deleteSession(sessionId);
    }

    container.invalidate(sessionHistoryProvider);
    container.invalidate(sessionScoutProvider('Focused'));

    final after = await container.read(sessionScoutProvider('Focused').future);

    expect(after.usedFallback, true);
    expect(after.suggestedMinutes, 25);
  });

  test('Deleting a preset cascades to its sessions', () async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Reading',
        moodTag: 'Relaxed',
        durationMinutes: 30,
      ),
    );

    await dependencies.saveSessionLog(
      presetId: id,
      date: DateTime(2026, 10, 28),
      completedSeconds: 1800,
      status: 'completed',
    );

    await dependencies.presetRepository.deletePreset(id);

    container.invalidate(focusPresetsProvider);
    container.invalidate(sessionHistoryProvider);

    final presets = await container.read(focusPresetsProvider.future);

    final sessions = await container.read(sessionHistoryProvider.future);

    expect(presets, isEmpty);
    expect(sessions, isEmpty);
  });
}

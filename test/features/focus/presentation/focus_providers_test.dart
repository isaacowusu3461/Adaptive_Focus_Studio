
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

    dependencies = FocusDependencies(
      databaseHelper: helper,
    );

    container = ProviderContainer(
      overrides: [
        focusDependenciesProvider.overrideWithValue(dependencies),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await helper.close();
  });

  test('provides the existing dependency container', () {
    expect(
      container.read(focusDependenciesProvider),
      same(dependencies),
    );
  });

  test('provides the preset repository', () {
    expect(
      container.read(focusPresetRepositoryProvider),
      same(dependencies.presetRepository),
    );
  });

  test('provides the session repository', () {
    expect(
      container.read(sessionLogRepositoryProvider),
      same(dependencies.sessionRepository),
    );
  });

  test('provides the preset use cases', () {
    expect(
      container.read(createFocusPresetProvider),
      same(dependencies.createFocusPreset),
    );

    expect(
      container.read(updateFocusPresetProvider),
      same(dependencies.updateFocusPreset),
    );

    expect(
      container.read(deleteFocusPresetProvider),
      same(dependencies.deleteFocusPreset),
    );
  });

  test('provides the session use case', () {
    expect(
      container.read(saveSessionLogProvider),
      same(dependencies.saveSessionLog),
    );
  });

  test('loads an empty preset list', () async {
    final presets =
        await container.read(focusPresetsProvider.future);

    expect(presets, isEmpty);
  });

  test('loads an empty session history', () async {
    final sessions =
        await container.read(sessionHistoryProvider.future);

    expect(sessions, isEmpty);
  });

  test('loads saved presets after invalidation', () async {
    final initial =
        await container.read(focusPresetsProvider.future);

    expect(initial, isEmpty);

    await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    container.invalidate(focusPresetsProvider);

    final updated =
        await container.read(focusPresetsProvider.future);

    expect(updated.length, 1);
    expect(updated.first.name, 'Algorithms');
  });

  test('loads saved sessions after invalidation', () async {
    final presetId =
        await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Flutter',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final initial =
        await container.read(sessionHistoryProvider.future);

    expect(initial, isEmpty);

    await dependencies.saveSessionLog(
      presetId: presetId,
      date: DateTime(2026, 10, 27),
      completedSeconds: 1500,
      status: 'completed',
    );

    container.invalidate(sessionHistoryProvider);

    final updated =
        await container.read(sessionHistoryProvider.future);

    expect(updated.length, 1);
    expect(updated.first.completedSeconds, 1500);
  });

  test('Session Scout returns fallback with no history', () async {
    final recommendation = await container.read(
      sessionScoutProvider('Focused').future,
    );

    expect(recommendation.suggestedMinutes, 25);
    expect(recommendation.usedFallback, true);
  });

  test('Session Scout uses completed session history', () async {
    final presetId =
        await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    for (var i = 0; i < 3; i++) {
      await dependencies.saveSessionLog(
        presetId: presetId,
        date: DateTime(2026, 10, 20 + i),
        completedSeconds: (20 + i * 5) * 60,
        status: 'completed',
      );
    }

    final recommendation = await container.read(
      sessionScoutProvider('Focused').future,
    );

    expect(recommendation.suggestedMinutes, 25);
    expect(recommendation.sessionsUsed, 3);
    expect(recommendation.usedFallback, false);
  });

  test('different moods have separate recommendations', () async {
    final focused = await container.read(
      sessionScoutProvider('Focused').future,
    );

    final relaxed = await container.read(
      sessionScoutProvider('Relaxed').future,
    );

    expect(focused.moodTag, 'Focused');
    expect(relaxed.moodTag, 'Relaxed');
  });
}

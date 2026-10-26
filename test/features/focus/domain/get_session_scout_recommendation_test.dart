
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/data/repositories/focus_preset_repository_impl.dart';
import 'package:adaptive_focus_studio/features/focus/data/repositories/session_log_repository_impl.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/session_log.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/calculate_session_scout.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/get_session_scout_recommendation.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper databaseHelper;
  late FocusPresetRepositoryImpl presetRepository;
  late SessionLogRepositoryImpl sessionRepository;
  late GetSessionScoutRecommendation getRecommendation;

  setUp(() {
    databaseHelper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    presetRepository = FocusPresetRepositoryImpl(
      databaseHelper: databaseHelper,
    );

    sessionRepository = SessionLogRepositoryImpl(
      databaseHelper: databaseHelper,
    );

    getRecommendation = GetSessionScoutRecommendation(
      presetRepository: presetRepository,
      sessionRepository: sessionRepository,
      calculateSessionScout: CalculateSessionScout(),
    );
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  Future<int> addPreset({
    required String name,
    required String mood,
  }) {
    return presetRepository.createPreset(
      FocusPreset(
        name: name,
        moodTag: mood,
        durationMinutes: 25,
      ),
    );
  }

  Future<void> addSession({
    required int presetId,
    required int minutes,
    required int day,
    String status = 'completed',
  }) async {
    await sessionRepository.createSession(
      SessionLog(
        presetId: presetId,
        date: DateTime(2026, 10, day),
        completedSeconds: minutes * 60,
        status: status,
        notes: '',
      ),
    );
  }

  test('returns fallback when there is no history', () async {
    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 0);
    expect(result.usedFallback, true);
  });

  test('uses three completed sessions for matching mood', () async {
    final focusedId = await addPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addSession(
      presetId: focusedId,
      minutes: 20,
      day: 20,
    );
    await addSession(
      presetId: focusedId,
      minutes: 30,
      day: 21,
    );
    await addSession(
      presetId: focusedId,
      minutes: 25,
      day: 22,
    );

    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
    expect(result.usedFallback, false);
  });

  test('ignores sessions belonging to another mood', () async {
    final focusedId = await addPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    final relaxedId = await addPreset(
      name: 'Reading',
      mood: 'Relaxed',
    );

    await addSession(
      presetId: focusedId,
      minutes: 20,
      day: 20,
    );
    await addSession(
      presetId: focusedId,
      minutes: 25,
      day: 21,
    );
    await addSession(
      presetId: relaxedId,
      minutes: 50,
      day: 22,
    );
    await addSession(
      presetId: focusedId,
      minutes: 30,
      day: 23,
    );

    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
  });

  test('ignores partial sessions', () async {
    final presetId = await addPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addSession(
      presetId: presetId,
      minutes: 20,
      day: 20,
    );
    await addSession(
      presetId: presetId,
      minutes: 25,
      day: 21,
    );
    await addSession(
      presetId: presetId,
      minutes: 30,
      day: 22,
    );
    await addSession(
      presetId: presetId,
      minutes: 55,
      day: 23,
      status: 'partial',
    );

    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
  });

  test('selects the three most recent sessions', () async {
    final presetId = await addPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addSession(
      presetId: presetId,
      minutes: 55,
      day: 10,
    );
    await addSession(
      presetId: presetId,
      minutes: 50,
      day: 11,
    );
    await addSession(
      presetId: presetId,
      minutes: 20,
      day: 20,
    );
    await addSession(
      presetId: presetId,
      minutes: 30,
      day: 21,
    );
    await addSession(
      presetId: presetId,
      minutes: 25,
      day: 22,
    );

    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
  });

  test('combines sessions from presets with same mood', () async {
    final firstId = await addPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    final secondId = await addPreset(
      name: 'Flutter',
      mood: 'Focused',
    );

    await addSession(
      presetId: firstId,
      minutes: 20,
      day: 20,
    );
    await addSession(
      presetId: secondId,
      minutes: 25,
      day: 21,
    );
    await addSession(
      presetId: firstId,
      minutes: 30,
      day: 22,
    );

    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
  });

  test('falls back when only two completed sessions match', () async {
    final presetId = await addPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addSession(
      presetId: presetId,
      minutes: 35,
      day: 20,
    );
    await addSession(
      presetId: presetId,
      minutes: 40,
      day: 21,
    );

    final result = await getRecommendation(
      moodTag: 'Focused',
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 2);
    expect(result.usedFallback, true);
  });

  test('clamps high durations to 60 minutes', () async {
    final presetId = await addPreset(
      name: 'Long Study',
      mood: 'Motivated',
    );

    await addSession(
      presetId: presetId,
      minutes: 70,
      day: 20,
    );
    await addSession(
      presetId: presetId,
      minutes: 80,
      day: 21,
    );
    await addSession(
      presetId: presetId,
      minutes: 90,
      day: 22,
    );

    final result = await getRecommendation(
      moodTag: 'Motivated',
    );

    expect(result.suggestedMinutes, 60);
    expect(result.usedFallback, false);
  });

  test('rejects an empty mood', () async {
    await expectLater(
      getRecommendation(moodTag: '  '),
      throwsArgumentError,
    );
  });
}

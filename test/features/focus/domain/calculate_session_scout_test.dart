
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/usecases/calculate_session_scout.dart';

void main() {
  late CalculateSessionScout calculate;

  setUp(() {
    calculate = CalculateSessionScout();
  });

  test('calculates median of three sessions', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        20 * 60,
        30 * 60,
        25 * 60,
      ],
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
    expect(result.usedFallback, false);
  });

  test('uses three most recent sessions only', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        20 * 60,
        30 * 60,
        25 * 60,
        55 * 60,
        60 * 60,
      ],
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 3);
  });

  test('uses fallback when no sessions exist', () {
    final result = calculate(
      moodTag: 'Relaxed',
      recentCompletedSeconds: [],
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 0);
    expect(result.usedFallback, true);
  });

  test('uses fallback when only one session exists', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [40 * 60],
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 1);
    expect(result.usedFallback, true);
  });

  test('uses fallback when only two sessions exist', () {
    final result = calculate(
      moodTag: 'Motivated',
      recentCompletedSeconds: [
        35 * 60,
        45 * 60,
      ],
    );

    expect(result.suggestedMinutes, 25);
    expect(result.sessionsUsed, 2);
    expect(result.usedFallback, true);
  });

  test('clamps a short median to 10 minutes', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        2 * 60,
        5 * 60,
        8 * 60,
      ],
    );

    expect(result.suggestedMinutes, 10);
    expect(result.usedFallback, false);
  });

  test('clamps a long median to 60 minutes', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        70 * 60,
        90 * 60,
        80 * 60,
      ],
    );

    expect(result.suggestedMinutes, 60);
    expect(result.usedFallback, false);
  });

  test('allows the minimum duration boundary', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        9 * 60,
        10 * 60,
        11 * 60,
      ],
    );

    expect(result.suggestedMinutes, 10);
  });

  test('allows the maximum duration boundary', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        55 * 60,
        60 * 60,
        65 * 60,
      ],
    );

    expect(result.suggestedMinutes, 60);
  });

  test('rounds median seconds to nearest minute', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        20 * 60,
        25 * 60 + 40,
        30 * 60,
      ],
    );

    expect(result.suggestedMinutes, 26);
  });

  test('does not modify the input list', () {
    final durations = [
      30 * 60,
      20 * 60,
      25 * 60,
    ];

    calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: durations,
    );

    expect(durations, [
      30 * 60,
      20 * 60,
      25 * 60,
    ]);
  });

  test('trims the mood tag', () {
    final result = calculate(
      moodTag: '  Focused  ',
      recentCompletedSeconds: [
        20 * 60,
        25 * 60,
        30 * 60,
      ],
    );

    expect(result.moodTag, 'Focused');
  });

  test('rejects an empty mood tag', () {
    expect(
      () => calculate(
        moodTag: '   ',
        recentCompletedSeconds: [],
      ),
      throwsArgumentError,
    );
  });

  test('rejects negative session durations', () {
    expect(
      () => calculate(
        moodTag: 'Focused',
        recentCompletedSeconds: [
          20 * 60,
          -1,
          30 * 60,
        ],
      ),
      throwsArgumentError,
    );
  });

  test('includes explanation for personalized result', () {
    final result = calculate(
      moodTag: 'Focused',
      recentCompletedSeconds: [
        20 * 60,
        25 * 60,
        30 * 60,
      ],
    );

    expect(result.explanation, contains('Focused'));
    expect(result.explanation, contains('25 minutes'));
    expect(result.explanation, contains('median'));
  });

  test('includes explanation for fallback result', () {
    final result = calculate(
      moodTag: 'Relaxed',
      recentCompletedSeconds: [],
    );

    expect(
      result.explanation,
      contains('Not enough completed'),
    );
    expect(result.explanation, contains('25-minute'));
  });
}

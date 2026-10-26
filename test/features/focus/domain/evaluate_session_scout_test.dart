
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/entities/session_scout_evaluation_case.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/calculate_session_scout.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/evaluate_session_scout.dart';

void main() {
  late EvaluateSessionScout evaluate;

  setUp(() {
    evaluate = EvaluateSessionScout(
      CalculateSessionScout(),
    );
  });

  SessionScoutEvaluationCase makeCase({
    String name = 'Test Case',
    String mood = 'Focused',
    List<int> durations = const [1200, 1500, 1800],
    int actual = 28,
  }) {
    return SessionScoutEvaluationCase(
      name: name,
      moodTag: mood,
      recentCompletedSeconds: durations,
      actualDurationMinutes: actual,
    );
  }

  final sampleCases = [
    const SessionScoutEvaluationCase(
      name: 'Case 1 - Focused',
      moodTag: 'Focused',
      recentCompletedSeconds: [1200, 1500, 1800],
      actualDurationMinutes: 28,
    ),
    const SessionScoutEvaluationCase(
      name: 'Case 2 - Motivated',
      moodTag: 'Motivated',
      recentCompletedSeconds: [1800, 2100, 2400],
      actualDurationMinutes: 38,
    ),
    const SessionScoutEvaluationCase(
      name: 'Case 3 - Relaxed',
      moodTag: 'Relaxed',
      recentCompletedSeconds: [2400, 2700, 3000],
      actualDurationMinutes: 47,
    ),
    const SessionScoutEvaluationCase(
      name: 'Case 4 - Focused',
      moodTag: 'Focused',
      recentCompletedSeconds: [600, 900, 1200],
      actualDurationMinutes: 18,
    ),
    const SessionScoutEvaluationCase(
      name: 'Case 5 - Motivated',
      moodTag: 'Motivated',
      recentCompletedSeconds: [3000, 3300, 3600],
      actualDurationMinutes: 58,
    ),
    const SessionScoutEvaluationCase(
      name: 'Case 6 - Fallback',
      moodTag: 'Relaxed',
      recentCompletedSeconds: [],
      actualDurationMinutes: 25,
    ),
  ];

  test('evaluates six sample cases', () {
    final result = evaluate(sampleCases);

    expect(result.caseCount, 6);
    expect(result.cases.length, 6);
  });

  test('uses the correct Scout predictions', () {
    final result = evaluate(sampleCases);

    expect(
      result.cases.map((c) => c.scoutMinutes).toList(),
      [25, 35, 45, 15, 55, 25],
    );
  });

  test('always uses 25-minute baseline', () {
    final result = evaluate(sampleCases);

    expect(
      result.cases.every(
        (c) => c.baselineMinutes == 25,
      ),
      true,
    );
  });

  test('calculates absolute errors correctly', () {
    final result = evaluate(sampleCases);

    expect(
      result.cases.map((c) => c.scoutAbsoluteError).toList(),
      [3, 3, 2, 3, 3, 0],
    );

    expect(
      result.cases
          .map((c) => c.baselineAbsoluteError)
          .toList(),
      [3, 13, 22, 7, 33, 0],
    );
  });

  test('calculates Scout mean absolute error', () {
    final result = evaluate(sampleCases);

    expect(
      result.scoutMeanAbsoluteError,
      closeTo(14 / 6, 0.0001),
    );
  });

  test('calculates baseline mean absolute error', () {
    final result = evaluate(sampleCases);

    expect(
      result.baselineMeanAbsoluteError,
      closeTo(78 / 6, 0.0001),
    );
  });

  test('calculates relative error improvement', () {
    final result = evaluate(sampleCases);

    expect(
      result.improvementPercentage,
      closeTo(82.0513, 0.001),
    );
  });

  test('identifies Scout as better on sample data', () {
    final result = evaluate(sampleCases);

    expect(result.betterMethod, 'Session Scout');
  });

  test('identifies baseline as better when appropriate', () {
    final result = evaluate([
      makeCase(
        durations: [2400, 2700, 3000],
        actual: 25,
      ),
    ]);

    expect(result.betterMethod, 'Fixed 25-minute baseline');
  });

  test('identifies a tie', () {
    final result = evaluate([
      makeCase(
        durations: [1200, 1500, 1800],
        actual: 25,
      ),
    ]);

    expect(result.betterMethod, 'Tie');
    expect(result.improvementPercentage, 0);
  });

  test('handles zero baseline error', () {
    final result = evaluate([
      makeCase(
        durations: [2400, 2700, 3000],
        actual: 25,
      ),
    ]);

    expect(result.baselineMeanAbsoluteError, 0);
    expect(result.improvementPercentage, 0);
  });

  test('records fallback usage', () {
    final result = evaluate(sampleCases);

    expect(result.cases.last.usedFallback, true);
    expect(result.cases.first.usedFallback, false);
  });

  test('rejects an empty evaluation list', () {
    expect(
      () => evaluate([]),
      throwsArgumentError,
    );
  });

  test('rejects an empty case name', () {
    expect(
      () => evaluate([
        makeCase(name: '  '),
      ]),
      throwsArgumentError,
    );
  });

  test('rejects zero actual duration', () {
    expect(
      () => evaluate([
        makeCase(actual: 0),
      ]),
      throwsArgumentError,
    );
  });

  test('rejects negative actual duration', () {
    expect(
      () => evaluate([
        makeCase(actual: -5),
      ]),
      throwsArgumentError,
    );
  });

  test('rejects negative historical durations', () {
    expect(
      () => evaluate([
        makeCase(
          durations: [1200, -60, 1800],
        ),
      ]),
      throwsArgumentError,
    );
  });
}

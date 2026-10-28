
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/usecases/calculate_study_statistics.dart';

void main() {
  Map<String, Object?> session(
    String status,
    int seconds,
  ) {
    return {
      'status': status,
      'completedSeconds': seconds,
    };
  }

  test('returns zero statistics for empty history', () {
    final result = calculateStudyStatistics([]);

    expect(result.totalSessions, 0);
    expect(result.completedSessions, 0);
    expect(result.partialSessions, 0);
    expect(result.totalSeconds, 0);
    expect(result.averageMinutes, 0);
    expect(result.longestSessionSeconds, 0);
    expect(result.completionRate, 0);
  });

  test('calculates one completed session', () {
    final result = calculateStudyStatistics([
      session('completed', 1500),
    ]);

    expect(result.totalSessions, 1);
    expect(result.completedSessions, 1);
    expect(result.partialSessions, 0);
    expect(result.totalMinutes, 25);
    expect(result.averageMinutes, 25);
    expect(result.completionRate, 100);
  });

  test('calculates completed and partial sessions', () {
    final result = calculateStudyStatistics([
      session('completed', 1200),
      session('partial', 600),
      session('completed', 1800),
    ]);

    expect(result.totalSessions, 3);
    expect(result.completedSessions, 2);
    expect(result.partialSessions, 1);
    expect(result.totalSeconds, 3600);
    expect(result.totalMinutes, 60);
    expect(result.averageMinutes, 20);
    expect(result.longestSessionMinutes, 30);
    expect(result.completionRate, closeTo(66.67, 0.01));
  });

  test('calculates total time from partial sessions', () {
    final result = calculateStudyStatistics([
      session('partial', 600),
      session('partial', 900),
    ]);

    expect(result.totalMinutes, 25);
    expect(result.completedSessions, 0);
    expect(result.partialSessions, 2);
    expect(result.completionRate, 0);
  });

  test('finds the longest session', () {
    final result = calculateStudyStatistics([
      session('completed', 900),
      session('completed', 3600),
      session('partial', 1200),
    ]);

    expect(result.longestSessionSeconds, 3600);
  });

  test('calculates fractional average minutes', () {
    final result = calculateStudyStatistics([
      session('completed', 1200),
      session('completed', 1500),
      session('completed', 1800),
    ]);

    expect(result.averageMinutes, 25);
  });

  test('handles zero-second partial sessions', () {
    final result = calculateStudyStatistics([
      session('partial', 0),
    ]);

    expect(result.totalSeconds, 0);
    expect(result.averageMinutes, 0);
    expect(result.partialSessions, 1);
  });

  test('rejects negative duration', () {
    expect(
      () => calculateStudyStatistics([
        session('completed', -60),
      ]),
      throwsArgumentError,
    );
  });

  test('rejects invalid status', () {
    expect(
      () => calculateStudyStatistics([
        session('unknown', 1200),
      ]),
      throwsArgumentError,
    );
  });

  test('does not modify input session list', () {
    final sessions = [
      session('completed', 1500),
      session('partial', 600),
    ];

    calculateStudyStatistics(sessions);

    expect(sessions.length, 2);
    expect(sessions.first['completedSeconds'], 1500);
  });
}

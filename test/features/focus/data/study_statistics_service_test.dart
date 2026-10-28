
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/data/services/study_statistics_service.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/session_log.dart';

void main() {
  late StudyStatisticsService service;

  setUp(() {
    service = StudyStatisticsService();
  });

  SessionLog makeSession({
    int presetId = 1,
    int seconds = 1500,
    String status = 'completed',
  }) {
    return SessionLog(
      presetId: presetId,
      date: DateTime(2026, 10, 28),
      completedSeconds: seconds,
      status: status,
      notes: '',
    );
  }

  test('calculates empty statistics in isolate', () async {
    final result = await service.calculate([]);

    expect(result.totalSessions, 0);
    expect(result.totalSeconds, 0);
  });

  test('calculates multiple sessions in isolate', () async {
    final result = await service.calculate([
      makeSession(seconds: 1200),
      makeSession(seconds: 1800),
      makeSession(
        seconds: 600,
        status: 'partial',
      ),
    ]);

    expect(result.totalSessions, 3);
    expect(result.completedSessions, 2);
    expect(result.partialSessions, 1);
    expect(result.totalMinutes, 60);
    expect(result.averageMinutes, 20);
    expect(result.longestSessionMinutes, 30);
  });

  test('handles a larger collection of sessions', () async {
    final sessions = List.generate(
      1000,
      (index) => makeSession(
        seconds: 1500,
      ),
    );

    final result = await service.calculate(sessions);

    expect(result.totalSessions, 1000);
    expect(result.completedSessions, 1000);
    expect(result.totalSeconds, 1500000);
    expect(result.averageMinutes, 25);
    expect(result.completionRate, 100);
  });

  test('propagates invalid session errors', () async {
    await expectLater(
      service.calculate([
        makeSession(seconds: -30),
      ]),
      throwsArgumentError,
    );
  });

  test('does not modify original session data', () async {
    final sessions = [
      makeSession(seconds: 1200),
      makeSession(seconds: 1800),
    ];

    await service.calculate(sessions);

    expect(sessions.length, 2);
    expect(sessions.first.completedSeconds, 1200);
  });
}


import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/features/focus/domain/entities/session_log.dart';
import 'package:adaptive_focus_studio/features/focus/domain/repositories/session_log_repository.dart';
import 'package:adaptive_focus_studio/features/focus/domain/usecases/save_session_log.dart';

class FakeSessionRepository implements SessionLogRepository {
  SessionLog? savedSession;

  @override
  Future<int> createSession(SessionLog session) async {
    savedSession = session;
    return 1;
  }

  @override
  Future<List<SessionLog>> getAllSessions() async => [];

  @override
  Future<SessionLog?> getSessionById(int id) async => null;

  @override
  Future<int> updateSession(SessionLog session) async => 0;

  @override
  Future<int> deleteSession(int id) async => 0;
}

void main() {
  late FakeSessionRepository repository;
  late SaveSessionLog saveSession;

  setUp(() {
    repository = FakeSessionRepository();
    saveSession = SaveSessionLog(repository);
  });

  test('saves a completed session', () async {
    final id = await saveSession(
      presetId: 1,
      date: DateTime(2026, 10, 26),
      completedSeconds: 1500,
      status: 'completed',
      notes: '  Good progress  ',
    );

    expect(id, 1);
    expect(repository.savedSession!.status, 'completed');
    expect(repository.savedSession!.completedSeconds, 1500);
    expect(repository.savedSession!.notes, 'Good progress');
  });

  test('saves a partial session', () async {
    await saveSession(
      presetId: 1,
      date: DateTime.now(),
      completedSeconds: 300,
      status: 'partial',
    );

    expect(repository.savedSession!.status, 'partial');
  });

  test('rejects an invalid preset ID', () async {
    await expectLater(
      saveSession(
        presetId: 0,
        date: DateTime.now(),
        completedSeconds: 300,
        status: 'partial',
      ),
      throwsArgumentError,
    );
  });

  test('rejects negative seconds', () async {
    await expectLater(
      saveSession(
        presetId: 1,
        date: DateTime.now(),
        completedSeconds: -5,
        status: 'completed',
      ),
      throwsArgumentError,
    );
  });

  test('rejects invalid status', () async {
    await expectLater(
      saveSession(
        presetId: 1,
        date: DateTime.now(),
        completedSeconds: 300,
        status: 'stopped',
      ),
      throwsArgumentError,
    );
  });
}

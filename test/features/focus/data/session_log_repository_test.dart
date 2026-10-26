
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/data/repositories/session_log_repository_impl.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/session_log.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper helper;
  late SessionLogRepositoryImpl repository;
  late int presetId;

  setUp(() async {
    helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    repository = SessionLogRepositoryImpl(
      databaseHelper: helper,
    );

    final db = await helper.database;

    presetId = await db.insert(
      DatabaseHelper.presetsTable,
      {
        'name': 'Algorithms',
        'mood_tag': 'Focused',
        'duration_minutes': 25,
      },
    );
  });

  tearDown(() async {
    await helper.close();
  });

  SessionLog sampleSession({
    int? id,
    int? seconds,
    String status = 'completed',
    String notes = '',
  }) {
    return SessionLog(
      id: id,
      presetId: presetId,
      date: DateTime(2026, 10, 26, 10),
      completedSeconds: seconds ?? 1500,
      status: status,
      notes: notes,
    );
  }

  test('creates and retrieves a session', () async {
    final id = await repository.createSession(
      sampleSession(),
    );

    final saved = await repository.getSessionById(id);

    expect(id, greaterThan(0));
    expect(saved, isNotNull);
    expect(saved!.completedSeconds, 1500);
    expect(saved.status, 'completed');
  });

  test('retrieves all sessions', () async {
    await repository.createSession(sampleSession());
    await repository.createSession(
      sampleSession(seconds: 600, status: 'partial'),
    );

    final sessions = await repository.getAllSessions();

    expect(sessions.length, 2);
  });

  test('updates an existing session', () async {
    final id = await repository.createSession(
      sampleSession(),
    );

    final rows = await repository.updateSession(
      sampleSession(
        id: id,
        seconds: 900,
        status: 'partial',
        notes: 'Stopped early',
      ),
    );

    final saved = await repository.getSessionById(id);

    expect(rows, 1);
    expect(saved!.completedSeconds, 900);
    expect(saved.status, 'partial');
    expect(saved.notes, 'Stopped early');
  });

  test('deletes a session', () async {
    final id = await repository.createSession(
      sampleSession(),
    );

    final rows = await repository.deleteSession(id);
    final saved = await repository.getSessionById(id);

    expect(rows, 1);
    expect(saved, isNull);
  });

  test('returns null for a missing session', () async {
    expect(await repository.getSessionById(999), isNull);
  });

  test('rejects negative duration', () async {
    await expectLater(
      repository.createSession(
        sampleSession(seconds: -1),
      ),
      throwsArgumentError,
    );
  });

  test('rejects invalid status', () async {
    await expectLater(
      repository.createSession(
        sampleSession(status: 'unknown'),
      ),
      throwsArgumentError,
    );
  });

  test('rejects an invalid preset reference', () async {
    await expectLater(
      repository.createSession(
        SessionLog(
          presetId: 999,
          date: DateTime.now(),
          completedSeconds: 600,
          status: 'completed',
        ),
      ),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('deleting a preset cascades to its sessions', () async {
    await repository.createSession(sampleSession());

    final db = await helper.database;

    await db.delete(
      DatabaseHelper.presetsTable,
      where: 'id = ?',
      whereArgs: [presetId],
    );

    expect(await repository.getAllSessions(), isEmpty);
  });

  test('returns zero when deleting a missing session', () async {
    expect(await repository.deleteSession(999), 0);
  });
}

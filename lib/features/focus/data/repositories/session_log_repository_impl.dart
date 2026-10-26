
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/session_log.dart';
import '../../domain/repositories/session_log_repository.dart';
import '../datasources/database_helper.dart';
import '../models/session_log_model.dart';

class SessionLogRepositoryImpl implements SessionLogRepository {
  final DatabaseHelper databaseHelper;

  SessionLogRepositoryImpl({
    required this.databaseHelper,
  });

  @override
  Future<List<SessionLog>> getAllSessions() async {
    final db = await databaseHelper.database;

    final rows = await db.query(
      DatabaseHelper.sessionsTable,
      orderBy: 'date DESC, id DESC',
    );

    return rows
        .map((row) => SessionLogModel.fromMap(row))
        .toList();
  }

  @override
  Future<SessionLog?> getSessionById(int id) async {
    final db = await databaseHelper.database;

    final rows = await db.query(
      DatabaseHelper.sessionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return SessionLogModel.fromMap(rows.first);
  }

  @override
  Future<int> createSession(SessionLog session) async {
    _validateSession(session);

    final db = await databaseHelper.database;
    final data = SessionLogModel.fromEntity(session).toMap();

    data.remove('id');

    return db.insert(
      DatabaseHelper.sessionsTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<int> updateSession(SessionLog session) async {
    if (session.id == null || session.id! <= 0) {
      throw ArgumentError(
        'A valid session ID is required.',
      );
    }

    _validateSession(session);

    final db = await databaseHelper.database;
    final data = SessionLogModel.fromEntity(session).toMap();

    data.remove('id');

    return db.update(
      DatabaseHelper.sessionsTable,
      data,
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  @override
  Future<int> deleteSession(int id) async {
    if (id <= 0) {
      throw ArgumentError(
        'A valid session ID is required.',
      );
    }

    final db = await databaseHelper.database;

    return db.delete(
      DatabaseHelper.sessionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _validateSession(SessionLog session) {
    if (session.presetId <= 0) {
      throw ArgumentError('Invalid preset ID.');
    }

    if (session.completedSeconds < 0) {
      throw ArgumentError(
        'Completed seconds cannot be negative.',
      );
    }

    if (session.status != 'completed' &&
        session.status != 'partial') {
      throw ArgumentError(
        'Status must be completed or partial.',
      );
    }
  }
}

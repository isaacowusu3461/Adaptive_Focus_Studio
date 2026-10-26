
import '../entities/session_log.dart';

abstract class SessionLogRepository {
  Future<List<SessionLog>> getAllSessions();

  Future<SessionLog?> getSessionById(int id);

  Future<int> createSession(SessionLog session);

  Future<int> updateSession(SessionLog session);

  Future<int> deleteSession(int id);
}

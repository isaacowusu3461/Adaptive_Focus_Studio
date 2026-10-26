
import '../entities/session_log.dart';
import '../repositories/session_log_repository.dart';

class SaveSessionLog {
  final SessionLogRepository repository;

  SaveSessionLog(this.repository);

  Future<int> call({
    required int presetId,
    required DateTime date,
    required int completedSeconds,
    required String status,
    String notes = '',
  }) async {
    if (presetId <= 0) {
      throw ArgumentError('Invalid preset ID.');
    }

    if (completedSeconds < 0) {
      throw ArgumentError(
        'Completed seconds cannot be negative.',
      );
    }

    if (status != 'completed' && status != 'partial') {
      throw ArgumentError('Invalid session status.');
    }

    final session = SessionLog(
      presetId: presetId,
      date: date,
      completedSeconds: completedSeconds,
      status: status,
      notes: notes.trim(),
    );

    return repository.createSession(session);
  }
}

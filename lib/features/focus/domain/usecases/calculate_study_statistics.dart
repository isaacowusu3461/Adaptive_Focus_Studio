
import '../entities/study_statistics.dart';

StudyStatistics calculateStudyStatistics(
  List<Map<String, Object?>> sessions,
) {
  if (sessions.isEmpty) {
    return const StudyStatistics.empty();
  }

  var completed = 0;
  var partial = 0;
  var totalSeconds = 0;
  var longestSeconds = 0;

  for (final session in sessions) {
    final status = session['status'] as String;
    final seconds = session['completedSeconds'] as int;

    if (seconds < 0) {
      throw ArgumentError(
        'Session duration cannot be negative.',
      );
    }

    if (status == 'completed') {
      completed++;
    } else if (status == 'partial') {
      partial++;
    } else {
      throw ArgumentError('Invalid session status.');
    }

    totalSeconds += seconds;

    if (seconds > longestSeconds) {
      longestSeconds = seconds;
    }
  }

  return StudyStatistics(
    totalSessions: sessions.length,
    completedSessions: completed,
    partialSessions: partial,
    totalSeconds: totalSeconds,
    averageMinutes:
        totalSeconds / sessions.length / 60,
    longestSessionSeconds: longestSeconds,
  );
}

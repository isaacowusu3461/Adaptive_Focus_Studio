
import 'dart:isolate';

import '../../domain/entities/session_log.dart';
import '../../domain/entities/study_statistics.dart';
import '../../domain/usecases/calculate_study_statistics.dart';

class StudyStatisticsService {
  Future<StudyStatistics> calculate(
    List<SessionLog> sessions,
  ) async {
    final sessionData = sessions.map((session) {
      return <String, Object?>{
        'status': session.status,
        'completedSeconds': session.completedSeconds,
      };
    }).toList();

    return Isolate.run(
      () => calculateStudyStatistics(sessionData),
    );
  }
}

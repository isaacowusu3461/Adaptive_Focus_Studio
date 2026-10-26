
import '../entities/session_scout_recommendation.dart';
import '../repositories/focus_preset_repository.dart';
import '../repositories/session_log_repository.dart';
import 'calculate_session_scout.dart';

class GetSessionScoutRecommendation {
  final FocusPresetRepository presetRepository;
  final SessionLogRepository sessionRepository;
  final CalculateSessionScout calculateSessionScout;

  GetSessionScoutRecommendation({
    required this.presetRepository,
    required this.sessionRepository,
    required this.calculateSessionScout,
  });

  Future<SessionScoutRecommendation> call({
    required String moodTag,
  }) async {
    final mood = moodTag.trim();

    if (mood.isEmpty) {
      throw ArgumentError('Mood tag cannot be empty.');
    }

    final presets = await presetRepository.getAllPresets();
    final sessions = await sessionRepository.getAllSessions();

    final matchingPresetIds = presets
        .where((preset) => preset.moodTag == mood)
        .map((preset) => preset.id)
        .whereType<int>()
        .toSet();

    final matchingSessions = sessions.where((session) {
      return session.status == 'completed' &&
          matchingPresetIds.contains(session.presetId);
    }).toList();

    // Explicitly sort by date so the newest sessions come first.
    matchingSessions.sort(
      (first, second) => second.date.compareTo(first.date),
    );

    final recentDurations = matchingSessions
        .take(CalculateSessionScout.requiredSessions)
        .map((session) => session.completedSeconds)
        .toList();

    return calculateSessionScout(
      moodTag: mood,
      recentCompletedSeconds: recentDurations,
    );
  }
}

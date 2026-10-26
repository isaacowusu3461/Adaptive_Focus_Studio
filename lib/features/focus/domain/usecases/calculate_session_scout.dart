
import '../entities/session_scout_recommendation.dart';

class CalculateSessionScout {
  static const int minimumMinutes = 10;
  static const int maximumMinutes = 60;
  static const int fallbackMinutes = 25;
  static const int requiredSessions = 3;

  SessionScoutRecommendation call({
    required String moodTag,
    required List<int> recentCompletedSeconds,
  }) {
    final mood = moodTag.trim();

    if (mood.isEmpty) {
      throw ArgumentError('Mood tag cannot be empty.');
    }

    if (recentCompletedSeconds.any((seconds) => seconds < 0)) {
      throw ArgumentError(
        'Session durations cannot be negative.',
      );
    }

    if (recentCompletedSeconds.length < requiredSessions) {
      return SessionScoutRecommendation(
        moodTag: mood,
        suggestedMinutes: fallbackMinutes,
        explanation:
            'Not enough completed $mood sessions yet. '
            'Using the standard 25-minute focus duration.',
        sessionsUsed: recentCompletedSeconds.length,
        usedFallback: true,
      );
    }

    // The input is ordered from most recent to oldest.
    final recentThree = recentCompletedSeconds
        .take(requiredSessions)
        .toList();

    // Sorting a copy lets us find the median without
    // changing the original session order.
    final sorted = List<int>.from(recentThree)..sort();

    final medianSeconds = sorted[1];

    // Round to the nearest whole minute.
    final medianMinutes = (medianSeconds / 60).round();

    // Keep suggestions within the allowed duration range.
    final suggestedMinutes = medianMinutes.clamp(
      minimumMinutes,
      maximumMinutes,
    );

    return SessionScoutRecommendation(
      moodTag: mood,
      suggestedMinutes: suggestedMinutes,
      explanation:
          'Based on your three most recent completed '
          '$mood sessions, your median study duration '
          'was $medianMinutes minutes. '
          'Session Scout recommends $suggestedMinutes minutes.',
      sessionsUsed: requiredSessions,
      usedFallback: false,
    );
  }
}

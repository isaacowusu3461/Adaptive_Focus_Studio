
class SessionScoutRecommendation {
  final String moodTag;
  final int suggestedMinutes;
  final String explanation;
  final int sessionsUsed;
  final bool usedFallback;

  const SessionScoutRecommendation({
    required this.moodTag,
    required this.suggestedMinutes,
    required this.explanation,
    required this.sessionsUsed,
    required this.usedFallback,
  });
}

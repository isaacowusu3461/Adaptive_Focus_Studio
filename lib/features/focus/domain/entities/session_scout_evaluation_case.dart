
class SessionScoutEvaluationCase {
  final String name;
  final String moodTag;
  final List<int> recentCompletedSeconds;
  final int actualDurationMinutes;

  const SessionScoutEvaluationCase({
    required this.name,
    required this.moodTag,
    required this.recentCompletedSeconds,
    required this.actualDurationMinutes,
  });
}

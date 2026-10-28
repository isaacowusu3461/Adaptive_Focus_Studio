
class StudyStatistics {
  final int totalSessions;
  final int completedSessions;
  final int partialSessions;
  final int totalSeconds;
  final double averageMinutes;
  final int longestSessionSeconds;

  const StudyStatistics({
    required this.totalSessions,
    required this.completedSessions,
    required this.partialSessions,
    required this.totalSeconds,
    required this.averageMinutes,
    required this.longestSessionSeconds,
  });

  const StudyStatistics.empty()
      : totalSessions = 0,
        completedSessions = 0,
        partialSessions = 0,
        totalSeconds = 0,
        averageMinutes = 0,
        longestSessionSeconds = 0;

  double get totalMinutes => totalSeconds / 60;

  double get longestSessionMinutes =>
      longestSessionSeconds / 60;

  double get completionRate {
    if (totalSessions == 0) {
      return 0;
    }

    return completedSessions / totalSessions * 100;
  }
}

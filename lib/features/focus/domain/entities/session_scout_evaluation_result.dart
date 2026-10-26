
class SessionScoutCaseResult {
  final String name;
  final String moodTag;
  final int actualMinutes;
  final int scoutMinutes;
  final int baselineMinutes;
  final int scoutAbsoluteError;
  final int baselineAbsoluteError;
  final bool usedFallback;

  const SessionScoutCaseResult({
    required this.name,
    required this.moodTag,
    required this.actualMinutes,
    required this.scoutMinutes,
    required this.baselineMinutes,
    required this.scoutAbsoluteError,
    required this.baselineAbsoluteError,
    required this.usedFallback,
  });
}

class SessionScoutEvaluationResult {
  final List<SessionScoutCaseResult> cases;
  final double scoutMeanAbsoluteError;
  final double baselineMeanAbsoluteError;

  const SessionScoutEvaluationResult({
    required this.cases,
    required this.scoutMeanAbsoluteError,
    required this.baselineMeanAbsoluteError,
  });

  int get caseCount => cases.length;

  double get improvementPercentage {
    if (baselineMeanAbsoluteError == 0) {
      return 0;
    }

    return (baselineMeanAbsoluteError -
            scoutMeanAbsoluteError) /
        baselineMeanAbsoluteError *
        100;
  }

  String get betterMethod {
    if (scoutMeanAbsoluteError <
        baselineMeanAbsoluteError) {
      return 'Session Scout';
    }

    if (baselineMeanAbsoluteError <
        scoutMeanAbsoluteError) {
      return 'Fixed 25-minute baseline';
    }

    return 'Tie';
  }
}


import '../entities/session_scout_evaluation_case.dart';
import '../entities/session_scout_evaluation_result.dart';
import 'calculate_session_scout.dart';

class EvaluateSessionScout {
  final CalculateSessionScout calculateSessionScout;

  EvaluateSessionScout(this.calculateSessionScout);

  SessionScoutEvaluationResult call(
    List<SessionScoutEvaluationCase> evaluationCases,
  ) {
    if (evaluationCases.isEmpty) {
      throw ArgumentError(
        'At least one evaluation case is required.',
      );
    }

    final results = <SessionScoutCaseResult>[];

    var totalScoutError = 0;
    var totalBaselineError = 0;

    for (final evaluationCase in evaluationCases) {
      if (evaluationCase.name.trim().isEmpty) {
        throw ArgumentError(
          'Evaluation case name cannot be empty.',
        );
      }

      if (evaluationCase.actualDurationMinutes <= 0) {
        throw ArgumentError(
          'Actual duration must be greater than zero.',
        );
      }

      final recommendation = calculateSessionScout(
        moodTag: evaluationCase.moodTag,
        recentCompletedSeconds:
            evaluationCase.recentCompletedSeconds,
      );

      const baselineMinutes =
          CalculateSessionScout.fallbackMinutes;

      final scoutError = (recommendation.suggestedMinutes -
              evaluationCase.actualDurationMinutes)
          .abs();

      final baselineError = (baselineMinutes -
              evaluationCase.actualDurationMinutes)
          .abs();

      totalScoutError += scoutError;
      totalBaselineError += baselineError;

      results.add(
        SessionScoutCaseResult(
          name: evaluationCase.name,
          moodTag: evaluationCase.moodTag,
          actualMinutes:
              evaluationCase.actualDurationMinutes,
          scoutMinutes: recommendation.suggestedMinutes,
          baselineMinutes: baselineMinutes,
          scoutAbsoluteError: scoutError,
          baselineAbsoluteError: baselineError,
          usedFallback: recommendation.usedFallback,
        ),
      );
    }

    return SessionScoutEvaluationResult(
      cases: results,
      scoutMeanAbsoluteError:
          totalScoutError / evaluationCases.length,
      baselineMeanAbsoluteError:
          totalBaselineError / evaluationCases.length,
    );
  }
}


# AI Feature - Session Scout

## 1. Overview

Session Scout is the intelligent recommendation
feature in Adaptive Focus Studio.

It suggests a study duration based on a student's
previously completed focus sessions.

The goal is to provide a more personalized
recommendation than using the same fixed duration
for every session.

Session Scout is a rule-based recommendation
algorithm. It does not use a trained machine
learning model or a generative AI service.

## 2. Problem

Students may prefer different study durations
depending on their mood and previous study habits.

A fixed 25-minute duration does not adapt to
these differences.

Session Scout attempts to address this by using
recent completed study sessions to recommend
a suitable duration.

## 3. Inputs

The algorithm uses:

- Selected mood
- Saved focus presets
- Completed study sessions
- Completed duration in seconds
- Session date

Supported moods:

- Focused
- Relaxed
- Motivated

Partial sessions are excluded from the
recommendation calculation.

## 4. Recommendation Algorithm

The algorithm performs these steps:

1. Retrieve saved focus presets and session logs.
2. Find presets matching the selected mood.
3. Select completed sessions linked to those presets.
4. Sort the matching sessions from newest to oldest.
5. Select the three most recent completed sessions.
6. Calculate the median completed duration.
7. Round the median to the nearest whole minute.
8. Limit the recommendation to 10-60 minutes.
9. Return the suggested duration and explanation.

If fewer than three matching completed sessions
exist, Session Scout recommends 25 minutes.

## 5. Why Median?

I chose the median because it is less affected
by unusually short or long sessions than
the arithmetic mean.

For example, consider these durations:

20, 25, 90 minutes

Mean:

45 minutes

Median:

25 minutes

The median is less influenced by the unusually
long 90-minute session.

## 6. Baseline

The baseline always recommends 25 minutes.

It does not use mood or session history.

Baseline prediction:

25 minutes

## 7. Evaluation Method

I compared Session Scout against the fixed
25-minute baseline using six synthetic test cases.

Five cases contain three historical completed
session durations.

One case tests the fallback when no completed
session history is available.

For each case:

1. Generate a Session Scout recommendation.
2. Generate the fixed baseline prediction.
3. Compare both predictions with the actual
   duration assigned to the case.
4. Calculate the absolute error.
5. Calculate mean absolute error across all cases.

The actual duration represents a subsequent
session being predicted. It is not included
in the historical input durations.

## 8. Evaluation Cases

All durations are in minutes.

| Case | Historical Durations | Actual | Scout | Baseline |
|------|----------------------|--------|-------|----------|
| 1 | 20, 25, 30 | 28 | 25 | 25 |
| 2 | 30, 35, 40 | 38 | 35 | 25 |
| 3 | 40, 45, 50 | 47 | 45 | 25 |
| 4 | 10, 15, 20 | 18 | 15 | 25 |
| 5 | 50, 55, 60 | 58 | 55 | 25 |
| 6 | No history | 25 | 25 | 25 |

## 9. Error Calculation

Absolute Error:

Absolute Error = |Prediction - Actual|

Mean Absolute Error:

MAE = Sum of Absolute Errors / Number of Cases

A smaller MAE indicates predictions closer
to the actual durations.

## 10. Evaluation Results

| Case | Scout Error | Baseline Error |
|------|-------------|----------------|
| 1 | 3 | 3 |
| 2 | 3 | 13 |
| 3 | 2 | 22 |
| 4 | 3 | 7 |
| 5 | 3 | 33 |
| 6 | 0 | 0 |

Session Scout total absolute error:

14 minutes

Baseline total absolute error:

78 minutes

Number of cases:

6

Session Scout MAE:

14 / 6 = 2.33 minutes

Baseline MAE:

78 / 6 = 13.00 minutes

Relative MAE reduction:

(13.00 - 2.33) / 13.00 * 100

Approximately 82.05%

## 11. Interpretation

On these six synthetic examples, Session Scout
produced predictions closer to the target
durations than the fixed baseline.

However, these results do not establish that
Session Scout performs better in real use.

The test cases were constructed so that the
subsequent target durations are generally
close to their historical medians.

This makes them useful for checking the
implementation, but they are not an unbiased
sample of actual study behavior.

## 12. Limitations

### Limited history

The algorithm requires three completed sessions
for a personalized recommendation.

Otherwise, it uses the fixed 25-minute fallback.

### No trained model

Session Scout is a deterministic,
median-based recommendation system.

It does not learn parameters or train a
machine learning model.

### Mood association

Session mood is determined by the preset
currently linked to each session.

Editing a preset's mood may change how
previous sessions are grouped.

### Synthetic evaluation

The evaluation cases are synthetic.

The measured improvement may not generalize
to real student sessions.

### Prediction versus effectiveness

The evaluation measures prediction error,
not whether the recommended duration improves
concentration, productivity, or study outcomes.

## 13. Possible Improvements

Future improvements could include:

- Evaluation on real historical study sessions
- Chronological holdout testing
- Comparing against additional baselines
- Tracking prediction accuracy over time
- Incorporating time of day
- Incorporating subject or task difficulty
- Using more historical sessions
- Allowing users to rate recommendations

## 14. Implementation Files

Recommendation algorithm:

lib/features/focus/domain/usecases/
calculate_session_scout.dart

Repository-connected recommendation:

lib/features/focus/domain/usecases/
get_session_scout_recommendation.dart

Evaluation implementation:

lib/features/focus/domain/usecases/
evaluate_session_scout.dart

Evaluation tests:

test/features/focus/domain/
evaluate_session_scout_test.dart

## 15. Conclusion

Session Scout provides a simple, explainable
way to personalize study-duration suggestions.

The evaluation implementation allows the
recommendation algorithm to be compared
consistently against a fixed baseline.

The six synthetic cases demonstrate the
calculation and evaluation process.

A real-world study using held-out session
records would be necessary to determine
whether Session Scout offers a meaningful
predictive advantage.

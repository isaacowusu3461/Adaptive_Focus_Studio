
# Adaptive Focus Studio — Session Scout Documentation

**Project:** Adaptive Focus Studio  
**Course:** CSC 6360 — Mobile App Development  
**Developer:** Isaac Owusu  
**Feature:** Session Scout  
**Implementation:** Local, rule-based recommendation system

## 1. Introduction

Session Scout is a recommendation feature I developed for Adaptive Focus Studio. Its purpose is to suggest a reasonable focus duration based on a user's previous completed study sessions.

When I started developing the application, I wanted it to do more than just track study time. I wanted it to make use of the session history to provide something helpful to the user.

Session Scout does this by looking at the three most recent completed sessions for a particular mood and calculating their median duration.

I implemented the feature locally using Dart. It does not connect to an external AI service or require a trained machine learning model.

## 2. Problem and Motivation

Students do not always study for the same amount of time.

For example, someone might usually study for 20 minutes when they feel tired but manage longer sessions when they feel focused.

I wanted the application to recognize these differences instead of recommending the same duration in every situation.

This is why Session Scout uses a mood tag alongside previous session durations.

The goal is not to force the user to follow a recommendation. It is simply to provide a suggestion based on their recent study history.

## 3. How Session Scout Works

The main recommendation logic is implemented in the `CalculateSessionScout` class.

The class receives two inputs:

- `moodTag`: The mood associated with the recommendation.
- `recentCompletedSeconds`: A list of completed session durations in seconds, ordered from most recent to oldest.

The calculation class expects the caller to supply the relevant completed sessions for the selected mood.

It does not directly retrieve records from SQLite or perform mood filtering itself.

### Recommendation Rules

I defined the following constants in the implementation:

```dart
static const int minimumMinutes = 10;
static const int maximumMinutes = 60;
static const int fallbackMinutes = 25;
static const int requiredSessions = 3;
```

These constants control the recommendation behavior.

Session Scout requires at least three completed sessions before it calculates a personalized suggestion.

If fewer than three sessions are available, it recommends the standard 25-minute duration.

When enough sessions are available, it uses the three most recent durations to calculate the median.

The final suggestion is limited to a minimum of 10 minutes and a maximum of 60 minutes.

## 4. Recommendation Algorithm

The algorithm follows these steps:

1. Receive the selected mood and the completed session durations.
2. Remove extra spaces from the mood tag.
3. Check that the mood is not empty.
4. Check that none of the supplied durations are negative.
5. If fewer than three sessions are available, return the 25-minute fallback.
6. Otherwise, take the first three durations from the list.
7. Sort a copy of those three durations.
8. Select the middle duration as the median.
9. Convert the median from seconds to minutes and round to the nearest whole minute.
10. Limit the result to between 10 and 60 minutes.
11. Return the suggested duration with an explanation.

The original session order is not changed because the algorithm sorts a separate copy of the three selected durations.

### Example

Suppose a user has the following completed sessions for the mood "Focused":

| Session | Duration |
|---------|----------|
| Most recent | 35 minutes |
| Second most recent | 25 minutes |
| Third most recent | 30 minutes |

The algorithm takes these three values and sorts them:

25, 30, 35

The middle value is 30.

Therefore, Session Scout recommends **30 minutes**.

This recommendation falls within the allowed range, so no additional adjustment is needed.

## 5. Why I Used the Median

I chose the median because it is less affected by unusually long or short sessions than the average.

For example, suppose the three most recent completed sessions are:

20, 25, 90 minutes

The average is:

(20 + 25 + 90) / 3 = 45 minutes

However, the median is 25 minutes.

The median gives a result that is closer to the user's shorter, more typical sessions in this example.

This made it a reasonable choice for Session Scout.

Another advantage is that calculating the median of three values is straightforward, making the recommendation easier to explain and test.

## 6. Handling Insufficient Session History

Session Scout requires at least three completed sessions.

If the user has zero, one, or two completed sessions for the selected mood, the algorithm returns the fallback recommendation of 25 minutes.

The implementation uses the following condition:

```dart
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
```

I included this fallback because calculating a recommendation from very little history may not represent the user's normal study habits.

The returned result also records how many sessions were available and whether the fallback was used.

This allows the application to distinguish between a standard recommendation and one calculated from session history.

## 7. Using the Three Most Recent Sessions

Even if the user has more than three completed sessions, Session Scout only uses the three most recent ones.

This is implemented using:

```dart
final recentThree = recentCompletedSeconds
    .take(requiredSessions)
    .toList();
```

The input list is expected to be ordered from newest to oldest.

For example, suppose the user has five completed sessions:

| Session | Duration |
|---------|----------|
| Most recent | 40 minutes |
| Second most recent | 35 minutes |
| Third most recent | 30 minutes |
| Fourth most recent | 20 minutes |
| Fifth most recent | 15 minutes |

Session Scout uses:

40, 35, 30

It ignores the older 20-minute and 15-minute sessions for this calculation.

After sorting the selected values:

30, 35, 40

The median is 35 minutes.

I used this approach so that the recommendation focuses on recent study behavior rather than giving equal importance to every session the user has ever completed.

## 8. Rounding and Duration Limits

The session durations are provided in seconds.

After finding the median, the algorithm converts it to minutes and rounds to the nearest whole minute.

```dart
final medianMinutes = (medianSeconds / 60).round();
```

For example, if the median is 1,740 seconds:

1,740 / 60 = 29 minutes

The calculated duration is 29 minutes.

If the median is 1,750 seconds:

1,750 / 60 = 29.17 minutes

The result is rounded to 29 minutes.

The algorithm then applies the allowed duration range:

```dart
final suggestedMinutes = medianMinutes.clamp(
  minimumMinutes,
  maximumMinutes,
);
```

This means the final recommendation cannot be below 10 minutes or above 60 minutes.

### Example: Below the Minimum

Suppose the three completed sessions are:

5, 7, 8 minutes

The median is 7 minutes.

Because this is below the minimum, Session Scout recommends **10 minutes**.

### Example: Above the Maximum

Suppose the three completed sessions are:

65, 70, 80 minutes

The median is 70 minutes.

Because this exceeds the maximum, Session Scout recommends **60 minutes**.

These limits help keep the recommendations within the duration range I defined for the application.

## 9. Input Validation

I added validation to prevent the recommendation algorithm from processing invalid inputs.

### Empty Mood Tag

The algorithm trims extra spaces from the mood tag.

If the resulting mood is empty, it throws an `ArgumentError`.

```dart
if (mood.isEmpty) {
  throw ArgumentError('Mood tag cannot be empty.');
}
```

This prevents the calculation from proceeding without a valid mood.

### Negative Session Durations

The algorithm also checks whether any session duration is negative.

```dart
if (recentCompletedSeconds.any((seconds) => seconds < 0)) {
  throw ArgumentError(
    'Session durations cannot be negative.',
  );
}
```

Negative durations are rejected because they do not represent valid study time.

This validation applies to the supplied duration list before the algorithm selects the three most recent sessions.

## 10. Recommendation Explanation

Session Scout returns more than just a number.

It returns a `SessionScoutRecommendation` object containing information about the suggestion.

The calculation populates these fields:

| Field | Purpose |
|-------|---------|
| `moodTag` | The selected mood |
| `suggestedMinutes` | The recommended duration |
| `explanation` | A message explaining the result |
| `sessionsUsed` | Number of sessions used or available |
| `usedFallback` | Whether the fallback recommendation was used |

For a personalized recommendation, the explanation tells the user that the suggestion is based on the three most recent completed sessions for the selected mood.

It also reports the calculated median and the final recommended duration.

If the fallback is used, the explanation tells the user that there are not enough completed sessions yet.

I wanted users to understand where the recommendation came from rather than simply seeing a number without any context.

## 11. Local Processing and Privacy

Session Scout performs its recommendation calculation locally.

The application uses SQLite for storing focus presets and session history.

The recommendation logic itself works with the session durations passed to it and does not make a network request.

It does not require:

- A cloud database
- An external AI API
- A trained machine learning model
- Uploading session durations to an external recommendation service

This was important to me because Adaptive Focus Studio is designed as an offline-first application.

It also makes the recommendation logic easier to test and maintain.

## 12. Deterministic Behavior

Session Scout is deterministic.

This means that providing the same mood tag and the same ordered list of session durations produces the same recommendation.

For example, if the three most recent completed sessions are:

25, 30, 35 minutes

The median will always be 30 minutes.

There is no randomness involved in the calculation.

The result can change when the input history changes, but the algorithm does not train or update a machine learning model.

I found this useful because it makes the recommendation predictable and straightforward to verify through automated tests.

## 13. Baseline Comparison

The standard 25-minute duration provides a simple baseline for comparing Session Scout's personalized recommendations.

A fixed baseline always suggests the same duration, regardless of study history.

Session Scout, on the other hand, uses recent completed sessions when enough data is available.

For example:

| Approach | Suggested Duration |
|----------|--------------------|
| Fixed baseline | 25 minutes |
| Session Scout | 35 minutes |

For this example, Session Scout receives three completed sessions of 30, 35, and 40 minutes.

The median is 35 minutes, so the personalized recommendation is 35 minutes.

The difference between the two suggestions is 10 minutes.

This shows how the history-based approach can respond to a user's recent study behavior.

However, this comparison alone does not prove that the personalized recommendation improves study performance.

That would require additional evaluation using actual user behavior.

## 14. Testing and Evaluation

Because Session Scout uses a deterministic algorithm, I can test it using known input values and expected outputs.

The following examples are based on the actual rules in `CalculateSessionScout`.

| Input Durations | Expected Result | Reason |
|-----------------|-----------------|--------|
| No sessions | 25 minutes | Fallback |
| 20 minutes | 25 minutes | Fewer than 3 sessions |
| 20, 30 minutes | 25 minutes | Fewer than 3 sessions |
| 20, 25, 30 minutes | 25 minutes | Median |
| 25, 30, 35 minutes | 30 minutes | Median |
| 5, 7, 8 minutes | 10 minutes | Minimum limit |
| 65, 70, 80 minutes | 60 minutes | Maximum limit |
| 40, 35, 30, 20 minutes | 35 minutes | Only first 3 used |

These are expected algorithm results, not a claim that each example was individually executed during the final test run.

The algorithm should also be tested with an empty mood tag and negative session durations to verify that invalid inputs are rejected.

The application's broader automated testing process is documented in [Testing Documentation](docs/testing.md).

## 15. Limitations

Although Session Scout provides personalized recommendations, it has some limitations.

### Limited Session History

The algorithm uses only three completed sessions.

This makes it responsive to recent behavior, but three sessions may not always represent a user's normal study habits.

### Dependence on Mood-Specific Data

The recommendation depends on receiving the correct completed sessions for the selected mood.

If the caller provides unrelated or incorrectly ordered records, the calculation may not represent the intended study history.

### Limited Context

The algorithm does not directly consider factors such as upcoming deadlines, subject difficulty, fatigue, or how much free time the user has.

For example, a user might normally study for 40 minutes but only have 15 minutes available before class.

### No Trained AI Model

Session Scout does not use machine learning or a generative AI model.

It is a local, rule-based recommendation system that uses a statistical calculation.

I chose this approach because it is appropriate for the project's offline requirements and is easier to explain and test.

## 16. Possible Future Improvements

If I continued developing Session Scout, I would consider a few improvements.

One improvement would be to allow the algorithm to use a configurable number of recent sessions instead of always using three.

I could also consider additional information, such as the time of day, the type of subject being studied, or how often the user completes a recommended duration.

Another improvement would be to evaluate the recommendations using real completion data and compare them with the fixed 25-minute baseline.

For the current version, I wanted to keep the feature simple and reliable.

## 17. What I Learned

Developing Session Scout helped me understand how an application can use stored data to provide a useful recommendation without connecting to an external AI service.

I learned how to calculate the median from recent session durations, convert between seconds and minutes, and apply minimum and maximum limits.

I also learned why input validation and fallback behavior are important.

A recommendation feature should not assume that every user has enough history or that every input is valid.

Another thing I learned was the importance of explaining the recommendation to the user.

Instead of returning only a suggested duration, Session Scout also provides an explanation of how that duration was calculated.

## 18. Conclusion

Session Scout is one of the features I added to make Adaptive Focus Studio more useful than a basic focus timer.

It uses the three most recent completed sessions for a selected mood to calculate a median-based focus duration.

When there is not enough history, it falls back to 25 minutes. Personalized recommendations are rounded to whole minutes and kept between 10 and 60 minutes.

The calculation is deterministic, runs locally, and does not require an external AI service.

Overall, I think Session Scout demonstrates how a relatively simple algorithm can make use of existing study data to provide a personalized and understandable recommendation.

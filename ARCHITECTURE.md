
# Adaptive Focus Studio - Architecture

## 1. Overview

Adaptive Focus Studio is a Flutter application that helps students organize focus sessions, track their study progress, and receive personalized study-duration recommendations.

The application follows clean architecture to separate the user interface, business logic, and data storage.

The application works offline and stores data locally.

## 2. Architecture Layers

The project is divided into three main layers:

- Presentation
- Domain
- Data

The dependency direction follows:

Presentation -> Domain <- Data

The domain layer contains the application's core business logic and does not depend on Flutter widgets or SQLite implementations.

## 3. Presentation Layer

The presentation layer contains the screens, reusable widgets, and Riverpod providers.

### Screens

- Welcome Screen
- Dashboard Screen
- Create/Edit Preset Screen
- Focus Timer Screen
- History & Insights Screen
- Settings Screen

### Dashboard

The Dashboard allows users to:

- View study statistics
- Create focus presets
- Edit saved presets
- Delete presets
- Filter presets by mood
- Start focus sessions
- Generate Session Scout recommendations
- Apply recommended durations

### History & Insights

The History screen allows users to:

- View recorded sessions
- Add manual session logs
- Edit session logs
- Delete session logs
- View study statistics

### Settings

The Settings screen manages preferences stored in SharedPreferences.

Supported settings:

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference

## 4. Domain Layer

The domain layer contains entities, repository interfaces, and use cases.

### Entities

- FocusPreset
- SessionLog
- SessionScoutRecommendation
- SessionScoutEvaluationCase
- SessionScoutCaseResult
- SessionScoutEvaluationResult
- StudyStatistics

### Repository Interfaces

- FocusPresetRepository
- SessionLogRepository

### Use Cases

- CreateFocusPreset
- UpdateFocusPreset
- DeleteFocusPreset
- SaveSessionLog
- CalculateSessionScout
- GetSessionScoutRecommendation
- EvaluateSessionScout
- calculateStudyStatistics

The statistics calculation is implemented as a pure Dart function.

It does not directly access SQLite, Flutter widgets, or Riverpod.

## 5. Data Layer

The data layer handles local persistence and background processing.

### Database

DatabaseHelper manages the SQLite database.

### Models

- FocusPresetModel
- SessionLogModel

### Repository Implementations

- FocusPresetRepositoryImpl
- SessionLogRepositoryImpl

### Background Service

- StudyStatisticsService

StudyStatisticsService runs statistics calculations in a background Dart isolate.

## 6. SQLite Database

The application uses two related tables.

### focus_presets

Columns:

- id
- name
- mood_tag
- duration_minutes

### session_logs

Columns:

- id
- preset_id
- date
- completed_seconds
- status
- notes

The preset_id column references the focus_presets table.

Foreign keys are enabled.

Deleting a preset automatically deletes its related session logs.

## 7. Riverpod State Management

Riverpod is used for dependency injection and asynchronous state management.

### Dependency Injection

FocusDependencies constructs the repositories and use cases.

ProviderScope makes these dependencies available throughout the application.

### Repository Providers

- focusPresetRepositoryProvider
- sessionLogRepositoryProvider

### Use Case Providers

- createFocusPresetProvider
- updateFocusPresetProvider
- deleteFocusPresetProvider
- saveSessionLogProvider
- getSessionScoutRecommendationProvider

### Data Providers

- focusPresetsProvider
- sessionHistoryProvider
- sessionScoutProvider
- studyStatisticsProvider

### Settings Provider

- reduceMotionProvider

### Provider Invalidation

When the application creates, edits, or deletes data, the affected providers are invalidated.

This allows Riverpod to reload the updated information.

For example:

1. A user completes a focus session.
2. The session is saved in SQLite.
3. sessionHistoryProvider is invalidated.
4. Riverpod reloads the session history.
5. studyStatisticsProvider recalculates the statistics.
6. The Dashboard and History screens display updated values.

## 8. Focus Timer

The Focus Timer supports four main states:

- Ready
- Running
- Paused
- Finished

The timer uses Stopwatch to measure elapsed time.

Timer.periodic updates the displayed countdown.

When a session is completed, the application saves a completed session log.

If the user finishes early, the session can be saved as partial.

Session logs are stored in SQLite through SaveSessionLog.

## 9. Session Scout Recommendation System

Session Scout is a deterministic, rule-based recommendation algorithm.

It suggests study durations based on previously completed sessions.

### Inputs

- Selected mood
- Saved focus presets
- Saved session logs
- Completed session durations

### Algorithm

1. Validate the selected mood.
2. Retrieve saved presets and session logs.
3. Identify presets matching the selected mood.
4. Select completed sessions linked to those presets.
5. Sort the sessions from newest to oldest.
6. Select the three most recent completed sessions.
7. Calculate the median completed duration.
8. Round the median to the nearest whole minute.
9. Limit the recommendation to 10-60 minutes.
10. Return the recommendation and explanation.

### Fallback

If fewer than three completed sessions are available, Session Scout returns a 25-minute recommendation.

### Applying Recommendations

The Dashboard allows users to apply a recommendation to an existing preset with the matching mood.

The updated duration is saved in SQLite.

### Limitations

Session Scout does not use a trained machine learning model.

It is a simple, explainable recommendation system.

Session mood is determined through the preset associated with each session.

Changing a preset's mood can therefore affect how previous sessions are grouped.

## 10. Session Scout Evaluation

EvaluateSessionScout compares Session Scout against a fixed 25-minute baseline.

### Evaluation Inputs

Each evaluation case contains:

- Case name
- Mood tag
- Historical completed durations
- Actual subsequent duration

### Evaluation Process

1. Generate a Session Scout prediction.
2. Generate the fixed baseline prediction.
3. Compare both predictions against the target duration.
4. Calculate absolute errors.
5. Repeat for all evaluation cases.
6. Calculate mean absolute error for each method.
7. Compare the results.

### Metrics

Absolute Error:

Absolute Error = |Prediction - Actual|

Mean Absolute Error:

MAE = Sum of Absolute Errors / Number of Cases

Relative MAE Reduction:

(Baseline MAE - Scout MAE) / Baseline MAE * 100

### Synthetic Evaluation Results

Six synthetic cases were used.

Session Scout MAE:

2.33 minutes

Fixed baseline MAE:

13.00 minutes

Relative MAE reduction:

Approximately 82.05%

These results demonstrate the evaluation method.

They do not establish that Session Scout performs better with real-world study data.

More realistic evaluation would require actual chronological session records.

See AI_FEATURE.md for the full evaluation.

## 11. Custom Animations

The application uses both implicit and explicit Flutter animations.

### Implicit Animation

AnimatedSize is used to animate the Session Scout recommendation panel.

AppMotion defines reusable animation durations and curves.

### Explicit Animation

AnimatedFocusIndicator uses:

- AnimationController
- TweenSequence
- CurvedAnimation
- ScaleTransition

The indicator performs a short pulse when activated.

The controller is stopped when the indicator becomes inactive or reduced motion is enabled.

The controller is disposed in dispose().

### Reduced Motion

The reduce_motion preference is stored using SharedPreferences.

ReduceMotionNotifier exposes the saved preference through Riverpod.

When reduced motion is enabled:

- Decorative focus indicator animation is disabled.
- Custom panel transition duration becomes zero.

## 12. Responsive Layout

The application supports different screen sizes.

### ResponsiveContent

ResponsiveContent centers content and limits its maximum width.

### Dashboard Presets

The Dashboard uses LayoutBuilder and Wrap.

On narrow screens, preset cards use one column.

When the available content width is at least 650 pixels, preset cards use two columns.

### Navigation

Screens narrower than 700 pixels use NavigationBar.

Screens at least 700 pixels wide use NavigationRail.

## 13. Background Statistics Processing

### Purpose

The application calculates study statistics using a background Dart isolate.

This separates potentially expensive calculations from Flutter's main UI isolate.

The goal is to avoid blocking the interface during larger calculations.

### Components

#### StudyStatistics

A domain entity containing the calculated statistics.

Fields:

- totalSessions
- completedSessions
- partialSessions
- totalSeconds
- averageMinutes
- longestSessionSeconds

Computed properties:

- totalMinutes
- longestSessionMinutes
- completionRate

#### calculateStudyStatistics

A pure Dart function that processes session data.

It calculates:

- Total session count
- Completed session count
- Partial session count
- Total duration
- Average duration
- Longest session duration

The function also validates session durations and statuses.

#### StudyStatisticsService

A service that uses Isolate.run() to perform calculations in a background isolate.

The service receives a list of SessionLog objects.

It converts the objects into simple maps containing:

- status
- completedSeconds

These maps are passed to the background isolate.

The isolate runs calculateStudyStatistics and returns a StudyStatistics object.

#### studyStatisticsProvider

A Riverpod FutureProvider that coordinates statistics processing.

It watches sessionHistoryProvider and uses StudyStatisticsService to calculate the results.

The Dashboard and History screens watch studyStatisticsProvider.

### Data Flow

1. SessionLogRepository retrieves saved sessions from SQLite.
2. sessionHistoryProvider exposes the session list.
3. studyStatisticsProvider receives the session data.
4. StudyStatisticsService converts sessions into transferable maps.
5. Isolate.run() starts the background calculation.
6. calculateStudyStatistics processes the data.
7. The background isolate returns StudyStatistics.
8. Riverpod exposes the calculated statistics.
9. The Dashboard and History screens display the results.

### Calculation Rules

Total Sessions:

Number of all recorded sessions.

Completed Sessions:

Number of sessions with status completed.

Partial Sessions:

Number of sessions with status partial.

Total Study Time:

Sum of completedSeconds across all sessions.

Average Duration:

Total study duration divided by the number of sessions.

Longest Session:

Maximum completedSeconds value.

Completion Rate:

Completed Sessions / Total Sessions * 100

If no sessions exist, the completion rate is zero.

### Error Handling

The calculation rejects:

- Negative session durations
- Unsupported session statuses

Riverpod exposes three asynchronous states:

- Loading
- Data
- Error

Both screens provide a retry option when statistics cannot be loaded.

### Performance Considerations

Using an isolate introduces startup and data-transfer overhead.

For a small number of sessions, calculating directly on the main isolate may be faster.

The isolate implementation is intended to demonstrate background processing and provide a foundation for larger workloads.

SQLite access remains outside the background isolate.

## 14. Testing Strategy

The project uses unit tests, database tests, widget tests, and provider tests.

### Domain Tests

- Focus preset use cases
- Session logging
- Session Scout recommendation calculation
- Session Scout evaluation
- Study statistics calculation

### Database Tests

- SQLite CRUD operations
- Foreign-key cascade deletion
- Session history
- Mood-based recommendation filtering

### Widget Tests

- Welcome screen
- Preset creation
- Preset editing
- Preset deletion
- Focus Timer
- History
- Settings
- Session Scout recommendation interface

### Riverpod Tests

- Dependency overrides
- Repository providers
- Use case providers
- Preset loading
- Session history loading
- Provider invalidation
- Session Scout recommendations

### Animation Tests

- Active indicator
- Inactive indicator
- Animation progression
- Reduced-motion behavior
- AnimationController disposal

### Responsive Layout Tests

- Narrow layout
- Maximum content width
- Custom padding

### Statistics Calculation Tests

- Empty session history
- Completed sessions
- Partial sessions
- Total study duration
- Average session duration
- Longest session
- Completion rate
- Invalid durations
- Invalid statuses
- Input preservation

### Background Isolate Tests

- Empty session calculation
- Multiple session calculation
- Larger session collection
- Error propagation
- Input preservation

The isolate service tests call the real StudyStatisticsService implementation.

## 15. Development Progress

### Commits 1-8

Project initialization, clean architecture, SQLite integration, and focus preset management.

### Commit 9

Focus Timer, session history, study statistics, and persistent settings.

### Commit 10

Session Scout recommendation algorithm and automated tests.

### Commit 11

Session Scout Dashboard integration and recommendation actions.

### Commit 12

Session Scout evaluation against a fixed baseline.

### Commit 13

Riverpod state management and dependency injection.

### Commit 14

Custom animations, responsive layouts, and reduced-motion support.

### Commit 15

Background statistics processing using Dart isolates, Riverpod integration, and automated tests.

## 16. Planned Work

- Local notifications
- JSON import and export
- Additional unit and widget tests
- Integration testing
- Test coverage
- Final documentation and project polish

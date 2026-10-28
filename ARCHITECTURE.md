
# Adaptive Focus Studio - Architecture

## 1. Overview

Adaptive Focus Studio is a Flutter application that helps students organize focus sessions, track study progress, and receive personalized study-duration recommendations.

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

Platform-specific services, such as local notifications, are placed under core.

## 3. Presentation Layer

The presentation layer contains screens, reusable widgets, and Riverpod providers.

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

The Reminders setting requests notification permission when enabled and saved.

The reduced-motion preference controls custom decorative animations.

## 4. Domain Layer

The domain layer contains entities, repository interfaces, and use cases.

### Entities

- FocusPreset
- SessionLog
- SessionScoutRecommendation
- SessionScoutEvaluationCase
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

FocusDependencies constructs repositories and use cases.

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

For example:

1. A user completes a focus session.
2. The session is saved in SQLite.
3. sessionHistoryProvider is invalidated.
4. Riverpod reloads the session history.
5. studyStatisticsProvider recalculates the statistics.
6. Dashboard and History display updated values.

## 8. Focus Timer

The Focus Timer supports four main states:

- Ready
- Running
- Paused
- Finished

The timer uses Stopwatch to measure elapsed time.

Timer.periodic updates the displayed countdown.

When the countdown finishes naturally, the timer saves a completed session log.

If the user finishes early, the session can be saved as partial.

Session logs are stored in SQLite through SaveSessionLog.

### Timer Lifecycle

Ready:

The timer has not started.

Running:

Stopwatch measures elapsed time, and Timer.periodic updates the countdown.

Paused:

Stopwatch stops until the user resumes.

Finished:

The timer has stopped and the session is saved.

### Natural Completion

When the remaining time reaches zero:

1. Stopwatch stops.
2. The periodic timer is cancelled.
3. The timer state changes to Finished.
4. The session is marked as naturally completed.
5. SaveSessionLog saves the completed session.
6. The notification controller is called after successful saving.
7. The notification service checks the Reminders preference.
8. A local notification is displayed if reminders are enabled and platform permission allows it.

### Manual Completion

When the user presses Finish:

1. Stopwatch stops.
2. The periodic timer is cancelled.
3. The session is marked as manually finished.
4. The session log is saved.
5. No completion notification is requested.

### Reset

Reset cancels the periodic timer, resets Stopwatch, and returns the timer to Ready.

The notification state is also reset.

## 9. Local Notifications

### Purpose

Local notifications inform users when a focus session finishes naturally.

The application uses flutter_local_notifications.

Notifications are generated on the device without a server.

### Components

#### FocusNotificationService

An abstract interface defining:

- initialize()
- requestPermission()
- notifySessionCompleted()

#### LocalFocusNotificationService

The platform-specific implementation of FocusNotificationService.

It uses FlutterLocalNotificationsPlugin.

Responsibilities:

- Initialize the notification plugin
- Request notification permission
- Read the saved reminder preference
- Display a local notification

#### FocusNotificationController

A small controller that decides whether a notification should be requested.

It receives:

- Preset name
- Natural-completion flag
- Session status

It requests a notification only when:

- The session finished naturally
- The saved status is completed

#### FocusTimerScreen

The Focus Timer calls FocusNotificationController after a naturally completed session has been saved successfully.

### Notification Flow

1. User enables Reminders in Settings.
2. User saves Settings.
3. The application requests notification permission.
4. The reminder preference is saved.
5. User starts a focus session.
6. The countdown reaches zero naturally.
7. The completed session is saved in SQLite.
8. FocusNotificationController checks the completion reason.
9. LocalFocusNotificationService reads reminders_enabled.
10. If reminders are enabled, the service requests an immediate local notification.

### Notification Content

Title:

Focus session completed

Body:

You finished your [Preset Name] focus session.

### Android Configuration

AndroidManifest.xml declares:

android.permission.POST_NOTIFICATIONS

The application requests notification permission at runtime on supported Android versions.

The Android build uses Java 17 and core library desugaring.

### Notification Channel

Channel ID:

focus_sessions

Channel Name:

Focus Sessions

Importance:

High

Priority:

High

### Reminder Preference

The key reminders_enabled is stored in SharedPreferences.

When the preference is false, the notification service returns without displaying a notification.

When the preference is true, the service attempts to display a notification.

The operating system may still block notifications if permission is denied or notification settings are changed outside the application.

### Error Handling

Notification initialization errors are caught so they do not prevent the application from starting.

Notification display errors are caught separately from session-saving errors.

A notification failure does not undo a successfully saved session.

### Limitations

The implementation uses immediate notifications.

It does not schedule notifications to run at a future time.

The Focus Timer must remain active to detect countdown completion.

If the application is suspended or terminated before the timer reaches zero, notification delivery is not guaranteed.

Background scheduling would require additional design and platform configuration.

## 10. Session Scout Recommendation System

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
5. Sort sessions from newest to oldest.
6. Select the three most recent completed sessions.
7. Calculate the median completed duration.
8. Round the median to the nearest minute.
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

## 11. Session Scout Evaluation

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

These results demonstrate the evaluation method and do not establish real-world performance.

See AI_FEATURE.md for the full evaluation.

## 12. Custom Animations

The application uses implicit and explicit Flutter animations.

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

## 13. Responsive Layout

The application supports different screen sizes.

### ResponsiveContent

ResponsiveContent centers content and limits its maximum width.

### Dashboard Presets

The Dashboard uses LayoutBuilder and Wrap.

On narrow screens, preset cards use one column.

When available content width is at least 650 pixels, preset cards use two columns.

### Navigation

Screens narrower than 700 pixels use NavigationBar.

Screens at least 700 pixels wide use NavigationRail.

## 14. Background Statistics Processing

### Purpose

The application calculates study statistics using a background Dart isolate.

This separates potentially expensive calculations from Flutter's main UI isolate.

### Components

#### StudyStatistics

A domain entity containing:

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

A pure Dart function that calculates statistics from session data.

It validates session durations and statuses.

#### StudyStatisticsService

Uses Isolate.run() to execute the calculation in a background isolate.

The service converts SessionLog objects into maps containing:

- status
- completedSeconds

#### studyStatisticsProvider

A Riverpod FutureProvider that watches sessionHistoryProvider and calls StudyStatisticsService.

### Data Flow

1. SessionLogRepository retrieves saved sessions from SQLite.
2. sessionHistoryProvider exposes the session list.
3. studyStatisticsProvider receives the session data.
4. StudyStatisticsService converts sessions into transferable maps.
5. Isolate.run() executes the background calculation.
6. calculateStudyStatistics processes the data.
7. The isolate returns StudyStatistics.
8. Riverpod exposes the results.
9. Dashboard and History display the statistics.

### Calculated Metrics

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

If no sessions exist, completion rate is zero.

### Error Handling

The calculation rejects:

- Negative session durations
- Unsupported session statuses

Riverpod exposes loading, data, and error states.

Both screens provide retry options.

### Performance Considerations

Using an isolate introduces startup and data-transfer overhead.

For small datasets, direct calculation may be faster.

The implementation demonstrates background processing for larger workloads.

SQLite access remains outside the background isolate.

## 15. Testing Strategy

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
- Session Scout interface

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

### Statistics Tests

- Empty history
- Completed sessions
- Partial sessions
- Total duration
- Average duration
- Longest session
- Completion rate
- Invalid inputs

### Background Isolate Tests

- Empty calculation
- Multiple sessions
- Larger session collection
- Error propagation
- Input preservation

### Notification Controller Tests

- Natural completion triggers notification
- Early completion does not trigger notification
- Manual completion does not trigger notification
- Partial status does not trigger notification
- Preset name is passed correctly

Notification permission and display behavior also require manual testing on Android.

## 16. Development Progress

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

### Commit 16

Local notifications, Android notification permission, reminder preference integration, and notification controller tests.

## 17. Planned Work

- JSON import and export
- Additional unit and widget tests
- Integration testing
- Test coverage
- Final documentation and project polish

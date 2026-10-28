
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

The Settings screen also provides JSON backup and restore actions.

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

The data layer handles local persistence, background processing, and JSON backup operations.

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

### Backup Services

- FocusBackupCodec
- FocusBackupService

FocusBackupCodec handles JSON encoding and validation.

FocusBackupService handles database export, file selection, native sharing, and transactional restoration.

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

The JSON backup feature uses the existing schema without requiring a database migration.

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

### Backup Provider

- focusBackupServiceProvider

The backup provider creates FocusBackupService using the existing DatabaseHelper instance.

### Provider Invalidation

When the application creates, edits, or deletes data, the affected providers are invalidated.

For example:

1. A user completes a focus session.
2. The session is saved in SQLite.
3. sessionHistoryProvider is invalidated.
4. Riverpod reloads the session history.
5. studyStatisticsProvider recalculates the statistics.
6. Dashboard and History display updated values.

After a successful JSON restore:

1. The backup service commits the restored records.
2. focusPresetsProvider is invalidated.
3. sessionHistoryProvider is invalidated.
4. Dependent statistics and recommendations are recalculated.

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

The platform-specific implementation.

Responsibilities:

- Initialize the notification plugin
- Request notification permission
- Read the saved reminder preference
- Display a local notification

#### FocusNotificationController

Decides whether a notification should be requested.

It receives:

- Preset name
- Natural-completion flag
- Session status

It requests a notification only when the session finished naturally and its saved status is completed.

#### FocusTimerScreen

Calls FocusNotificationController after a naturally completed session has been saved successfully.

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

When false, the notification service returns without notifying.

When true, the service attempts to display a notification.

The operating system may still block notifications if permission is denied.

### Error Handling

Notification initialization errors do not prevent the application from starting.

Notification display errors are caught separately from session-saving errors.

A notification failure does not undo a successfully saved session.

### Limitations

The implementation uses immediate notifications.

It does not schedule notifications for future times.

If the application is suspended or terminated before the timer reaches zero, notification delivery is not guaranteed.

## 10. JSON Backup and Restore

### Purpose

The JSON backup feature allows users to export and restore their focus presets and session history.

The feature is designed to work offline.

It uses the existing SQLite database without changing its schema.

### Components

#### FocusBackupData

A data structure containing:

- Preset records
- Session records

#### FocusBackupCodec

Responsible for:

- Encoding database records into JSON
- Decoding JSON into validated database records
- Checking the backup format version
- Checking required fields
- Validating preset and session IDs
- Validating relationships between sessions and presets

The codec does not access SQLite or the device file system.

#### FocusBackupService

Responsible for:

- Reading saved presets and sessions
- Generating a JSON backup
- Creating a temporary export file
- Opening the native share sheet
- Selecting a JSON backup file
- Validating imported data
- Restoring records using a SQLite transaction

#### focusBackupServiceProvider

A Riverpod provider that constructs FocusBackupService using the application's existing DatabaseHelper.

#### SettingsScreen

Provides the user interface for:

- Export JSON Backup
- Import JSON Backup
- Confirming replacement
- Displaying success and error messages

### Backup Format

The JSON file includes:

- formatVersion
- app
- exportedAt
- focusPresets
- sessionLogs

Each focus preset contains:

- id
- name
- moodTag
- durationMinutes

Each session log contains:

- id
- presetId
- date
- completedSeconds
- status
- notes

### Export Flow

1. User selects Export JSON Backup.
2. SettingsScreen calls FocusBackupService.
3. The service retrieves presets and sessions from SQLite.
4. Both tables are read within a database transaction.
5. FocusBackupCodec generates the JSON document.
6. The service writes the JSON to a temporary file.
7. The native share sheet opens.
8. The user chooses where to save or share the backup.

The exported JSON is independent of the SQLite database file.

### Import Flow

1. User selects Import JSON Backup.
2. SettingsScreen displays a replacement warning.
3. User confirms.
4. The file picker opens.
5. User selects a JSON file.
6. The service reads the file.
7. FocusBackupCodec validates the document.
8. The service begins a SQLite transaction.
9. Existing session logs are deleted.
10. Existing focus presets are deleted.
11. Imported presets are inserted.
12. Imported sessions are inserted.
13. The transaction commits.
14. Riverpod providers are invalidated.
15. Dashboard and History reload restored data.

If the user cancels the file picker, no database changes occur.

### Validation Rules

The codec validates:

- JSON object structure
- Supported format version
- Correct application name
- Valid export timestamp
- Preset and session arrays
- Positive integer IDs
- Unique preset IDs
- Unique session IDs
- Non-empty preset names
- Supported mood tags
- Positive preset durations
- Valid session dates
- Non-negative completed seconds
- Completed or partial session status
- String notes
- Valid session-to-preset relationships

A session referencing a missing preset causes validation to fail.

### Restore Strategy

The application uses replace-all restoration.

This means the imported backup becomes the current database content.

It does not merge imported records with existing records.

This approach avoids duplicate records when the same backup is imported repeatedly.

Original record IDs are preserved so session relationships remain valid.

### SQLite Transactions

The entire restoration operation runs inside one transaction.

If an insert or delete fails, SQLite rolls back the transaction.

This prevents partially restored data.

The application validates the backup before starting the transaction.

### Empty Backups

A valid backup may contain empty preset and session arrays.

Importing an empty backup removes all current presets and sessions after user confirmation.

### Settings

SharedPreferences settings are not included in the JSON backup.

The following preferences remain unchanged during restoration:

- Default focus duration
- Reminders
- Reduced motion
- Sound

### Limitations

The current format supports version 1 only.

Importing a file with another version is rejected.

The export feature uses the native share sheet rather than writing directly to an arbitrary folder.

The temporary export file is not intended for permanent storage.

Users must save a copy to a location of their choice.

The backup contains study information in plain-text JSON and is not encrypted.

Users should store backup files securely.

## 11. Session Scout Recommendation System

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

Changing a preset's mood can affect how previous sessions are grouped.

## 12. Session Scout Evaluation

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

## 13. Custom Animations

The application uses implicit and explicit Flutter animations.

### Implicit Animation

AnimatedSize animates the Session Scout recommendation panel.

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

## 14. Responsive Layout

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

## 15. Background Statistics Processing

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

## 16. Testing Strategy

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

### JSON Codec Tests

- Valid backup encoding
- Valid backup decoding
- Empty backups
- Invalid JSON
- Unsupported versions
- Incorrect app name
- Duplicate IDs
- Missing preset references
- Invalid durations
- Invalid statuses
- Empty names
- Unsupported moods

### JSON Backup Service Tests

- Exporting database records
- Restoring exported data
- Replacing existing data
- Preventing duplicate imports
- Preserving data after invalid JSON
- Rejecting invalid relationships
- Restoring empty backups

The backup service tests use an in-memory SQLite database.

They do not modify the application's saved data.

## 17. Development Progress

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

### Commit 17

JSON backup codec, export and import services, file operations, backup validation, transactional restoration, and automated tests.

## 18. Planned Work

- Additional unit and widget tests
- Integration testing
- Test coverage
- Final documentation and project polish

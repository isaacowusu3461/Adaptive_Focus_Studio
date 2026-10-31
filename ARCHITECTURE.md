
# Adaptive Focus Studio - Architecture

## 1. Overview

Adaptive Focus Studio is a Flutter application that helps students organize focus sessions, track their study progress, and receive personalized study-duration recommendations.

I developed the application using clean architecture to separate the user interface, business logic, and data storage.

The application works offline and stores its data locally using SQLite and SharedPreferences.

The main technologies used are Flutter, Dart, Riverpod, SQLite, SharedPreferences, Dart isolates, and Flutter plugins for notifications and file operations.

## 2. Architecture Layers

The project is divided into three main layers:

- Presentation
- Domain
- Data

The dependency direction follows:

```text
Presentation -> Domain <- Data
```

The domain layer contains the application's core business logic. It does not depend on Flutter widgets or SQLite implementations.

The presentation layer handles the user interface and application state.

The data layer handles database operations, repository implementations, and local services.

Platform-specific functionality, such as local notifications, is organized under the core directory.

This separation makes the application easier to maintain, test, and extend.

## 3. Presentation Layer

The presentation layer contains Flutter screens, reusable widgets, and Riverpod providers.

### Main Screens

The application includes:

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

The Dashboard uses Riverpod providers to retrieve and display data.

When focus presets or session history change, the affected providers can be invalidated so the interface displays updated information.

### History & Insights

The History screen allows users to:

- View recorded sessions
- Add manual session logs
- Edit session logs
- Delete session logs
- View study statistics

The screen displays information calculated from the saved session history.

### Settings

The Settings screen manages preferences stored using SharedPreferences.

Supported settings include:

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference

The Settings screen also provides JSON backup and restore actions.

The reminder preference controls local completion notifications.

The reduced-motion preference controls supported decorative animations.

The sound preference is stored, although separate sound playback functionality has not been implemented.

## 4. Domain Layer

The domain layer contains entities, repository interfaces, use cases, and business logic.

### Entities

Important domain entities include:

- `FocusPreset`
- `SessionLog`
- `SessionScoutRecommendation`
- `SessionScoutEvaluationCase`
- `SessionScoutEvaluationResult`
- `StudyStatistics`

These entities represent the application's main data and calculation results.

### Repository Interfaces

The repository interfaces include:

- `FocusPresetRepository`
- `SessionLogRepository`

The domain layer uses these interfaces without needing to know how the data is stored.

### Use Cases

Important use cases and calculations include:

- `CreateFocusPreset`
- `UpdateFocusPreset`
- `DeleteFocusPreset`
- `SaveSessionLog`
- `CalculateSessionScout`
- `GetSessionScoutRecommendation`
- `EvaluateSessionScout`
- `calculateStudyStatistics`

Each use case handles a specific part of the application's business logic.

For example, `CalculateSessionScout` calculates a recommended focus duration, while `SaveSessionLog` handles saving a study session through the repository interface.

The statistics calculation is implemented as a pure Dart function and does not directly access SQLite, Flutter widgets, or Riverpod.

## 5. Data Layer

The data layer handles local persistence, repository implementations, background processing services, and JSON backup operations.

### Database

`DatabaseHelper` manages the SQLite database.

It is responsible for opening the database and supporting the tables used by the application.

### Models

The data models include:

- `FocusPresetModel`
- `SessionLogModel`

These models help convert between stored database records and application data.

### Repository Implementations

The repository implementations include:

- `FocusPresetRepositoryImpl`
- `SessionLogRepositoryImpl`

These classes implement the repository interfaces defined in the domain layer.

They handle SQLite operations for focus presets and session logs.

### Background Service

`StudyStatisticsService` runs statistics calculations in a background Dart isolate.

### Backup Services

The backup components include:

- `FocusBackupCodec`
- `FocusBackupService`

`FocusBackupCodec` handles JSON encoding, decoding, and validation.

`FocusBackupService` handles database export, file selection, native sharing, and transactional restoration.

## 6. SQLite Database

The application uses two related SQLite tables.

### focus_presets

| Column | Description |
|---|---|
| id | Unique preset ID |
| name | Preset name |
| mood_tag | Selected mood |
| duration_minutes | Planned focus duration |

### session_logs

| Column | Description |
|---|---|
| id | Unique session ID |
| preset_id | Related focus preset |
| date | Session date |
| completed_seconds | Recorded study duration |
| status | Session status |
| notes | Optional session notes |

The `preset_id` column references the `focus_presets` table.

Foreign keys are enabled.

Deleting a preset automatically deletes its related session logs through cascade deletion.

This relationship helps maintain consistency between saved presets and session history.

The JSON backup feature uses the existing database schema without requiring a migration.

## 7. Riverpod State Management

I used Riverpod for dependency injection and asynchronous state management.

### Dependency Injection

`FocusDependencies` constructs repositories and use cases.

`ProviderScope` makes Riverpod dependencies available throughout the application.

### Repository Providers

- `focusPresetRepositoryProvider`
- `sessionLogRepositoryProvider`

### Use Case Providers

- `createFocusPresetProvider`
- `updateFocusPresetProvider`
- `deleteFocusPresetProvider`
- `saveSessionLogProvider`
- `getSessionScoutRecommendationProvider`

### Data Providers

- `focusPresetsProvider`
- `sessionHistoryProvider`
- `sessionScoutProvider`
- `studyStatisticsProvider`

### Other Providers

- `reduceMotionProvider`
- `focusBackupServiceProvider`

The backup provider creates `FocusBackupService` using the existing `DatabaseHelper` instance.

### Provider Invalidation

When the application creates, edits, or deletes data, the affected providers are invalidated.

For example, when a focus session is completed:

1. The session is saved in SQLite.
2. `sessionHistoryProvider` is invalidated.
3. Riverpod reloads the session history.
4. `studyStatisticsProvider` recalculates the statistics.
5. The Dashboard and History screens display updated values.

After a successful JSON restore, the preset and session history providers are invalidated so the interface can reload the restored data.

## 8. Focus Timer

The Focus Timer supports four main states:

- Ready
- Running
- Paused
- Finished

The timer uses Dart's `Stopwatch` to measure elapsed time.

`Timer.periodic` updates the countdown display.

Using `Stopwatch` for elapsed time helps separate time measurement from visual updates.

### Ready

The timer has not started.

### Running

The stopwatch measures elapsed time while the periodic timer updates the display.

### Paused

The stopwatch stops until the user resumes the session.

### Finished

The timer has stopped, and the application handles saving the session.

### Natural Completion

When the countdown reaches zero:

1. The stopwatch stops.
2. The periodic timer is cancelled.
3. The timer changes to its finished state.
4. The session is marked as naturally completed.
5. `SaveSessionLog` saves the completed session.
6. The notification controller is called after successful saving.
7. The notification service checks the reminder preference.
8. A local notification is displayed if reminders are enabled and platform permission allows it.

### Manual Completion

When the user finishes early:

1. The stopwatch stops.
2. The periodic timer is cancelled.
3. The session is marked as manually finished.
4. The session log is saved as a partial session.
5. No natural-completion notification is requested.

### Reset

Reset cancels the periodic timer, resets the stopwatch, and returns the timer to Ready.

The notification state is also reset.

## 9. Local Notifications

The application uses `flutter_local_notifications` to notify users when a focus session finishes naturally.

Notifications are generated on the device without requiring a server.

### Components

#### FocusNotificationService

An abstract interface defining:

- `initialize()`
- `requestPermission()`
- `notifySessionCompleted()`

#### LocalFocusNotificationService

The platform-specific implementation.

Its responsibilities include:

- Initializing the notification plugin
- Requesting notification permission
- Reading the saved reminder preference
- Displaying a local notification

#### FocusNotificationController

This component decides whether a notification should be requested.

It receives information such as the preset name, completion reason, and saved session status.

It requests a notification only when the session finishes naturally and its saved status is completed.

#### FocusTimerScreen

The timer screen calls the notification controller after a naturally completed session has been saved successfully.

### Notification Flow

1. The user enables Reminders in Settings.
2. The user saves the settings.
3. The application requests notification permission.
4. The reminder preference is saved.
5. The user starts a focus session.
6. The countdown reaches zero naturally.
7. The completed session is saved in SQLite.
8. The notification controller checks the completion reason.
9. The notification service reads the reminder preference.
10. If reminders are enabled and permission is available, the service requests an immediate local notification.

### Notification Content

Example title:

`Focus session completed`

Example body:

`You finished your Morning Study focus session.`

### Android Configuration

The Android manifest declares:

```text
android.permission.POST_NOTIFICATIONS
```

The Android build uses Java 17 and core library desugaring.

### Notification Channel

| Setting | Value |
|---|---|
| Channel ID | `focus_sessions` |
| Channel Name | Focus Sessions |
| Importance | High |
| Priority | High |

### Reminder Preference

The key `reminders_enabled` is stored in SharedPreferences.

When reminders are disabled, the notification service returns without notifying.

When reminders are enabled, the service attempts to display a notification.

The operating system may still block notifications if permission is denied.

### Error Handling

Notification initialization errors do not prevent the application from starting.

Notification display errors are handled separately from session-saving errors.

A notification failure does not undo a successfully saved session.

### Limitations

The implementation uses immediate notifications rather than scheduled notifications.

If the application is suspended or terminated before the timer reaches zero, notification delivery is not guaranteed.

## 10. JSON Backup and Restore

The JSON backup feature allows users to export and restore their focus presets and session history.

The feature works offline and uses the existing SQLite database.

### Components

#### FocusBackupData

A data structure containing preset records and session records.

#### FocusBackupCodec

Responsible for:

- Encoding database records into JSON
- Decoding JSON into validated database records
- Checking the backup format version
- Checking required fields
- Validating preset and session IDs
- Validating relationships between sessions and presets

The codec does not directly access SQLite or the device file system.

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

A Riverpod provider that constructs `FocusBackupService` using the application's existing database helper.

#### SettingsScreen

Provides the interface for exporting and importing backups, confirming data replacement, and displaying feedback.

### Backup Format

The JSON file includes:

- `formatVersion`
- `app`
- `exportedAt`
- `focusPresets`
- `sessionLogs`

Each focus preset contains:

- `id`
- `name`
- `moodTag`
- `durationMinutes`

Each session log contains:

- `id`
- `presetId`
- `date`
- `completedSeconds`
- `status`
- `notes`

### Export Flow

1. The user selects Export JSON Backup.
2. SettingsScreen calls FocusBackupService.
3. The service retrieves presets and sessions from SQLite.
4. Both tables are read within a database transaction.
5. FocusBackupCodec generates the JSON document.
6. The service writes the JSON to a temporary file.
7. The native share sheet opens.
8. The user chooses where to save or share the backup.

The exported JSON is independent of the SQLite database file.

### Import Flow

1. The user selects Import JSON Backup.
2. SettingsScreen displays a replacement warning.
3. The user confirms.
4. The file picker opens.
5. The user selects a JSON file.
6. The service reads the file.
7. FocusBackupCodec validates the document.
8. The service begins a SQLite transaction.
9. Existing session logs are deleted.
10. Existing focus presets are deleted.
11. Imported presets are inserted.
12. Imported sessions are inserted.
13. The transaction commits.
14. Riverpod providers are invalidated.
15. Dashboard and History reload the restored data.

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

The imported backup becomes the current database content.

It does not merge imported records with existing records.

This avoids duplicate records when the same backup is imported repeatedly.

Original record IDs are preserved so session relationships remain valid.

### SQLite Transactions

The entire restoration operation runs inside one transaction.

If an insert or delete fails, SQLite rolls back the transaction.

This prevents partially restored data.

The application validates the backup before starting the transaction.

### Empty Backups

A valid backup may contain empty preset and session arrays.

Importing an empty backup removes all current presets and sessions after confirmation.

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

Session Scout is a deterministic, rule-based recommendation system.

It suggests study durations based on previously completed sessions for a selected mood.

### Inputs

The recommendation workflow uses:

- Selected mood
- Saved focus presets
- Saved session logs
- Completed session durations

The `CalculateSessionScout` class itself receives:

- `moodTag`
- `recentCompletedSeconds`

The completed durations must be supplied in newest-to-oldest order.

### Algorithm

The overall recommendation process is:

1. Validate the selected mood.
2. Retrieve saved presets and session logs.
3. Identify presets matching the selected mood.
4. Select completed sessions linked to those presets.
5. Order the sessions from newest to oldest.
6. Pass the completed durations to `CalculateSessionScout`.
7. Select the first three durations.
8. Sort a copy of those three durations.
9. Find the middle value, which is the median.
10. Convert the median from seconds to minutes.
11. Round to the nearest whole minute.
12. Limit the recommendation to 10–60 minutes.
13. Return the recommendation and explanation.

The session retrieval and mood filtering happen outside the calculation class.

### Fallback

Session Scout requires three completed sessions.

If fewer than three matching completed sessions are available, it returns a 25-minute recommendation.

The returned result also indicates that the fallback was used.

### Input Validation

The calculation rejects:

- Empty mood tags after trimming
- Negative session durations

Invalid inputs cause an `ArgumentError`.

### Recommendation Limits

The implementation uses:

```dart
static const int minimumMinutes = 10;
static const int maximumMinutes = 60;
static const int fallbackMinutes = 25;
static const int requiredSessions = 3;
```

For example, if the three selected durations are 20, 25, and 30 minutes, the recommendation is 25 minutes.

If the median is below 10 minutes, the recommendation becomes 10 minutes.

If the median exceeds 60 minutes, the recommendation becomes 60 minutes.

### Applying Recommendations

The Dashboard allows users to apply a recommendation to an existing preset with the matching mood.

The updated duration is saved in SQLite.

### Limitations

Session Scout does not use a trained machine learning model.

It is a local, explainable recommendation system.

Session mood is determined through the preset associated with each session.

Changing a preset's mood can affect how previous sessions are grouped.

For more information, see [AI_FEATURE.md](AI_FEATURE.md).

## 12. Session Scout Evaluation

`EvaluateSessionScout` compares Session Scout against a fixed 25-minute baseline.

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

```text
Absolute Error = |Prediction - Actual|
```

Mean Absolute Error:

```text
MAE = Sum of Absolute Errors / Number of Cases
```

Relative MAE Reduction:

```text
(Baseline MAE - Scout MAE) / Baseline MAE * 100
```

### Synthetic Evaluation Results

The existing project evaluation records six synthetic cases.

| Metric | Recorded Value |
|---|---:|
| Session Scout MAE | 2.33 minutes |
| Fixed Baseline MAE | 13.00 minutes |
| Relative MAE Reduction | Approximately 82.05% |

These values should be confirmed against the final evaluation test output.

The results demonstrate the evaluation method and do not establish real-world performance.

## 13. Custom Animations

The application uses implicit and explicit Flutter animations.

### Implicit Animation

`AnimatedSize` animates the Session Scout recommendation panel.

`AppMotion` defines reusable animation durations and curves.

### Explicit Animation

`AnimatedFocusIndicator` uses:

- `AnimationController`
- `TweenSequence`
- `CurvedAnimation`
- `ScaleTransition`

The indicator performs a short pulse when activated.

The controller is stopped when the indicator becomes inactive or reduced motion is enabled.

The controller is disposed in `dispose()`.

### Reduced Motion

The `reduce_motion` preference is stored using SharedPreferences.

`ReduceMotionNotifier` exposes the saved preference through Riverpod.

When reduced motion is enabled:

- Decorative focus indicator animation is disabled.
- Custom panel transition duration becomes zero.

This allows users to reduce unnecessary visual movement.

## 14. Responsive Layout

The application supports different screen sizes.

### ResponsiveContent

`ResponsiveContent` centers content and limits its maximum width.

### Dashboard Presets

The Dashboard uses `LayoutBuilder` and `Wrap`.

On narrow screens, preset cards use one column.

When available content width is at least 650 pixels, preset cards use two columns.

### Navigation

Screens narrower than 700 pixels use `NavigationBar`.

Screens at least 700 pixels wide use `NavigationRail`.

This allows the application to adjust its navigation and content layout based on screen width.

## 15. Background Statistics Processing

The application calculates study statistics using a background Dart isolate.

This separates potentially expensive calculations from Flutter's main UI isolate.

### Components

#### StudyStatistics

A domain entity containing:

- `totalSessions`
- `completedSessions`
- `partialSessions`
- `totalSeconds`
- `averageMinutes`
- `longestSessionSeconds`

Computed properties include:

- `totalMinutes`
- `longestSessionMinutes`
- `completionRate`

#### calculateStudyStatistics

A pure Dart function that calculates statistics from session data.

It validates session durations and statuses.

#### StudyStatisticsService

Uses `Isolate.run()` to execute the calculation in a background isolate.

The service converts session objects into transferable data containing:

- Status
- Completed seconds

#### studyStatisticsProvider

A Riverpod `FutureProvider` that watches `sessionHistoryProvider` and calls `StudyStatisticsService`.

### Data Flow

1. SessionLogRepository retrieves saved sessions from SQLite.
2. `sessionHistoryProvider` exposes the session list.
3. `studyStatisticsProvider` receives the session data.
4. StudyStatisticsService converts sessions into transferable maps.
5. `Isolate.run()` executes the background calculation.
6. `calculateStudyStatistics` processes the data.
7. The isolate returns the calculated statistics.
8. Riverpod exposes the results.
9. Dashboard and History display the statistics.

### Calculated Metrics

| Metric | Calculation |
|---|---|
| Total Sessions | Number of all recorded sessions |
| Completed Sessions | Sessions with completed status |
| Partial Sessions | Sessions with partial status |
| Total Study Time | Sum of completed seconds |
| Average Duration | Total duration divided by number of sessions |
| Longest Session | Maximum completed duration |
| Completion Rate | Completed sessions divided by total sessions, multiplied by 100 |

If no sessions exist, the completion rate is zero.

### Error Handling

The calculation rejects:

- Negative session durations
- Unsupported session statuses

Riverpod exposes loading, data, and error states.

The Dashboard and History screens provide retry options.

### Performance Considerations

Using an isolate introduces startup and data-transfer overhead.

For small datasets, direct calculation may be faster.

The implementation demonstrates background processing and provides a foundation for larger workloads.

SQLite access remains outside the background isolate.

## 16. Testing Strategy

The project uses unit tests, database tests, widget tests, provider tests, and integration tests.

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

### Integration Testing

Integration tests cover complete application workflows on an Android emulator.

These tests help check that the main features work together rather than only testing individual classes.

The final test counts and pass status should be recorded after the latest verification run.

For testing commands, results, and evidence, see [Testing Documentation](docs/testing.md).

## 17. Development Progress

The project was developed incrementally through 20 main implementation commits.

### Commits 1–8

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

### Commit 18

Integration testing and complete focus workflow verification.

### Commit 19

Widget test stabilization, focus timer UI tests, form validation tests, and additional automated testing.

### Commit 20

Final static analysis cleanup, database and backup service cleanup, and project verification.

## 18. Project Management

I used ClickUp to organize the development tasks for Adaptive Focus Studio.

The project was developed individually, so I managed the planning, implementation, testing, and documentation myself.

I used a Kanban-style board with the following statuses:

- Backlog
- To Do
- In Progress
- Done

The board helped me organize tasks and track development progress.

[View Adaptive Focus Studio ClickUp Board](https://sharing.clickup.com/90141777100/b/h/2kydwq6c-474/65ac003664e3c60)

The development process is documented in [Development Journal](docs/development-journal.md).

## 19. Limitations

The current architecture has some limitations:

- Session Scout uses a rule-based recommendation algorithm rather than a trained machine learning model.
- Session Scout uses only three recent completed sessions for each recommendation.
- The evaluation uses synthetic data rather than real user study data.
- Notifications depend on the timer reaching completion while the application remains active.
- The sound preference is stored, but separate sound functionality is not implemented.
- JSON backups do not include SharedPreferences settings.
- Backup files are not encrypted.
- The application does not provide cloud synchronization.

These limitations are useful to consider when planning future improvements.

## 20. Conclusion

Adaptive Focus Studio combines Flutter, Riverpod, SQLite, and several local services into one mobile application.

The clean architecture structure separates the user interface, business logic, and data storage.

Riverpod manages dependencies and application state, while SQLite stores focus presets and session history.

The project also includes Session Scout recommendations, background statistics processing, custom animations, local notifications, and JSON backup and restore.

Developing the application gave me experience working with a larger Flutter project and connecting several features while keeping the code organized and testable.

## Related Documentation

- [README](README.md)
- [Session Scout Documentation](AI_FEATURE.md)
- [Development Journal](docs/development-journal.md)
- [Testing Documentation](docs/testing.md)

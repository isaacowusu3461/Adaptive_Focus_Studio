
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application for organizing focus sessions, tracking study progress, and recommending personalized study durations.

Developed for CSC 6360 - Mobile App Development at Georgia State University.

## Developer

Isaac Owusu

## Technologies

- Flutter and Dart
- Riverpod
- SQLite (sqflite)
- SharedPreferences
- Material Design 3
- intl
- sqflite_common_ffi for database testing
- Dart Isolates
- flutter_local_notifications

## Features

### Focus Presets

Users can create and manage focus presets for different study activities.

Features include:

- Create focus presets
- Edit existing presets
- Delete presets with confirmation
- Filter presets by mood
- Save presets locally using SQLite

Supported moods:

- Focused
- Relaxed
- Motivated

Each preset contains a name, mood tag, and focus duration.

### Focus Timer

The Focus Timer allows users to run study sessions using saved presets.

Features include:

- Start a focus session
- Pause and resume the timer
- Finish a session early
- Reset the timer
- Automatically save completed sessions
- Save partially completed sessions
- Retry saving if a database operation fails

The timer uses Stopwatch to measure elapsed time and Timer.periodic to update the countdown display.

Session records are stored in SQLite.

### History & Insights

The History screen displays previously recorded study sessions.

Users can:

- View saved session logs
- Add manual session logs
- Edit session logs
- Delete session logs
- View study statistics

The application calculates:

- Total sessions
- Completed sessions
- Partial sessions
- Total study time
- Average session duration
- Longest session duration
- Completion rate

Statistics are calculated using a background Dart isolate.

### Settings

Users can configure:

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference

Settings are stored locally using SharedPreferences.

The reduced-motion preference controls the application's custom decorative animations.

The Reminders setting controls local focus-completion notifications.

The Sound setting is currently stored as a preference. Separate sound functionality has not yet been implemented.

### Local Notifications

The application uses flutter_local_notifications to display a notification when a focus session finishes naturally.

Notifications are generated locally and do not require a server or internet connection.

The notification feature:

- Initializes the notification plugin when the app starts
- Requests permission when the user enables reminders
- Stores the reminder preference in SharedPreferences
- Checks the reminder preference before notifying
- Sends a notification after a naturally completed session is saved
- Does not notify when a session is finished early
- Does not notify when the timer is paused or reset
- Avoids duplicate notifications for the same timer completion

Example notification:

Title: Focus session completed

Body: You finished your Morning Study focus session.

On Android 13 and later, the app requests notification permission.

The notification feature uses immediate local notifications rather than scheduled notifications.

The timer must remain active long enough to detect completion. This implementation does not guarantee a notification if the operating system suspends or terminates the application before the countdown ends.

### Session Scout

Session Scout is a rule-based recommendation feature that suggests a focus duration based on previous study sessions.

The user selects a mood, and Session Scout finds the three most recent completed sessions matching that mood.

It then:

1. Retrieves matching completed sessions.
2. Selects the three most recent sessions.
3. Calculates their median completed duration.
4. Rounds the median to the nearest minute.
5. Limits the recommendation to 10-60 minutes.
6. Displays the recommendation and an explanation.

If fewer than three completed sessions are available, Session Scout recommends 25 minutes.

Users can apply the recommendation to an existing matching focus preset or dismiss it.

Session Scout works offline and does not use a trained machine learning model or external AI service.

### Session Scout Evaluation

Session Scout is evaluated against a fixed 25-minute baseline using synthetic cases.

Metrics include:

- Absolute prediction error
- Mean absolute error (MAE)
- Relative MAE reduction

Results from six synthetic evaluation cases:

| Metric | Session Scout | Fixed Baseline |
|--------|---------------|----------------|
| Mean Absolute Error | 2.33 minutes | 13.00 minutes |
| Relative MAE Reduction | 82.05% | - |

These results demonstrate the evaluation process. They do not establish real-world performance.

See [AI_FEATURE.md](AI_FEATURE.md) for the complete evaluation and limitations.

### Animations and Responsive Layouts

The application includes:

- Animated Session Scout recommendation panel
- Explicit focus indicator animation
- Responsive preset cards
- Centered content on larger screens
- Bottom navigation on phones
- Navigation rail on wider screens
- Reduced-motion support

The focus indicator uses an AnimationController and performs a short animation when activated.

The controller is disposed when the widget is removed.

When reduced motion is enabled, decorative animation is disabled and custom panel transition duration becomes zero.

### Background Statistics Processing

Study statistics are calculated using a background Dart isolate through Isolate.run().

The application:

1. Loads session records from SQLite.
2. Retrieves them through Riverpod.
3. Converts session records into simple data.
4. Sends the data to a background isolate.
5. Calculates study statistics.
6. Returns the results to the main isolate.
7. Displays the results on Dashboard and History.

Both screens use the same statistics provider.

When session history changes, Riverpod recalculates the statistics.

Using an isolate introduces overhead for small datasets, but demonstrates background processing for potentially larger calculations.

## State Management

Riverpod manages dependency injection and asynchronous application state.

Important providers include:

- focusDependenciesProvider
- focusPresetRepositoryProvider
- sessionLogRepositoryProvider
- focusPresetsProvider
- sessionHistoryProvider
- sessionScoutProvider
- studyStatisticsServiceProvider
- studyStatisticsProvider
- reduceMotionProvider

After database changes, the affected providers are invalidated so the UI can display updated information.

SQLite remains responsible for persistent data storage.

## Architecture

The application follows clean architecture with three main layers.

### Presentation Layer

Contains Flutter screens, reusable widgets, and Riverpod providers.

### Domain Layer

Contains entities, repository interfaces, and use cases.

### Data Layer

Contains SQLite models, database helpers, repository implementations, and the background statistics service.

The notification service is implemented under core because it is a platform-related service shared by the application.

See [ARCHITECTURE.md](ARCHITECTURE.md) for more information.

## Database

The application uses SQLite with two related tables.

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

The session_logs table references focus_presets through a foreign key.

Deleting a preset also deletes its associated session logs through cascade deletion.

## Running the Application

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android emulator or supported physical device

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

### Android Notification Setup

The Android manifest includes POST_NOTIFICATIONS permission.

The Android app uses Java 17 and core library desugaring.

For testing notifications:

1. Run the application on an Android emulator or physical device.
2. Open Settings.
3. Enable Reminders.
4. Select Save Settings.
5. Allow notification permission when prompted.
6. Create a focus preset.
7. Start a focus session.
8. Let the timer finish naturally.
9. Check that the session is saved and a notification appears.

Pressing Finish early should save a partial session without sending a completion notification.

Turning Reminders off should prevent notifications.

## Testing

### Format Code

```bash
dart format lib test
```

### Static Analysis

```bash
flutter analyze
```

### Run All Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Riverpod Tests

```bash
flutter test test/features/focus/presentation/focus_providers_test.dart
```

### Animation Tests

```bash
flutter test test/core/animation/animated_focus_indicator_test.dart
```

### Responsive Layout Tests

```bash
flutter test test/core/widgets/responsive_content_test.dart
```

### Statistics Calculation Tests

```bash
flutter test test/features/focus/domain/calculate_study_statistics_test.dart
```

### Background Isolate Tests

```bash
flutter test test/features/focus/data/study_statistics_service_test.dart
```

### Notification Controller Tests

```bash
flutter test test/core/notifications/focus_notification_controller_test.dart
```

The notification controller tests verify:

- Natural completion triggers a notification
- Early completion does not trigger a notification
- Manual completion does not trigger a notification
- Partial sessions do not trigger notifications
- Preset names are passed correctly

Real notification permission and display behavior must also be tested on Android.

## Development Progress

### Commits 1-8

- Flutter project initialization
- Clean architecture setup
- Domain entities and models
- SQLite integration
- Focus preset CRUD operations
- Mood filtering

### Commit 9

- Focus Timer
- Session history
- Manual session logging
- Study statistics
- Persistent settings

### Commit 10

- Session Scout recommendation algorithm
- Median-based calculation
- Fallback recommendation
- Algorithm tests

### Commit 11

- Session Scout Dashboard integration
- Mood selection
- Recommendation display
- Apply and Not now actions

### Commit 12

- Session Scout evaluation
- Fixed baseline comparison
- Mean absolute error calculation
- Evaluation documentation

### Commit 13

- Riverpod dependency injection
- Asynchronous data providers
- Dashboard and History integration
- Provider tests

### Commit 14

- Custom animations
- Responsive layouts
- Navigation rail for larger screens
- Reduced-motion support
- Animation and layout tests

### Commit 15

- Background statistics processing using Dart isolates
- StudyStatistics entity
- Pure Dart calculation
- Isolate service
- Riverpod integration
- Automated tests

### Commit 16

- Local notification service
- Android notification permission
- Reminder preference integration
- Focus Timer completion notification
- Notification controller tests

## Planned Features

- JSON import and export
- Additional unit and widget tests
- Integration testing
- Test coverage
- Final documentation and project polish

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

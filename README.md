
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application that helps students organize focus sessions, track their study progress, and get personalized study duration recommendations.

I developed this application as my graduate solo project for CSC 6360 - Mobile App Development at Georgia State University.

The application works offline and stores user data locally.

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
- file_picker
- share_plus
- path_provider

## Main Features

### 1. Focus Presets

Users can create and manage focus presets for different study activities.

The application supports:

- Creating new focus presets
- Editing existing presets
- Deleting presets with confirmation
- Filtering presets by mood
- Saving presets locally using SQLite

Each preset contains a name, mood tag, and duration.

Supported mood tags are:

- Focused
- Relaxed
- Motivated

Preset durations must be between 1 and 180 minutes.

### 2. Focus Timer

The Focus Timer allows users to start study sessions using their saved presets.

The timer supports:

- Starting a session
- Pausing and resuming
- Finishing a session early
- Resetting the timer
- Saving completed sessions
- Saving partially completed sessions
- Retrying failed session saves

I used Dart's `Stopwatch` to measure elapsed time and `Timer.periodic` to update the countdown display.

The stopwatch provides the elapsed time, while the periodic timer refreshes what the user sees.

Session records are stored in SQLite.

### 3. History and Insights

The History screen allows users to review their previous study sessions.

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

The Dashboard and History screens use the same statistics provider to display updated information.

### 4. Settings

Users can configure:

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference

Settings are stored locally using SharedPreferences.

The reduced-motion preference disables decorative animations where supported.

The reminder preference controls local focus-completion notifications.

The sound preference is stored, but separate sound functionality has not been implemented.

### 5. Local Notifications

Adaptive Focus Studio uses `flutter_local_notifications` to notify users when a focus session finishes naturally.

The notification feature:

- Initializes the notification plugin at startup
- Requests permission when reminders are enabled
- Saves the reminder preference
- Checks whether reminders are enabled
- Sends a notification after a naturally completed session is saved
- Avoids notifications for sessions finished early
- Avoids notifications when a timer is paused or reset
- Prevents duplicate notifications for the same completion

Example notification:

**Title:** Focus session completed

**Body:** You finished your Morning Study focus session.

On Android 13 and later, notification permission is requested.

Notifications are generated locally without requiring an internet connection.

The application uses immediate notifications rather than scheduled notifications.

The timer must remain active to detect completion. Notifications may not be delivered if the operating system suspends or terminates the application before the countdown finishes.

### 6. JSON Backup and Restore

The application allows users to export and import their focus data as JSON files.

This feature is available in Settings under Data Backup.

#### Exporting a Backup

To export data:

1. Open Settings.
2. Select Export JSON Backup.
3. Choose where to save or share the file.
4. Keep the JSON file for future restoration.

The exported backup contains:

- Focus presets
- Session logs
- Preset IDs
- Session IDs
- Relationships between presets and sessions
- Backup format version
- Export timestamp

SharedPreferences settings are not included.

#### Importing a Backup

To restore data:

1. Open Settings.
2. Select Import JSON Backup.
3. Read the replacement warning.
4. Confirm the operation.
5. Select a JSON backup file.
6. Wait for the data to be restored.

Importing a backup replaces the current presets and session history.

Users should export their current data before importing another backup.

Cancelling file selection leaves the existing data unchanged.

#### Backup Validation

Before importing data, the application validates:

- JSON structure
- Backup format version
- Application name
- Export timestamp
- Required preset fields
- Supported mood tags
- Positive preset durations
- Unique preset IDs
- Required session fields
- Valid session dates
- Non-negative session durations
- Supported session statuses
- Unique session IDs
- Valid preset references

Invalid backups are rejected before database changes begin.

#### Database Transactions

The restore operation uses a SQLite transaction.

The application:

1. Validates the backup.
2. Starts a database transaction.
3. Deletes existing session logs.
4. Deletes existing focus presets.
5. Inserts the imported presets.
6. Inserts the imported session logs.
7. Commits the transaction.

If a database operation fails, SQLite rolls back the transaction.

Importing the same backup again does not create duplicate records because the restore operation replaces the existing data.

#### Example Backup Format

```json
{
  "formatVersion": 1,
  "app": "Adaptive Focus Studio",
  "exportedAt": "2026-10-28T17:00:00.000Z",
  "focusPresets": [
    {
      "id": 1,
      "name": "Morning Study",
      "moodTag": "Focused",
      "durationMinutes": 25
    }
  ],
  "sessionLogs": [
    {
      "id": 1,
      "presetId": 1,
      "date": "2026-10-28T14:00:00.000Z",
      "completedSeconds": 1500,
      "status": "completed",
      "notes": ""
    }
  ]
}
```

The backup feature works offline.

## Session Scout

Session Scout is a rule-based recommendation feature that suggests a focus duration using previous study sessions.

It uses completed sessions that match the selected mood.

### How It Works

1. The user selects a mood.
2. The application supplies completed sessions matching that mood.
3. Session Scout selects the three most recent matching sessions.
4. It calculates the median completed duration.
5. It rounds the result to the nearest minute.
6. It limits the recommendation to between 10 and 60 minutes.
7. It displays the recommendation with an explanation.

If fewer than three completed sessions are available, Session Scout recommends 25 minutes.

Users can apply the recommendation to an existing matching focus preset or dismiss it.

Session Scout runs entirely offline.

It does not use a trained machine learning model or an external AI service.

### Why I Used the Median

I chose the median because it is less affected by unusually long or short study sessions than the mean.

For example, if the three most recent completed sessions lasted 20, 25, and 60 minutes, the median would be 25 minutes.

This gives a more stable recommendation than using the average.

### Session Scout Evaluation

The project includes a Session Scout evaluation against a fixed 25-minute baseline using six synthetic test cases.

The evaluation uses:

- Absolute prediction error
- Mean absolute error (MAE)
- Relative MAE reduction

Previously recorded evaluation results:

| Metric | Session Scout | Fixed Baseline |
|---|---:|---:|
| Mean Absolute Error | 2.33 minutes | 13.00 minutes |
| Relative MAE Reduction | 82.05% | - |

These values are from the existing project documentation and should be checked against the evaluation test output before final submission.

The results illustrate the evaluation approach using synthetic data. They do not establish how well the algorithm will perform with real users.

See [AI_FEATURE.md](AI_FEATURE.md) for the recommendation algorithm and its limitations.

## Graduate-Level Extensions

### 1. Custom Animations

The application includes both implicit and explicit animations.

Examples include:

- Animated Session Scout recommendation panel
- Animated focus indicator
- Responsive preset cards
- Reduced-motion support

The focus indicator uses an `AnimationController`.

The controller is disposed when its widget is removed to avoid unnecessary resource usage.

When reduced motion is enabled, decorative animations are disabled and supported custom transitions use zero duration.

### 2. Background Processing

Study statistics are calculated using a Dart isolate through `Isolate.run()`.

The process works as follows:

1. Session records are loaded from SQLite.
2. Riverpod retrieves the session history.
3. Session records are converted into simple data.
4. The data is passed to a background isolate.
5. The isolate calculates the statistics.
6. The results are returned to the main isolate.
7. The Dashboard and History screens display the results.

This keeps the statistics calculation separate from the main UI isolate.

For small datasets, an isolate can introduce additional overhead. However, it demonstrates background processing and provides a foundation for handling larger amounts of session data.

### 3. Local Notifications

The application supports local notifications for naturally completed focus sessions.

Notifications are controlled by the reminder preference stored in SharedPreferences.

The implementation includes notification permission handling and protection against duplicate notifications.

### 4. File Operations

The JSON backup feature demonstrates:

- File creation
- JSON encoding and decoding
- File selection
- Native file sharing
- File reading
- Data validation
- Transactional database restoration

All backup operations work locally.

### 5. Accessibility and Responsive Design

The application supports:

- Reduced-motion preferences
- Responsive layouts
- Centered content on larger screens
- Bottom navigation on phones
- Navigation rail on wider screens
- Form validation and error feedback

These features help make the application easier to use on different screen sizes.

## State Management

I used Riverpod for dependency injection and asynchronous state management.

Important providers include:

- `focusDependenciesProvider`
- `focusPresetRepositoryProvider`
- `sessionLogRepositoryProvider`
- `focusPresetsProvider`
- `sessionHistoryProvider`
- `sessionScoutProvider`
- `studyStatisticsServiceProvider`
- `studyStatisticsProvider`
- `reduceMotionProvider`
- `focusBackupServiceProvider`

When the database changes, the affected providers are invalidated so the interface can display updated data.

After a backup is restored, the preset and session history providers are invalidated.

SQLite remains responsible for persistent data storage.

## Architecture

The application follows clean architecture with three main layers.

### Presentation Layer

Contains:

- Flutter screens
- Reusable widgets
- Riverpod providers
- UI state and navigation

### Domain Layer

Contains:

- Entities
- Repository interfaces
- Use cases
- Session Scout logic
- Study statistics calculations

### Data Layer

Contains:

- SQLite database helper
- Data models
- Repository implementations
- Backup services
- Background statistics service

Platform-related services, including notifications, are implemented under the core directory.

The architecture separates UI code from business logic and data access.

See [ARCHITECTURE.md](ARCHITECTURE.md) for more information.

## Database Design

The application uses SQLite with two related tables.

### focus_presets

| Column | Description |
|---|---|
| id | Unique preset ID |
| name | Preset name |
| mood_tag | Selected mood |
| duration_minutes | Planned duration |

### session_logs

| Column | Description |
|---|---|
| id | Unique session ID |
| preset_id | Related focus preset |
| date | Session date |
| completed_seconds | Completed duration |
| status | Session status |
| notes | Optional session notes |

The `session_logs` table references `focus_presets` through a foreign key.

Deleting a preset also deletes its associated session logs through cascade deletion.

No database migration is required for the JSON backup feature.

## Running the Application

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android emulator or supported physical device

The project was developed using Flutter 3.47.2 and Dart 3.13.2.

### Install Dependencies

From the project directory, run:

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

### Build an Android APK

```bash
flutter build apk --release
```

The release APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Testing Notifications

1. Run the application on an Android emulator or physical device.
2. Open Settings.
3. Enable Reminders.
4. Select Save Settings.
5. Allow notification permission when prompted.
6. Create a focus preset.
7. Start a focus session.
8. Let the timer finish naturally.
9. Check that the session is saved and a notification appears.

## Testing Backup and Restore

1. Create at least two focus presets.
2. Complete a study session.
3. Open Settings.
4. Select Export JSON Backup.
5. Save the exported JSON file.
6. Create another preset.
7. Select Import JSON Backup.
8. Confirm the replacement warning.
9. Select the previously exported file.
10. Check that the original presets and sessions are restored.
11. Check that the additional preset has been removed.
12. Import the same backup again and check that no duplicate records appear.

Additional cases to test:

- Cancelling file selection
- Importing invalid JSON
- Importing an unsupported backup version
- Importing a backup with an invalid preset reference
- Importing an empty backup

An empty backup intentionally removes all presets and sessions after confirmation.

## Automated Testing

I used unit tests, widget tests, database tests, and integration tests to verify the application.

### Test Results

Earlier project documentation recorded the following results:

| Test Category | Previously Recorded Result |
|---|---|
| Unit and widget tests | 187 passed |
| Integration tests | 7 passed |
| Static analysis | No issues reported |

These are historical results. The final counts and pass status need to be confirmed from the latest test runs before submission.

### Format Code

```bash
dart format lib test integration_test
```

### Static Analysis

```bash
flutter analyze
```

### Run Unit and Widget Tests

```bash
flutter test test/
```

### Run Integration Tests

Start an Android emulator or connect a supported device, then run:

```bash
flutter test integration_test/focus_workflow_test.dart
```

### Run Individual Tests

Widget tests:

```bash
flutter test test/widget_test.dart
```

Focus preset form tests:

```bash
flutter test test/features/focus/presentation/screens/preset_form_screen_test.dart
```

Focus timer tests:

```bash
flutter test test/features/focus/presentation/screens/focus_timer_screen_test.dart
```

Animation tests:

```bash
flutter test test/core/animation/animated_focus_indicator_test.dart
```

Responsive layout tests:

```bash
flutter test test/core/widgets/responsive_content_test.dart
```

Notification controller tests:

```bash
flutter test test/core/notifications/focus_notification_controller_test.dart
```

Session Scout calculation tests:

```bash
flutter test test/features/focus/domain/calculate_session_scout_test.dart
```

Session Scout evaluation tests:

```bash
flutter test test/features/focus/domain/evaluate_session_scout_test.dart
```

JSON codec tests:

```bash
flutter test test/features/focus/data/services/focus_backup_codec_test.dart
```

JSON backup service tests:

```bash
flutter test test/features/focus/data/services/focus_backup_service_test.dart
```

The database and backup tests use in-memory SQLite databases to avoid modifying the application's saved data.

### Test Coverage

The automated tests cover areas including:

- Database creation and relationships
- Focus preset CRUD operations
- Session log operations
- Domain validation
- Session Scout calculations
- Session Scout evaluation
- Riverpod providers
- Form validation
- Focus timer controls
- Custom animations
- Responsive layouts
- Study statistics
- Notification controller behavior
- JSON backup validation
- JSON export and import
- Database transaction behavior
- Complete application workflows

The integration tests exercise application workflows on an Android emulator.

See [Testing Documentation](docs/testing.md) for the testing approach, test cases, and evidence.

## Project Management

I used ClickUp to organize and track the development of Adaptive Focus Studio.

Since this was an individual project, I managed the planning, implementation, testing, and documentation myself.

I used a Kanban-style board to keep track of tasks and move them through different stages of development.

The main task statuses were:

- **Backlog:** Tasks planned for future development.
- **To Do:** Tasks ready to be worked on.
- **In Progress:** Tasks I was currently implementing or testing.
- **Done:** Tasks that had been completed.

I divided the project into smaller tasks covering the main application features, database implementation, Session Scout, testing, and documentation.

This helped me track my progress and identify which features still needed attention.

### ClickUp Project Board

[View Adaptive Focus Studio ClickUp Board](https://sharing.clickup.com/90141777100/b/h/2kydwq6c-474/65ac003664e3c60)

The board contains the development tasks and their progress statuses.

For more details about the development process, see the [Development Journal](docs/development-journal.md).

## Development Progress

I developed the project incrementally using 20 meaningful Git commits.

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

### Commit 17

- JSON backup codec
- JSON export and import service
- File selection and native sharing
- Backup validation
- Transactional SQLite restoration
- Duplicate prevention through replacement
- Settings screen integration
- JSON and database tests

### Commit 18

- Integration testing
- Complete focus workflow verification
- Additional automated test coverage

### Commit 19

- Widget test stabilization
- Focus timer UI tests
- Preset form validation tests
- Test hang fixes
- Full unit and widget test verification

### Commit 20

- Final static analysis cleanup
- Database helper constructor cleanup
- Backup service cleanup
- Final README documentation
- Final automated testing and project verification

## Project Documentation

Additional documentation is available in the following files:

| Document | Description |
|---|---|
| [Architecture](ARCHITECTURE.md) | Explains the project architecture, layers, repositories, and state management |
| [Session Scout Documentation](AI_FEATURE.md) | Explains the recommendation algorithm, fallback rules, and limitations |
| [Development Journal](docs/development-journal.md) | Documents the development process, milestones, and project management |
| [Testing Documentation](docs/testing.md) | Explains the testing strategy, test cases, and verification results |

## Screenshots and Evidence

Screenshots and other project evidence are organized in the `docs/evidence/` directory.

The evidence is intended to support the development journal and testing documentation.

The screenshots include examples of application features and development or testing activities, where captured.

See the [Development Journal](docs/development-journal.md) and [Testing Documentation](docs/testing.md) for the relevant evidence references.

## Limitations

The current application has a few limitations:

- Session Scout uses a rule-based algorithm rather than a trained machine learning model.
- The Session Scout evaluation uses synthetic data rather than real user data.
- Notifications are immediate and depend on the timer reaching completion while the application remains active.
- The sound preference is stored, but separate sound functionality is not implemented.
- JSON backups contain focus presets and session history, but not SharedPreferences settings.
- All application data is stored locally without cloud synchronization.

These limitations are documented so the current functionality is clear.

## Conclusion

Adaptive Focus Studio brings together focus session management, local data storage, study statistics, and personalized duration recommendations in one Flutter application.

Through this project, I worked with clean architecture, Riverpod, SQLite, asynchronous programming, Dart isolates, animations, notifications, file operations, and automated testing.

The project also gave me experience organizing a larger Flutter application into separate layers and testing its functionality before final submission.

## GitHub Repository

[Adaptive Focus Studio GitHub Repository](https://github.com/isaacowusu3461/Adaptive_Focus_Studio)

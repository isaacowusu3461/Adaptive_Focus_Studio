
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
- Dart Isolates for background processing

## Features

### Focus Presets

Users can create and manage focus presets for different study activities.

Features include:

- Create new focus presets
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

The Focus Timer allows users to run study sessions using their saved presets.

Features include:

- Start a focus session
- Pause and resume the timer
- Finish a session early
- Reset the timer
- Automatically save completed sessions
- Save partially completed sessions

Session records are stored in SQLite.

### History & Insights

The History screen displays previously recorded study sessions.

Users can:

- View saved session logs
- Add manual session logs
- Edit existing session logs
- Delete session logs
- View study statistics

The application calculates:

- Total number of sessions
- Completed sessions
- Partial sessions
- Total study time
- Average session duration
- Longest session duration
- Completion rate

These statistics are calculated using a background Dart isolate.

### Settings

Users can configure the following preferences:

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference

Settings are stored locally using SharedPreferences.

The reduced-motion preference is connected to the application's custom animations.

Reminder and sound settings currently save user preferences. Their functional integrations are planned for later commits.

### Session Scout

Session Scout is a rule-based recommendation feature that suggests a focus duration based on the user's previous study sessions.

The user selects a mood, and Session Scout finds the three most recent completed sessions matching that mood.

It then:

1. Retrieves the matching completed sessions.
2. Selects the three most recent sessions.
3. Calculates the median completed duration.
4. Rounds the median to the nearest whole minute.
5. Limits the recommendation to 10-60 minutes.
6. Displays the suggested duration with an explanation.

If fewer than three completed sessions are available, Session Scout recommends the standard 25-minute duration.

Users can apply the recommendation to an existing focus preset or dismiss it.

Session Scout works entirely offline and does not use a trained machine learning model or external AI service.

### Session Scout Evaluation

Session Scout is evaluated against a fixed 25-minute baseline.

The evaluation compares the predicted study durations against target durations using synthetic test cases.

Metrics include:

- Absolute prediction error
- Mean absolute error (MAE)
- Relative MAE reduction

Results from six synthetic evaluation cases:

| Metric | Session Scout | Fixed Baseline |
|--------|---------------|----------------|
| Mean Absolute Error | 2.33 minutes | 13.00 minutes |
| Relative MAE Reduction | 82.05% | - |

These results demonstrate the evaluation process. They do not establish that Session Scout performs better with real-world study data.

See [AI_FEATURE.md](AI_FEATURE.md) for the complete explanation, evaluation results, and limitations.

### Animations and Responsive Layouts

The application includes custom animations and responsive layouts.

Implemented features:

- Animated Session Scout recommendation panel
- Explicit focus indicator animation
- Responsive preset cards
- Centered content on larger screens
- Bottom navigation on phones
- Navigation rail on wider screens
- Reduced-motion support

The focus indicator uses an AnimationController and performs a short animation when activated.

The controller is disposed when the widget is removed.

When reduced motion is enabled, decorative animation is disabled and the custom panel transition duration becomes zero.

### Background Statistics Processing

Study statistics are calculated in a background Dart isolate using `Isolate.run()`.

This feature moves the calculation work away from Flutter's main UI isolate.

The implementation follows these steps:

1. Load session records from SQLite.
2. Retrieve the records through the Riverpod session history provider.
3. Convert the session records into simple data containing status and duration.
4. Pass the data to a background isolate.
5. Calculate the study statistics.
6. Return the results to the main isolate.
7. Display the statistics on the Dashboard and History screens.

The background calculation includes:

- Total sessions
- Completed sessions
- Partial sessions
- Total study duration
- Average session duration
- Longest session
- Completion rate

Both the Dashboard and History screens use the same statistics provider.

When session history changes, Riverpod recalculates the statistics.

Using an isolate can introduce overhead for small datasets. This implementation demonstrates background processing that can be useful for larger calculations.

## State Management

The application uses Riverpod for state management and dependency injection.

Riverpod manages:

- Repository dependencies
- Use case dependencies
- Focus preset lists
- Session history
- Session Scout recommendations
- Study statistics
- Reduced-motion preference

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

After database changes, the relevant providers are invalidated so the UI can display updated information.

SQLite remains responsible for persistent data storage.

## Architecture

The application follows clean architecture with three main layers.

### Presentation Layer

Contains Flutter screens, reusable widgets, and Riverpod providers.

### Domain Layer

Contains entities, repository interfaces, and use cases.

### Data Layer

Contains SQLite models, database helpers, repository implementations, and the background statistics service.

The application is designed to work offline.

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

### Session Scout Algorithm Tests

```bash
flutter test test/features/focus/domain/calculate_session_scout_test.dart
```

### Session Scout Evaluation Tests

```bash
flutter test test/features/focus/domain/evaluate_session_scout_test.dart
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

The statistics tests cover empty histories, completed and partial sessions, total duration, averages, longest sessions, completion rate, invalid inputs, and calculations through `Isolate.run()`.

## Development Progress

### Commits 1-8

- Flutter project initialization
- Clean architecture setup
- Domain entities and models
- SQLite database integration
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
- Median-based duration calculation
- Fallback recommendation
- Algorithm unit tests

### Commit 11

- Session Scout Dashboard integration
- Mood selection
- Recommendation display
- Apply and Not now actions

### Commit 12

- Session Scout evaluation
- Fixed 25-minute baseline comparison
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
- StudyStatistics domain entity
- Pure Dart statistics calculation
- StudyStatisticsService using Isolate.run()
- Riverpod statistics provider
- Dashboard and History integration
- Statistics unit tests
- Isolate service tests

## Planned Features

- Local notifications
- JSON import and export
- Additional unit and widget tests
- Integration testing
- Test coverage
- Final documentation and project polish

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

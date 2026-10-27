
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter application for
organizing focus sessions, tracking study progress,
and recommending personalized study durations.

Developed for CSC 6360 - Mobile App Development
at Georgia State University.

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

## Features

### Focus Presets

- Create, edit, and delete focus presets
- Filter presets by mood
- Store presets locally using SQLite

Supported moods:
- Focused
- Relaxed
- Motivated

### Focus Timer

- Start, pause, and resume sessions
- Finish sessions early
- Reset the countdown
- Save completed and partial sessions

### History & Insights

- View session history
- Add manual session logs
- Edit and delete session logs
- View completed-session count
- View total study time
- View average session duration

### Settings

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference
- Persistent settings using SharedPreferences

### Session Scout

Session Scout uses the three most recent completed
sessions matching a selected mood to recommend
a study duration.

The algorithm:
1. Finds completed sessions for the selected mood.
2. Selects the three most recent sessions.
3. Calculates their median completed duration.
4. Rounds to the nearest minute.
5. Limits recommendations to 10-60 minutes.
6. Uses a 25-minute fallback when history is insufficient.

The Dashboard lets users generate recommendations,
view explanations, apply durations to matching
presets, or dismiss recommendations.

### Session Scout Evaluation

Session Scout is compared against a fixed
25-minute baseline using synthetic test cases.

The evaluation calculates absolute prediction
error and mean absolute error.

Synthetic example results:
- Session Scout MAE: 2.33 minutes
- Baseline MAE: 13.00 minutes
- Relative MAE reduction: approximately 82.05%

These synthetic results do not establish
real-world superiority.

See AI_FEATURE.md for details.

## Riverpod State Management

Riverpod manages application dependencies
and asynchronous data loading.

Providers include:
- focusDependenciesProvider
- focusPresetRepositoryProvider
- sessionLogRepositoryProvider
- createFocusPresetProvider
- updateFocusPresetProvider
- deleteFocusPresetProvider
- saveSessionLogProvider
- getSessionScoutRecommendationProvider
- focusPresetsProvider
- sessionHistoryProvider
- sessionScoutProvider

The Dashboard and History screens use
ConsumerStatefulWidget.

Database changes trigger provider invalidation,
allowing the screens to reload saved data.

The app still uses SQLite for persistent storage.

## Architecture

The project follows clean architecture:

- Presentation: Flutter screens and Riverpod providers
- Domain: Entities, repository interfaces, and use cases
- Data: SQLite models and repository implementations

See ARCHITECTURE.md.

## Database

The application stores:
- focus_presets
- session_logs

Deleting a preset also deletes its related
session logs through SQLite foreign-key
cascade deletion.

## Running the App

Install packages:

    flutter pub get

Start the app:

    flutter run

## Testing

Format code:

    dart format lib test

Analyze:

    flutter analyze

Run all tests:

    flutter test

Run Riverpod tests:

    flutter test test/features/focus/presentation/focus_providers_test.dart

Run widget tests:

    flutter test test/widget_test.dart

Run Session Scout tests:

    flutter test test/features/focus/domain/calculate_session_scout_test.dart

Run evaluation tests:

    flutter test test/features/focus/domain/evaluate_session_scout_test.dart

## Development Progress

Commits 1-8:
Project setup, architecture, SQLite,
and preset management.

Commit 9:
Focus timer, history, statistics,
and settings.

Commit 10:
Session Scout algorithm.

Commit 11:
Session Scout Dashboard integration.

Commit 12:
Session Scout baseline evaluation.

Commit 13:
Riverpod dependency injection,
asynchronous providers, and UI integration.

## Planned Features

- Animations and responsive layouts
- Dart isolate for statistics
- Local notifications
- JSON import and export
- Additional unit and widget tests
- Integration testing
- Coverage and final documentation

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

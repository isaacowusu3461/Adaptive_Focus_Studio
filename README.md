
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application
for organizing focus sessions, tracking study progress,
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
- Save presets locally using SQLite

Supported moods:
- Focused
- Relaxed
- Motivated

### Focus Timer

- Start, pause, and resume focus sessions
- Finish sessions early
- Reset the timer
- Save completed and partial sessions

### History & Insights

- View study session history
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

Reminder and sound settings currently save preferences.
Their functional integrations are planned for later work.

### Session Scout

Session Scout recommends a study duration using
the three most recent completed sessions matching
the selected mood.

It calculates the median duration, rounds to the
nearest minute, and limits the result to 10-60 minutes.

When there is insufficient history, it recommends
25 minutes.

Users can apply the recommendation to a matching
focus preset or dismiss it.

### Session Scout Evaluation

Session Scout is compared with a fixed 25-minute
baseline using synthetic evaluation cases.

The evaluation calculates absolute errors and
mean absolute error (MAE).

Synthetic results:
- Session Scout MAE: 2.33 minutes
- Baseline MAE: 13.00 minutes
- Relative MAE reduction: approximately 82.05%

These results demonstrate the evaluation method
and do not prove real-world superiority.

See AI_FEATURE.md for details.

### Animations and Responsive Layouts

The application includes:
- Animated Session Scout panel expansion
- Explicit pulsing focus indicator
- Responsive preset card layout
- Centered content on larger screens
- Bottom navigation on phones
- Navigation rail on wider screens
- Reduced-motion preference

The pulsing indicator uses an AnimationController
and disposes it when removed.

Reduced motion disables the custom decorative
animation and removes the panel transition duration.

## Riverpod State Management

Riverpod manages repositories, use cases,
saved presets, session history, and
Session Scout recommendations.

The application invalidates providers after
database changes to reload the affected data.

SQLite remains responsible for permanent storage.

## Architecture

The application follows clean architecture:

- Presentation: Flutter screens and Riverpod providers
- Domain: Entities, interfaces, and use cases
- Data: SQLite models and repository implementations

See ARCHITECTURE.md for details.

## Database

Tables:
- focus_presets
- session_logs

Deleting a preset also deletes its related
session logs through foreign-key cascade deletion.

## Running the Application

Install packages:

    flutter pub get

Run:

    flutter run

## Testing

Format:

    dart format lib test

Analyze:

    flutter analyze

Run all tests:

    flutter test

Run animation tests:

    flutter test test/core/animation/animated_focus_indicator_test.dart

Run responsive layout tests:

    flutter test test/core/widgets/responsive_content_test.dart

Run Riverpod tests:

    flutter test test/features/focus/presentation/focus_providers_test.dart

Run widget tests:

    flutter test test/widget_test.dart

## Development Progress

Commits 1-8:
Project setup, clean architecture, SQLite,
and focus preset management.

Commit 9:
Timer, history, statistics, and settings.

Commit 10:
Session Scout algorithm.

Commit 11:
Session Scout Dashboard integration.

Commit 12:
Session Scout evaluation.

Commit 13:
Riverpod state management.

Commit 14:
Animations, responsive layouts,
and reduced-motion support.

## Planned Features

- Background statistics processing using isolates
- Local notifications
- JSON import and export
- Additional unit and widget tests
- Integration testing
- Coverage and final documentation

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

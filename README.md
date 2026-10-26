
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
- SQLite (sqflite)
- SharedPreferences
- Material Design 3
- intl
- sqflite_common_ffi for database tests

## Features

### Focus Presets

- Create focus presets
- Edit saved presets
- Delete presets with confirmation
- Filter presets by mood
- Store presets in SQLite

Supported moods:
- Focused
- Relaxed
- Motivated

### Focus Timer

- Start a countdown
- Pause and resume
- Finish early
- Reset the timer
- Automatically save completed sessions
- Save partial sessions

### History & Insights

- View saved sessions
- Add manual session logs
- Edit session logs
- Delete session logs
- View completed-session count
- View total study time
- View average session duration

### Settings

- Default focus duration
- Reminder preference
- Reduced-motion preference
- Sound preference
- Persistent storage using SharedPreferences

### Session Scout

Session Scout recommends study durations based on
previously completed sessions for a selected mood.

How it works:

1. Select a mood on the Dashboard.
2. Tap Get Recommendation.
3. Session Scout finds the three most recent
   completed sessions for that mood.
4. It calculates their median completed duration.
5. The recommendation is rounded to the nearest
   minute and limited to 10-60 minutes.
6. The suggested duration and explanation appear.
7. Tap Apply to update a matching focus preset.
8. Tap Not now to dismiss the recommendation.

If fewer than three completed sessions match
the selected mood, Session Scout recommends
the standard 25-minute duration.

Applying a recommendation updates the selected
preset in SQLite. Future sessions using that
preset use the new duration.

## Architecture

The application follows clean architecture:

- Presentation: Flutter screens and UI state
- Domain: Entities, repository interfaces, use cases
- Data: SQLite models and repositories

See ARCHITECTURE.md for details.

## Database

Database file:

adaptive_focus_studio.db

Tables:
- focus_presets
- session_logs

Deleting a preset also deletes its related
session logs through foreign-key cascade deletion.

## Running the Application

Install dependencies:

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

Run widget tests:

    flutter test test/widget_test.dart

Run Session Scout algorithm tests:

    flutter test test/features/focus/domain/calculate_session_scout_test.dart

Run Session Scout integration tests:

    flutter test test/features/focus/domain/get_session_scout_recommendation_test.dart

## Development Progress

Commits 1-8:
Project setup, clean architecture, SQLite,
and focus preset management.

Commit 9:
Focus timer, session history, statistics,
and persistent settings.

Commit 10:
Session Scout recommendation algorithm
and automated tests.

Commit 11:
Session Scout Dashboard interface,
mood selection, recommendation display,
and Apply/Not now actions.

## Planned Features

- Session Scout evaluation against a fixed baseline
- Riverpod state management
- Animations and responsive layouts
- Dart isolate for statistics
- Local notifications
- JSON export and import
- Additional unit and widget tests
- Integration testing
- Coverage and final documentation

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

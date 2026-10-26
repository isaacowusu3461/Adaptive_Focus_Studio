
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application
that helps students organize focus sessions, track
study progress, and receive personalized study
duration recommendations.

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

## Implemented Features

### Focus Presets

- Create focus presets
- Edit saved presets
- Delete presets with confirmation
- Filter presets by mood
- Save presets locally using SQLite

Supported moods:
- Focused
- Relaxed
- Motivated

### Focus Timer

- Start a countdown
- Pause and resume
- Finish early
- Reset the timer
- Automatically record completed sessions
- Record partial sessions

### History & Insights

- View saved study sessions
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
- Persistent settings using SharedPreferences

### Session Scout Algorithm

Session Scout calculates a suggested study duration
using previously completed study sessions.

Algorithm:

1. Retrieve saved focus presets and session logs.
2. Find presets matching the requested mood.
3. Select completed sessions linked to those presets.
4. Sort matching sessions from newest to oldest.
5. Select the three most recent completed sessions.
6. Calculate their median completed duration.
7. Round the median to the nearest whole minute.
8. Clamp the recommendation between 10 and 60 minutes.
9. Return a recommendation with an explanation.

If fewer than three completed sessions match the
requested mood, Session Scout recommends 25 minutes.

Session Scout also returns:
- The requested mood
- The number of sessions used
- Whether the fallback was used
- An explanation of the recommendation

The algorithm is implemented in the domain layer.

The interactive Dashboard integration is planned
for Commit 11.

## Architecture

The project follows clean architecture:

- Presentation: Flutter screens and UI state
- Domain: Entities, repository interfaces, and use cases
- Data: SQLite models and repository implementations

See ARCHITECTURE.md for additional details.

## Database

Database file:

adaptive_focus_studio.db

Tables:
- focus_presets
- session_logs

Deleting a focus preset also deletes its related
session logs through SQLite foreign-key cascade
deletion.

## Running the Application

Install dependencies:

    flutter pub get

Run the application:

    flutter run

## Testing

Format Dart code:

    dart format lib test

Run static analysis:

    flutter analyze

Run all tests:

    flutter test

Run Session Scout calculation tests:

    flutter test test/features/focus/domain/calculate_session_scout_test.dart

Run Session Scout repository integration tests:

    flutter test test/features/focus/domain/get_session_scout_recommendation_test.dart

## Development Progress

### Commits 1-8

Project initialization, clean architecture,
navigation, SQLite, and preset management.

### Commit 9

Combined timer, session history, statistics,
and persistent settings.

### Commit 10

Implemented the Session Scout recommendation
algorithm, repository integration, and tests.

## Planned Features

- Session Scout Dashboard interface
- Session Scout evaluation against a fixed baseline
- Riverpod state management
- Animations and responsive layouts
- Background statistics processing using isolates
- Local notifications
- JSON export and import
- Additional unit and widget tests
- Integration testing
- Coverage and final documentation

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

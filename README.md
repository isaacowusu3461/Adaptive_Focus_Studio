
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application
for managing focus presets, running study timers,
recording sessions, and reviewing study progress.

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

### Focus Timer

- Select a saved preset
- Start a countdown
- Pause and resume
- Finish a session early
- Reset the timer
- Save completed and partial sessions to SQLite
- Display elapsed time and progress

### History & Insights

- View saved study sessions
- Add manual session logs
- Edit existing session logs
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

Reminder notifications, animations, and sound effects
will be connected in later commits.

### Planned

- Session Scout recommendations
- Riverpod state management
- Animated interfaces
- Background statistics processing
- Local notifications
- JSON export and import
- Additional automated tests and coverage

## Architecture

The application follows clean architecture:

- Presentation: Flutter screens and UI state
- Domain: Entities, repository interfaces, use cases
- Data: SQLite models and repository implementations

See ARCHITECTURE.md for details.

## Database

Database file:

adaptive_focus_studio.db

Tables:

### focus_presets

- id
- name
- mood_tag
- duration_minutes

### session_logs

- id
- preset_id
- date
- completed_seconds
- status
- notes

Deleting a preset also deletes related session logs.

## Running the Application

Install dependencies:

    flutter pub get

Run:

    flutter run

## Testing

Static analysis:

    flutter analyze

All tests:

    flutter test

Session repository tests:

    flutter test test/features/focus/data/session_log_repository_test.dart

Session use case tests:

    flutter test test/features/focus/domain/save_session_log_test.dart

Widget tests:

    flutter test test/widget_test.dart

## Development Progress

Commits 1-8 implemented project setup, architecture,
SQLite, and focus preset management.

Commit 9 combines the original planned Commits 9-13:

- Focus timer interface
- Countdown lifecycle
- Session recording
- History and Insights
- Session CRUD and statistics
- Persistent application settings

## GitHub

https://github.com/isaacowusu3461/Adaptive_Focus_Studio

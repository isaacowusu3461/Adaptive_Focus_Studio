
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application
that helps students organize study sessions, manage
focus presets, and track their study progress.

This project is being developed individually for
CSC 6360 - Mobile App Development at
Georgia State University.

## Developer

Isaac Owusu

## Project Overview

The application is designed to work offline.

Students can create, edit, delete, and filter focus
presets on the Dashboard. Saved presets remain
available after restarting the application.

SQLite stores focus presets and session logs.
SharedPreferences will store application settings.

## Implemented Features

- Welcome screen
- Dashboard, History, and Settings navigation
- SQLite database schema and models
- Focus preset repository CRUD operations
- Create focus presets
- Edit existing focus presets
- Delete presets with confirmation
- Automatically delete related session logs
- Filter presets by mood
- Form validation
- Persistent SQLite storage
- Display saved presets on the Dashboard
- Open the timer with a selected preset
- Unit, database, and widget tests

## Planned Features

- Functional countdown timer
- Save completed focus sessions
- Session history and statistics
- Session Scout recommendations
- Persistent settings
- Riverpod state management
- Animations and responsive improvements
- Local notifications
- JSON export and import
- Integration testing

## Technologies

- Flutter and Dart
- SQLite
- SharedPreferences
- Riverpod (planned)
- Material Design 3
- sqflite_common_ffi for database testing

## Architecture

The project follows clean architecture:

- Presentation: Screens, widgets, and UI state
- Domain: Entities, repository contracts, and use cases
- Data: SQLite models and repository implementations

See ARCHITECTURE.md for more details.

## Local Database

Database name:

adaptive_focus_studio.db

Tables:
- focus_presets
- session_logs

Focus presets store a name, mood tag, and
planned duration.

Session logs store a related preset ID, date,
completed duration, status, and notes.

Deleting a preset also deletes its related logs
through SQLite foreign-key cascade deletion.

## Preset Management

### Creating a Preset

1. Open the Dashboard.
2. Tap New.
3. Enter a preset name, mood, and duration.
4. Tap Save Preset.

### Editing a Preset

1. Open the Dashboard.
2. Tap Edit on an existing preset.
3. Change the name, mood, or duration.
4. Tap Update Preset.

### Deleting a Preset

1. Open the Dashboard.
2. Tap Delete on a saved preset.
3. Read the confirmation dialog.
4. Tap Delete to confirm or Cancel to keep it.

Deleting a preset permanently removes it and
any related session logs.

### Filtering Presets

Use the Filter by Mood dropdown on the Dashboard.

Available options:
- All
- Focused
- Relaxed
- Motivated

Selecting a mood displays matching presets only.

Selecting All displays every saved preset.

Filtering does not change the SQLite database.

### Validation

Preset names cannot be blank or exceed
50 characters.

Durations must be between 1 and 180 minutes.

## Current Progress

### Commit 1
Initialized the Flutter project.

### Commit 2
Introduced clean architecture and domain components.

### Commit 3
Created the main screens and navigation.

### Commit 4
Implemented SQLite database schema and models.

### Commit 5
Implemented repository CRUD operations.

### Commit 6
Connected the Dashboard and preset creation to SQLite.

### Commit 7
Added preset editing and improved form validation.

### Commit 8
Added preset deletion with confirmation,
mood filtering, and automated tests.

## Running the Application

Install dependencies:

    flutter pub get

Run the application:

    flutter run

## Testing

Run all tests:

    flutter test

Run widget tests:

    flutter test test/widget_test.dart

Run deletion use case tests:

    flutter test test/features/focus/domain/delete_focus_preset_test.dart

Run repository tests:

    flutter test test/features/focus/data/focus_preset_repository_test.dart

Check for code issues:

    flutter analyze

## Project Management

Development is tracked through GitHub and ClickUp.

GitHub Repository:
https://github.com/isaacowusu3461/Adaptive_Focus_Studio

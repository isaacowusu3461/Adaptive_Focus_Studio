
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

Students can create and edit focus presets, view
saved presets on the Dashboard, and open the timer
with a selected preset.

SQLite stores focus presets and session logs.
SharedPreferences will store application settings.

## Implemented Features

- Welcome screen
- Dashboard, History, and Settings navigation
- SQLite database schema
- Focus preset repository CRUD operations
- Create focus presets
- Edit existing focus presets
- Form validation
- Persistent SQLite storage
- Display saved presets on the Dashboard
- Open the timer with a selected preset

## Planned Features

- Delete presets from the UI
- Filter presets by mood
- Functional countdown timer
- Session history and statistics
- Session Scout recommendations
- Persistent settings
- Local notifications
- JSON export and import

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

Deleting a preset also deletes its related logs.

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

The application updates the existing SQLite
record and refreshes the Dashboard.

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
Added preset editing, reusable create/edit form,
improved validation, and tests.

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

Run update use case tests:

    flutter test test/features/focus/domain/update_focus_preset_test.dart

Check for code issues:

    flutter analyze

## Project Management

Development is tracked through GitHub and ClickUp.

GitHub Repository:
https://github.com/isaacowusu3461/Adaptive_Focus_Studio

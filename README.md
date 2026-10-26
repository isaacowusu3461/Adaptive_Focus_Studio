
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

Students can create focus presets and view them
on the Dashboard. Additional features will include
focus timers, study history, statistics, and
personalized study recommendations.

SQLite stores focus presets and session logs.
SharedPreferences will store application settings.

## Features

### Implemented

- Welcome screen
- Dashboard navigation
- History and Settings screen layouts
- SQLite database schema
- Focus preset repository CRUD operations
- Create focus preset form
- Form validation
- Save presets to SQLite
- Load saved presets on the Dashboard
- Open the timer screen with a selected preset

### Planned

- Edit and delete presets from the UI
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

Focus presets contain a name, mood tag, and
planned duration.

Session logs contain a related preset ID, date,
completed duration, status, and notes.

Deleting a preset also deletes its related logs.

## Current Progress

### Commit 1
Initialized the Flutter project.

### Commit 2
Introduced clean architecture and domain components.

### Commit 3
Created the five main screens and navigation.

### Commit 4
Implemented SQLite database schema and models.

### Commit 5
Implemented repository CRUD operations and
the CreateFocusPreset use case.

### Commit 6
Connected the Dashboard and Create Preset form
to SQLite.

Users can now save presets, view saved presets,
and open the timer with a selected preset.

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

Run static analysis:

    flutter analyze

## Project Management

Development is tracked through GitHub and ClickUp.

GitHub Repository:
https://github.com/isaacowusu3461/Adaptive_Focus_Studio

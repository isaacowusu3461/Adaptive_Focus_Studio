
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

Students will be able to create study presets,
manage focus sessions, review study history,
and receive study-duration recommendations.

SQLite stores focus presets and session logs.
SharedPreferences will store application settings.

## Planned Features

- Create, view, edit, and delete focus presets
- Start, pause, resume, finish, and reset sessions
- Track completed study sessions
- Filter presets by mood
- View study history and statistics
- Receive recommendations from Session Scout
- Customize timer settings and reminders

## Technologies

- Flutter and Dart
- SQLite
- SharedPreferences
- Riverpod
- Material Design 3
- sqflite_common_ffi for database testing

## Architecture

The project follows clean architecture with
three main layers:

- Presentation: Screens, widgets, and state
- Domain: Entities, repository contracts, and use cases
- Data: Database models and storage implementations

See ARCHITECTURE.md for more details.

## Local Database

The SQLite database is named:

adaptive_focus_studio.db

It contains two related tables:

### focus_presets

Stores:
- ID
- Name
- Mood tag
- Planned duration in minutes

### session_logs

Stores:
- ID
- Related preset ID
- Date
- Completed duration in seconds
- Status
- Notes

Deleting a preset also deletes its related
session logs.

## Repository Operations

The FocusPresetRepositoryImpl class provides
SQLite CRUD operations for focus presets.

Supported operations:
- Create a preset
- Retrieve all presets
- Retrieve a preset by ID
- Update a preset
- Delete a preset

The CreateFocusPreset use case validates
and normalizes input before saving.

## Current Progress

### Commit 1
Initialized the Flutter project and welcome screen.

### Commit 2
Introduced clean architecture and domain components.

### Commit 3
Created the five main screens and navigation.

### Commit 4
Implemented SQLite database schema,
data models, and database tests.

### Commit 5
Implemented focus preset repository CRUD
operations and the CreateFocusPreset use case.

The repository is not yet connected to the
application screens.

## Running the Application

Install dependencies:

    flutter pub get

Run the application:

    flutter run

## Testing

Run all tests:

    flutter test

Run repository tests:

    flutter test test/features/focus/data/focus_preset_repository_test.dart

Run use case tests:

    flutter test test/features/focus/domain/create_focus_preset_test.dart

Check for code issues:

    flutter analyze

## Project Management

Development is tracked through GitHub and ClickUp.

GitHub Repository:
https://github.com/isaacowusu3461/Adaptive_Focus_Studio

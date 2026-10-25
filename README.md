
# Adaptive Focus Studio

Adaptive Focus Studio is a Flutter mobile application
designed to help students organize study sessions,
manage focus presets, and track their study progress.

This project is being developed individually for
CSC 6360 - Mobile App Development at
Georgia State University.

## Developer

Isaac Owusu

## Project Overview

The application will allow students to create study
presets, manage focus timers, review completed sessions,
and receive study-duration recommendations.

The application is designed to work offline.

SQLite will store study presets and session records,
while SharedPreferences will store application settings.

## Planned Features

- Create, view, edit, and delete study presets
- Start, pause, resume, finish, and reset focus sessions
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

## Architecture

The project follows clean architecture with three
main layers:

- Presentation: Screens, widgets, and state management
- Domain: Entities, repository contracts, and use cases
- Data: Local database and repository implementations

See ARCHITECTURE.md for additional details.

## Current Progress

### Commit 1

Initialized the Flutter project, installed initial
dependencies, created a welcome screen, and added
widget tests.

### Commit 2

Introduced the clean architecture folder structure,
separated the application theme and configuration,
created the FocusPreset domain entity, defined the
repository interface, and added domain unit tests.

## Running the Application

Install dependencies:

    flutter pub get

Run the application:

    flutter run

## Testing

Run all tests:

    flutter test

Check for code issues:

    flutter analyze

## Project Management

Development is tracked through GitHub and ClickUp.

GitHub Repository:
https://github.com/isaacowusu3461/Adaptive_Focus_Studio

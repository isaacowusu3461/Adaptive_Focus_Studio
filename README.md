
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

The application allows students to organize study
activities, manage focus sessions, review study
history, and receive study-duration recommendations.

The application is designed to work offline.

SQLite will store focus presets and session logs,
while SharedPreferences will store application settings.

## Planned Features

- Create, view, edit, and delete focus presets
- Start, pause, resume, finish, and reset study sessions
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
- Data: Database and repository implementations

See ARCHITECTURE.md for details.

## Current Progress

### Commit 1

Initialized the Flutter project, installed initial
dependencies, created a welcome screen, and added
widget tests.

### Commit 2

Introduced clean architecture, separated application
configuration and theme, created the FocusPreset
domain entity and repository interface, and added
domain unit tests.

### Commit 3

Created the five main application screens and added
navigation between Dashboard, History, and Settings.

The Dashboard includes placeholder study summaries,
a sample preset, and a Session Scout section.

The preset form includes basic validation.

The Focus Timer, History, and Settings screens contain
initial interfaces. Data persistence and timer logic
will be implemented in future commits.

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

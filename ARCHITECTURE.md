
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio uses clean architecture
to separate Flutter UI components, business
logic, and persistent data storage.

The application works offline.

## Presentation Layer

Contains screens and UI state.

Screens:
- Welcome
- Dashboard
- Create/Edit Preset
- Focus Timer
- History & Insights
- Settings

The Dashboard displays saved presets and study
statistics.

The Focus Timer manages countdown state.

History & Insights displays and manages
saved session logs.

Settings uses SharedPreferences for local
preference persistence.

## Domain Layer

Entities:
- FocusPreset
- SessionLog

Repository interfaces:
- FocusPresetRepository
- SessionLogRepository

Use cases:
- CreateFocusPreset
- UpdateFocusPreset
- DeleteFocusPreset
- SaveSessionLog

Domain classes do not depend on Flutter widgets
or SQLite implementations.

## Data Layer

Database helper:
- DatabaseHelper

Models:
- FocusPresetModel
- SessionLogModel

Repository implementations:
- FocusPresetRepositoryImpl
- SessionLogRepositoryImpl

SQLite stores both focus presets and session logs.

## Dependency Direction

Presentation -> Domain <- Data

FocusDependencies currently creates and shares
repository implementations and use cases.

Riverpod will be introduced in a later commit.

## SQLite Database

Name:

adaptive_focus_studio.db

Version:

1

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

Session logs reference focus presets.

Foreign keys are enabled and ON DELETE CASCADE
removes related logs when a preset is deleted.

## Timer Lifecycle

Timer states:
- ready
- running
- paused
- finished

### Start

Starts the Stopwatch and periodic UI updates.

### Pause

Stops elapsed-time measurement and cancels
the periodic timer.

### Resume

Restarts elapsed-time measurement without
clearing the previous elapsed duration.

### Finish

Stops the timer and saves a session.

Sessions finished before the planned duration
receive the status "partial".

### Automatic Completion

When the remaining time reaches zero, the
session is saved with status "completed".

### Reset

Stops and resets the timer without creating
a session record.

## Session Recording

1. The user starts a focus session.
2. Stopwatch measures elapsed time.
3. The user finishes or the countdown ends.
4. SaveSessionLog validates the session.
5. SessionLogRepositoryImpl inserts it into SQLite.
6. History & Insights retrieves the saved session.

## Session Statistics

Completed Sessions:
Count of session logs with status "completed".

Total Study Time:
Sum of completed_seconds across all saved sessions.

Average Duration:
Total completed_seconds divided by the number
of saved sessions.

Partial sessions contribute to total and
average study time.

## History Management

History & Insights supports:
- Read saved sessions
- Add manual sessions
- Edit session details
- Delete sessions
- Refresh session history

The screen calculates statistics from saved
SQLite records.

## Settings Persistence

SharedPreferences keys:
- default_focus_duration
- reminders_enabled
- reduce_motion
- sound_enabled

Preferences are loaded when the Settings screen
initializes and saved when the user taps
Save Settings.

Reminder scheduling, animations, and sound
effects are planned for later commits.

## Testing

Database tests use sqflite_common_ffi with
in-memory SQLite databases.

Unit tests cover:
- Entities
- Repository validation
- Create, update, and delete use cases
- Session saving

Widget tests cover:
- Navigation
- Preset management
- Timer interactions
- History display
- Settings persistence

Additional timer and integration testing
will be implemented in later commits.

## Development Progress

### Commits 1-8

Flutter initialization, architecture, navigation,
SQLite database, and preset management.

### Commit 9

Combined original Commits 9-13:
- Focus timer
- Timer lifecycle
- Session saving
- History & Insights
- Session CRUD and statistics
- Persistent settings

## Planned Improvements

- Session Scout recommendation algorithm
- Session Scout UI and evaluation
- Riverpod state management
- Animations and responsive layouts
- Dart isolate for statistics
- Local notifications
- JSON export and import
- Additional unit and widget tests
- Integration tests
- Coverage and documentation


# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio follows clean architecture
to separate Flutter presentation, business logic,
and local data storage.

The application works offline.

## Presentation Layer

Screens:
- Welcome
- Dashboard
- Create/Edit Preset
- Focus Timer
- History & Insights
- Settings

The Dashboard displays saved focus presets and
study statistics.

The Focus Timer manages countdown state.

History & Insights manages session logs.

Settings stores preferences using SharedPreferences.

Session Scout's interactive Dashboard interface
will be implemented in Commit 11.

## Domain Layer

### Entities

- FocusPreset
- SessionLog
- SessionScoutRecommendation

### Repository Interfaces

- FocusPresetRepository
- SessionLogRepository

### Use Cases

- CreateFocusPreset
- UpdateFocusPreset
- DeleteFocusPreset
- SaveSessionLog
- CalculateSessionScout
- GetSessionScoutRecommendation

CalculateSessionScout performs the median
calculation independently of SQLite.

GetSessionScoutRecommendation retrieves saved
sessions, filters them, and calls the calculation
use case.

## Data Layer

### Database

DatabaseHelper manages the SQLite database.

Database name:

adaptive_focus_studio.db

Database version:

1

### Models

- FocusPresetModel
- SessionLogModel

### Repository Implementations

- FocusPresetRepositoryImpl
- SessionLogRepositoryImpl

## Dependency Direction

Presentation -> Domain <- Data

The domain layer defines repository interfaces.

The data layer implements those interfaces.

FocusDependencies creates repositories and
use cases and supplies them to screens.

Riverpod will be introduced in a later commit.

## SQLite Tables

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

Foreign keys are enabled.

Deleting a preset automatically deletes related
session logs using ON DELETE CASCADE.

## Timer Lifecycle

States:
- ready
- running
- paused
- finished

The timer uses Stopwatch for elapsed-time
measurement and Timer.periodic for display updates.

Completed sessions are saved automatically.

Sessions finished early are marked partial.

## History and Statistics

History supports:
- Read session logs
- Add manual session logs
- Edit session logs
- Delete session logs

Statistics include:
- Completed-session count
- Total study duration
- Average study duration

## Settings

SharedPreferences stores:
- default_focus_duration
- reminders_enabled
- reduce_motion
- sound_enabled

## Session Scout Recommendation Algorithm

### Purpose

Suggest a study duration based on the user's
recent completed sessions for a selected mood.

### Inputs

- Mood tag
- Saved focus presets
- Saved session logs

### Processing

1. Validate the mood tag.
2. Retrieve focus presets and session logs.
3. Identify presets with the requested mood.
4. Filter session logs by matching preset IDs.
5. Exclude partial sessions.
6. Sort matching sessions by date descending.
7. Select the three most recent sessions.
8. Calculate the median completed duration.
9. Round to the nearest whole minute.
10. Clamp the recommendation to 10-60 minutes.
11. Return the recommendation and explanation.

### Fallback

If fewer than three matching completed sessions
exist, return a fixed 25-minute recommendation.

### Median Example

Completed durations:
- 20 minutes
- 30 minutes
- 25 minutes

Sorted durations:
- 20 minutes
- 25 minutes
- 30 minutes

Median:
25 minutes

Suggested duration:
25 minutes

### Clamping Example

Completed durations:
- 70 minutes
- 80 minutes
- 90 minutes

Median:
80 minutes

Suggested duration:
60 minutes

### Output

SessionScoutRecommendation contains:
- moodTag
- suggestedMinutes
- explanation
- sessionsUsed
- usedFallback

### Current Data Limitation

Mood is determined using the preset currently
associated with each session.

Editing a preset's mood therefore changes how
its historical sessions are grouped.

Deleting a preset removes its related sessions.

These behaviors follow the existing SQLite schema.

## Testing

### Calculation Tests

Test:
- Median calculation
- Three-session selection
- Fallback behavior
- Minimum duration
- Maximum duration
- Rounding
- Input validation
- Explanation generation

### Repository Integration Tests

Test:
- SQLite session retrieval
- Mood filtering
- Completed-session filtering
- Date ordering
- Multiple presets with the same mood
- Fallback
- Clamping

Database tests use sqflite_common_ffi with
in-memory SQLite databases.

## Development Progress

### Commits 1-8

Project setup, architecture, navigation,
SQLite, and preset CRUD.

### Commit 9

Focus timer, session history, statistics,
and persistent settings.

### Commit 10

Session Scout recommendation calculation,
repository integration, and tests.

## Planned Improvements

- Session Scout Dashboard interface
- Baseline comparison and evaluation
- Riverpod state management
- Animations and responsive layouts
- Dart isolate for statistics
- Local notifications
- JSON export and import
- Additional tests and coverage
- Integration testing

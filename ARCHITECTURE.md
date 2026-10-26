
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio follows clean architecture
to separate presentation, domain logic,
and persistent data storage.

The application works offline.

## Presentation Layer

Screens:
- Welcome
- Dashboard
- Create/Edit Preset
- Focus Timer
- History & Insights
- Settings

### Dashboard

The Dashboard supports:
- Preset listing
- Preset creation
- Preset editing
- Preset deletion
- Mood filtering
- Study statistics
- Session Scout recommendations

### Session Scout UI

Session Scout is displayed on the Dashboard.

The user selects a mood and taps
Get Recommendation.

The Dashboard calls
GetSessionScoutRecommendation through
FocusDependencies.

The recommendation contains:
- Mood tag
- Suggested duration
- Explanation
- Number of sessions used
- Fallback status

The user can select Apply or Not now.

Apply opens a dialog containing presets
matching the recommended mood.

After the user selects a preset, the
Dashboard calls UpdateFocusPreset to
save the suggested duration in SQLite.

Not now dismisses the recommendation
without changing any saved data.

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

## Data Layer

### Database

DatabaseHelper manages SQLite.

Database name:

adaptive_focus_studio.db

Version:

1

### Models

- FocusPresetModel
- SessionLogModel

### Repository Implementations

- FocusPresetRepositoryImpl
- SessionLogRepositoryImpl

## Dependency Direction

Presentation -> Domain <- Data

FocusDependencies currently creates
repositories and use cases.

Riverpod integration is planned for
a later commit.

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

Deleting a preset automatically deletes
its associated session logs.

## Timer Lifecycle

States:
- ready
- running
- paused
- finished

The timer uses Stopwatch to measure
elapsed time.

Completed sessions are saved automatically.

Sessions finished early are marked partial.

## History and Statistics

History supports:
- Reading session logs
- Adding manual logs
- Editing logs
- Deleting logs

Statistics include:
- Completed-session count
- Total study time
- Average study duration

## Settings

SharedPreferences stores:
- default_focus_duration
- reminders_enabled
- reduce_motion
- sound_enabled

## Session Scout Algorithm

### Inputs

- Selected mood
- Saved focus presets
- Saved session logs

### Processing

1. Validate the selected mood.
2. Retrieve presets and session logs.
3. Identify presets with the selected mood.
4. Select completed sessions for those presets.
5. Sort matching sessions newest first.
6. Use the three most recent completed sessions.
7. Calculate the median completed duration.
8. Round to the nearest whole minute.
9. Clamp the result to 10-60 minutes.

### Fallback

If fewer than three completed sessions match,
return 25 minutes.

### Example

Completed durations:
- 20 minutes
- 30 minutes
- 25 minutes

Sorted:
- 20 minutes
- 25 minutes
- 30 minutes

Median:
25 minutes

Suggested duration:
25 minutes

### Applying a Recommendation

1. User selects a mood.
2. User generates a recommendation.
3. Dashboard displays the suggested duration.
4. User taps Apply.
5. Dashboard retrieves matching presets.
6. User selects a preset.
7. UpdateFocusPreset saves the new duration.
8. Dashboard reloads the updated preset list.

### Dismissing a Recommendation

Not now clears the displayed recommendation.

No database changes occur.

### Data Limitation

Session mood is determined through the
currently linked preset.

Editing a preset's mood can therefore change
how historical sessions are grouped.

## Testing

### Unit Tests

- Median calculation
- Fallback behavior
- Duration clamping
- Input validation
- Explanation generation

### SQLite Integration Tests

- Mood filtering
- Completed-session filtering
- Date ordering
- Multiple presets with the same mood

### Widget Tests

- Recommendation generation
- Fallback display
- Median recommendation display
- Not now dismissal
- Apply action
- Missing matching preset message

## Development Progress

Commits 1-8:
Project setup, architecture, SQLite,
and preset CRUD.

Commit 9:
Timer, session history, statistics,
and settings.

Commit 10:
Session Scout algorithm.

Commit 11:
Session Scout Dashboard integration.

## Planned Improvements

- Session Scout baseline evaluation
- Riverpod state management
- Animations and responsive layouts
- Dart isolate statistics
- Local notifications
- JSON export/import
- Additional testing and coverage
- Integration testing

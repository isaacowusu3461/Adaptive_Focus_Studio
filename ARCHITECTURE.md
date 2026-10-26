
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
- SessionScoutEvaluationCase
- SessionScoutCaseResult
- SessionScoutEvaluationResult

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
- EvaluateSessionScout

EvaluateSessionScout reuses the existing
CalculateSessionScout algorithm.

It does not implement a separate
recommendation formula.

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

## Session Scout Evaluation

### Purpose

Evaluate the predictive accuracy of Session Scout
against a fixed 25-minute baseline.

### Evaluation Inputs

Each evaluation case contains:

- Case name
- Mood tag
- Historical completed durations in seconds
- Actual subsequent duration in minutes

The target duration is separate from the
historical input durations.

### Evaluation Process

1. Read an evaluation case.
2. Generate a recommendation using
   CalculateSessionScout.
3. Generate the fixed 25-minute baseline.
4. Compare both predictions against the target.
5. Calculate absolute prediction errors.
6. Repeat for all cases.
7. Calculate mean absolute error for each method.
8. Compare the resulting MAE values.

### Metrics

Absolute Error:

|Prediction - Actual|

Mean Absolute Error:

Sum of Absolute Errors / Number of Cases

Relative MAE Reduction:

(Baseline MAE - Scout MAE) / Baseline MAE * 100

If baseline MAE is zero, the implementation
returns zero for the percentage metric
to avoid division by zero.

### Sample Evaluation

Six synthetic cases are used.

Scout absolute errors:

3, 3, 2, 3, 3, 0

Baseline absolute errors:

3, 13, 22, 7, 33, 0

Scout MAE:

14 / 6 = 2.33 minutes

Baseline MAE:

78 / 6 = 13.00 minutes

Relative MAE reduction:

Approximately 82.05%

### Interpretation

Session Scout performs better on the
constructed synthetic examples.

The sample data is not representative
evidence of real-world predictive performance.

Further evaluation should use actual
chronologically held-out study sessions.

### Implementation

Entities:
- SessionScoutEvaluationCase
- SessionScoutCaseResult
- SessionScoutEvaluationResult

Use case:
- EvaluateSessionScout

Tests:
- evaluate_session_scout_test.dart

Documentation:
- AI_FEATURE.md

## Testing

### Recommendation Unit Tests

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

### Evaluation Tests

- Six synthetic evaluation cases
- Scout predictions
- Fixed baseline predictions
- Absolute errors
- Mean absolute errors
- Relative improvement
- Better-method comparison
- Fallback usage
- Invalid inputs

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

Commit 12:
Session Scout baseline evaluation,
automated tests, and AI_FEATURE.md.

## Planned Improvements

- Riverpod state management
- Animations and responsive layouts
- Dart isolate statistics
- Local notifications
- JSON export/import
- Additional testing and coverage
- Integration testing

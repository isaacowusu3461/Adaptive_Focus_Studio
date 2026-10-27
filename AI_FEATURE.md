
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio uses clean architecture
to separate the user interface, business logic,
and persistent data storage.

The application works offline.

## Architecture Layers

### Presentation

The presentation layer contains:
- Welcome screen
- Dashboard
- Create/Edit Preset
- Focus Timer
- History & Insights
- Settings
- Riverpod providers

### Domain

The domain layer contains:
- FocusPreset
- SessionLog
- SessionScoutRecommendation
- SessionScoutEvaluationCase
- SessionScoutEvaluationResult
- Repository interfaces
- Use cases

### Data

The data layer contains:
- DatabaseHelper
- FocusPresetModel
- SessionLogModel
- FocusPresetRepositoryImpl
- SessionLogRepositoryImpl

## Dependency Direction

Presentation -> Domain <- Data

The domain layer does not depend on Flutter
widgets or SQLite implementations.

The data layer implements repository interfaces
defined in the domain layer.

## Riverpod Dependency Injection

FocusDependencies constructs the existing
repositories and use cases.

The application creates a ProviderScope
and overrides focusDependenciesProvider
with its dependency instance.

Repository providers expose:
- FocusPresetRepository
- SessionLogRepository

Use case providers expose:
- CreateFocusPreset
- UpdateFocusPreset
- DeleteFocusPreset
- SaveSessionLog
- GetSessionScoutRecommendation

## Asynchronous Data Providers

### focusPresetsProvider

Loads saved focus presets through
FocusPresetRepository.

### sessionHistoryProvider

Loads session logs through
SessionLogRepository.

### sessionScoutProvider

A FutureProvider.family that accepts a mood tag.

It calls GetSessionScoutRecommendation and
returns a SessionScoutRecommendation.

It watches the preset and session history
providers so changes to their data can
invalidate recommendations.

## UI Integration

### Dashboard

DashboardScreen extends ConsumerStatefulWidget.

It watches:
- focusPresetsProvider
- sessionHistoryProvider
- sessionScoutProvider

Preset creation, editing, deletion, and
recommendation application invalidate
the appropriate providers.

### History

HistoryScreen extends ConsumerStatefulWidget.

It watches sessionHistoryProvider.

Adding, editing, or deleting session logs
invalidates sessionHistoryProvider.

### Navigation

MainScreen extends ConsumerStatefulWidget.

It invalidates providers when switching
between Dashboard and History.

The existing navigation structure is retained.

## SQLite Storage

Tables:
- focus_presets
- session_logs

focus_presets:
- id
- name
- mood_tag
- duration_minutes

session_logs:
- id
- preset_id
- date
- completed_seconds
- status
- notes

Foreign keys are enabled.

Deleting a preset cascades to its
related session logs.

## Focus Timer

The timer supports:
- Ready
- Running
- Paused
- Finished

It uses Stopwatch for elapsed time
and Timer.periodic for display updates.

Completed and partial sessions are saved
through SaveSessionLog.

## Settings

SharedPreferences stores:
- default_focus_duration
- reminders_enabled
- reduce_motion
- sound_enabled

## Session Scout

Session Scout is a deterministic,
median-based recommendation algorithm.

It uses:
- Selected mood
- Completed sessions
- Three most recent matching durations

It calculates the median, rounds to the
nearest minute, and clamps the result
between 10 and 60 minutes.

If there are fewer than three matching
completed sessions, it returns 25 minutes.

The user can apply a recommendation
to an existing focus preset.

## Evaluation

EvaluateSessionScout compares the
recommendation against a fixed
25-minute baseline.

Metrics:
- Absolute error
- Mean absolute error
- Relative MAE reduction

Six synthetic evaluation cases are
documented in AI_FEATURE.md.

The synthetic results demonstrate
the calculation but do not prove
real-world predictive superiority.

## Testing

### Unit Tests

- Focus preset use cases
- Session logging
- Session Scout median calculation
- Session Scout evaluation

### Database Tests

- SQLite CRUD
- Foreign-key cascade behavior
- Session history
- Mood-based recommendation filtering

### Widget Tests

- Preset management
- Timer interactions
- History
- Settings
- Session Scout interface

### Riverpod Tests

- Dependency provider overrides
- Repository providers
- Use case providers
- Preset loading
- Session loading
- Provider invalidation
- Session Scout recommendations

## Development Progress

Commits 1-8:
Project foundation and preset management.

Commit 9:
Timer, history, statistics, settings.

Commit 10:
Session Scout algorithm.

Commit 11:
Session Scout Dashboard integration.

Commit 12:
Session Scout evaluation.

Commit 13:
Riverpod state management and dependency injection.

## Planned Work

- Animations and responsive layouts
- Background statistics processing using isolates
- Local notifications
- JSON import/export
- Additional automated tests
- Integration tests
- Coverage and final documentation

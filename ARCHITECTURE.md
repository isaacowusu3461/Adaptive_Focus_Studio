
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio follows clean architecture
to separate presentation, domain logic,
and local data storage.

The application works offline.

## Architecture Layers

### Presentation

- Welcome
- Dashboard
- Create/Edit Preset
- Focus Timer
- History & Insights
- Settings
- Riverpod providers
- Reusable animation and layout widgets

### Domain

- FocusPreset
- SessionLog
- SessionScoutRecommendation
- SessionScoutEvaluationCase
- SessionScoutEvaluationResult
- Repository interfaces
- Use cases

### Data

- DatabaseHelper
- FocusPresetModel
- SessionLogModel
- FocusPresetRepositoryImpl
- SessionLogRepositoryImpl

## Dependency Direction

Presentation -> Domain <- Data

The domain layer does not depend on Flutter
widgets or SQLite implementations.

## Riverpod

FocusDependencies constructs repositories
and use cases.

ProviderScope makes dependencies available
throughout the application.

Providers manage:
- Focus preset repository
- Session log repository
- Preset use cases
- Session logging
- Focus preset lists
- Session history
- Session Scout recommendations
- Reduced-motion preference

Database updates invalidate affected providers.

## SQLite

Tables:
- focus_presets
- session_logs

The database uses foreign-key cascade deletion
for session logs linked to deleted presets.

## Focus Timer

The timer supports:
- Ready
- Running
- Paused
- Finished

Stopwatch measures elapsed time.

Timer.periodic updates the displayed countdown.

Completed and partial sessions are saved
through SaveSessionLog.

## Session Scout

Session Scout is a deterministic recommendation
algorithm using the median of the three most
recent completed sessions matching a mood.

Recommendations are limited to 10-60 minutes.

The fallback duration is 25 minutes.

The Dashboard allows users to generate,
apply, or dismiss recommendations.

## Session Scout Evaluation

EvaluateSessionScout compares predictions
against a fixed 25-minute baseline.

Metrics:
- Absolute error
- Mean absolute error
- Relative MAE reduction

Six synthetic cases are documented
in AI_FEATURE.md.

## Animations

### Implicit Animation

The Dashboard uses AnimatedSize for
the Session Scout recommendation panel.

The transition duration is controlled
by AppMotion.

### Explicit Animation

AnimatedFocusIndicator uses:
- AnimationController
- Tween<double>
- CurvedAnimation
- ScaleTransition

The controller is stopped when inactive
or when reduced motion is enabled.

The controller is disposed in dispose().

### Reduced Motion

The reduce_motion setting is stored
using SharedPreferences.

ReduceMotionNotifier exposes the preference
through Riverpod.

When enabled:
- Decorative pulsing stops
- Custom panel transition duration becomes zero

This setting currently applies to the custom
animations introduced in Commit 14.

## Responsive Layout

### ResponsiveContent

Centers content and limits maximum width
on larger screens.

### Dashboard Cards

Preset cards use LayoutBuilder and Wrap.

One column is used on narrow layouts.

Two columns are used when the available
content width is at least 650 pixels.

### Main Navigation

Narrow screens use NavigationBar.

Screens at least 700 pixels wide
use NavigationRail.

## Settings

SharedPreferences stores:
- default_focus_duration
- reminders_enabled
- reduce_motion
- sound_enabled

Reduced motion is connected to Riverpod.

Reminder and sound behavior will be
implemented in later work.

## Testing

### Domain Tests

- Focus preset use cases
- Session logging
- Session Scout calculation
- Session Scout evaluation

### Database Tests

- SQLite CRUD
- Foreign-key cascade behavior
- Session history

### Widget Tests

- Preset management
- Focus Timer
- History
- Settings
- Session Scout

### Riverpod Tests

- Provider overrides
- Data loading
- Provider invalidation
- Recommendation loading

### Animation Tests

- Active and inactive indicator
- Animation progression
- Reduced-motion behavior
- Animation controller disposal

### Responsive Tests

- Narrow layout
- Maximum content width
- Custom padding

## Development Progress

Commits 1-8:
Project setup and preset management.

Commit 9:
Timer, history, statistics, and settings.

Commit 10:
Session Scout algorithm.

Commit 11:
Session Scout Dashboard integration.

Commit 12:
Session Scout evaluation.

Commit 13:
Riverpod state management.

Commit 14:
Custom animations, responsive layouts,
and reduced-motion support.

## Planned Work

- Isolate-based statistics processing
- Local notifications
- JSON import and export
- Additional automated tests
- Integration testing
- Coverage and final documentation

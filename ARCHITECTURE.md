
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio follows clean architecture
to separate the user interface, business logic,
and local data storage.

The application is designed to work offline.

## Architecture Layers

### Presentation Layer

Contains screens, widgets, and UI state.

Current screens:
- Welcome
- Dashboard
- Create Preset
- Focus Timer
- History & Insights
- Settings

The Dashboard retrieves saved presets through
the FocusPresetRepository interface.

The Create Preset screen saves data using the
CreateFocusPreset use case.

### Domain Layer

Contains entities, repository interfaces,
and business use cases.

Entities:
- FocusPreset
- SessionLog

Repository interface:
- FocusPresetRepository

Use case:
- CreateFocusPreset

The domain layer does not depend on SQLite
or Flutter UI components.

### Data Layer

Contains database models, data sources,
and repository implementations.

Components:
- FocusPresetModel
- SessionLogModel
- DatabaseHelper
- FocusPresetRepositoryImpl

The repository converts SQLite records into
domain objects.

## Dependency Direction

Presentation -> Domain <- Data

The domain layer defines the repository contract.

The data layer implements that contract using SQLite.

## Dependency Injection

FocusDependencies creates and shares:
- DatabaseHelper
- FocusPresetRepositoryImpl
- CreateFocusPreset

Dependencies are passed to screens through
constructors.

This avoids creating separate database helpers
inside each screen and makes widget tests easier.

Riverpod will replace this initial dependency
container in a later commit.

## SQLite Database

Database name:

adaptive_focus_studio.db

Database version:

1

### focus_presets

Columns:
- id
- name
- mood_tag
- duration_minutes

### session_logs

Columns:
- id
- preset_id
- date
- completed_seconds
- status
- notes

The session_logs table references focus_presets.

Foreign keys are enabled, and deleting a preset
automatically deletes related session logs.

## Dashboard Data Flow

1. The Dashboard opens.
2. It calls FocusPresetRepository.getAllPresets().
3. The repository queries SQLite.
4. Database rows are converted into FocusPreset
   domain objects.
5. FutureBuilder displays the saved presets.

## Create Preset Data Flow

1. The user opens the Create Preset screen.
2. The user enters a name, mood, and duration.
3. The form validates the input.
4. CreateFocusPreset validates and normalizes it.
5. The repository inserts the preset into SQLite.
6. The form returns a successful result.
7. The Dashboard reloads the saved presets.

## Testing

Unit tests verify domain and repository logic.

Database tests use sqflite_common_ffi and
an in-memory SQLite database.

Widget tests verify navigation, form validation,
preset creation, and Dashboard updates.

## Current Implementation

### Commit 1
Flutter project initialization.

### Commit 2
Clean architecture and domain components.

### Commit 3
Main screens and navigation.

### Commit 4
SQLite database schema and models.

### Commit 5
Focus preset repository CRUD operations.

### Commit 6
Dashboard integration with SQLite and
persistent preset creation.

## Future Improvements

- Preset editing and deletion from the UI
- Mood filtering
- Timer lifecycle and session recording
- Session history and statistics
- Riverpod state management
- Session Scout recommendations
- Background statistics processing
- Local notifications
- JSON file operations
- Integration testing

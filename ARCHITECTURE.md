
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
- Create/Edit Preset
- Focus Timer
- History & Insights
- Settings

The Dashboard retrieves presets through
FocusPresetRepository.

The PresetFormScreen supports both creating
and editing presets.

### Domain Layer

Contains entities, repository interfaces,
and business use cases.

Entities:
- FocusPreset
- SessionLog

Repository:
- FocusPresetRepository

Use cases:
- CreateFocusPreset
- UpdateFocusPreset

CreateFocusPreset handles new preset creation.

UpdateFocusPreset validates changes and
updates existing presets through the repository.

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
domain objects and provides CRUD operations.

## Dependency Direction

Presentation -> Domain <- Data

The domain layer defines repository contracts.

The data layer implements those contracts
using SQLite.

## Dependency Injection

FocusDependencies creates and shares:
- DatabaseHelper
- FocusPresetRepositoryImpl
- CreateFocusPreset
- UpdateFocusPreset

Dependencies are passed to screens through
constructors.

Riverpod will be introduced later for
application-wide state management.

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

## Create Preset Data Flow

1. The user opens the Create Preset form.
2. The user enters a name, mood, and duration.
3. The form validates the input.
4. CreateFocusPreset prepares the entity.
5. The repository inserts it into SQLite.
6. The form returns a successful result.
7. The Dashboard reloads the saved presets.

## Edit Preset Data Flow

1. The user taps Edit on a saved preset.
2. The form receives the existing FocusPreset.
3. The fields are populated with saved values.
4. The user modifies the values.
5. The form validates the changes.
6. UpdateFocusPreset validates and normalizes
   the input.
7. The repository updates the SQLite record
   using its ID.
8. The Dashboard refreshes after a successful
   update.

## Form Validation

Preset names must contain non-whitespace text
and cannot exceed 50 characters.

Durations must be between 1 and 180 minutes.

The update use case also validates the preset ID.

These rules are enforced in the edit use case
and presentation form.

## Testing

Domain tests verify entity behavior,
input validation, and use case logic.

Database tests verify CRUD operations,
foreign-key relationships, and cascade deletion.

Widget tests verify navigation, form validation,
preset creation, preset editing, cancellation,
and Dashboard updates.

SQLite tests use sqflite_common_ffi with
an in-memory database.

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
Dashboard integration with SQLite.

### Commit 7
Preset editing, reusable form, improved
validation, and tests.

## Future Improvements

- Preset deletion and mood filtering
- Timer lifecycle and session recording
- Session history and statistics
- Riverpod state management
- Session Scout recommendations
- Background statistics processing
- Local notifications
- JSON file operations
- Integration testing

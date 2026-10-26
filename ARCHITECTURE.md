
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

The Dashboard retrieves saved presets through
FocusPresetRepository.

The Dashboard supports:
- Creating presets
- Editing presets
- Deleting presets
- Filtering presets by mood
- Opening the timer for a selected preset

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
- DeleteFocusPreset

CreateFocusPreset handles new preset creation.

UpdateFocusPreset validates changes and
updates existing presets.

DeleteFocusPreset validates the preset ID
before requesting deletion.

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
- DeleteFocusPreset

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

Foreign keys are enabled when the database opens.

Deleting a preset automatically deletes its
related session logs through ON DELETE CASCADE.

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
6. UpdateFocusPreset validates the input.
7. The repository updates the SQLite record.
8. The Dashboard refreshes after the update.

## Delete Preset Data Flow

1. The user taps Delete on a saved preset.
2. The Dashboard displays a confirmation dialog.
3. Cancel closes the dialog without changing data.
4. Confirm calls DeleteFocusPreset.
5. DeleteFocusPreset validates the preset ID.
6. The repository deletes the matching SQLite row.
7. SQLite automatically deletes related session logs.
8. The Dashboard refreshes the preset list.
9. A SnackBar displays the result.

## Mood Filtering

The Dashboard stores the selected mood in local
widget state.

Available values:
- All
- Focused
- Relaxed
- Motivated

When All is selected, every saved preset is shown.

Otherwise, the Dashboard displays presets whose
moodTag matches the selected mood.

Filtering is performed in memory after the
repository loads the presets.

The filter does not modify the database.

## Form Validation

Preset names must contain non-whitespace text
and cannot exceed 50 characters.

Durations must be between 1 and 180 minutes.

The update use case validates the preset ID.

The delete use case rejects IDs less than 1.

## Testing

Domain tests verify:
- Entity behavior
- Input validation
- Create, update, and delete use cases

Database tests verify:
- Table creation
- Model conversion
- CRUD operations
- Foreign-key relationships
- Cascade deletion

Widget tests verify:
- Navigation
- Preset creation
- Preset editing
- Canceling edits
- Deletion confirmation
- Canceling deletion
- Successful deletion
- Mood filtering
- Empty states

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
Preset editing and improved validation.

### Commit 8
Preset deletion, confirmation dialog,
mood filtering, and automated tests.

## Future Improvements

- Functional countdown timer
- Session recording
- Session history and statistics
- Riverpod state management
- Session Scout recommendations
- Background statistics processing
- Local notifications
- JSON file operations
- Integration testing

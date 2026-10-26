
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio follows clean architecture to
separate the user interface, business logic, and
data storage.

I chose this approach to make the application easier
to maintain, test, and extend.

## Architecture Layers

### Presentation Layer

The presentation layer contains the application's
screens, widgets, and state management.

Responsibilities:
- Display information
- Handle user interactions
- Navigate between screens
- Show validation messages
- Communicate with the domain layer

The five main screens were introduced in Commit 3.

### Domain Layer

The domain layer contains business entities,
repository interfaces, and use cases.

Current entities:
- FocusPreset
- SessionLog

The FocusPresetRepository interface defines:
- getAllPresets
- getPresetById
- createPreset
- updatePreset
- deletePreset

The CreateFocusPreset use case validates and
normalizes user input before saving a preset.

The domain layer does not depend on SQLite
or Flutter UI components.

### Data Layer

The data layer contains database models,
data sources, and repository implementations.

Current components:
- FocusPresetModel
- SessionLogModel
- DatabaseHelper
- FocusPresetRepositoryImpl

FocusPresetRepositoryImpl implements the
FocusPresetRepository interface using SQLite.

It converts database rows into domain objects
and provides CRUD operations.

## Dependency Direction

Presentation -> Domain <- Data

The presentation layer depends on domain logic.

The data layer implements repository interfaces
defined in the domain layer.

The domain layer remains independent of the
presentation and data layers.

## Dependency Injection

The repository receives DatabaseHelper through
its constructor.

The CreateFocusPreset use case receives a
FocusPresetRepository through its constructor.

This makes the components easier to replace
and test independently.

Riverpod will be introduced later for
application-wide dependency injection
and state management.

## SQLite Database

Database name:

adaptive_focus_studio.db

Database version:

1

### focus_presets

Columns:
- id: INTEGER PRIMARY KEY
- name: TEXT NOT NULL
- mood_tag: TEXT NOT NULL
- duration_minutes: INTEGER NOT NULL

The planned duration must be greater than zero.

### session_logs

Columns:
- id: INTEGER PRIMARY KEY
- preset_id: INTEGER NOT NULL
- date: TEXT NOT NULL
- completed_seconds: INTEGER NOT NULL
- status: TEXT NOT NULL
- notes: TEXT NOT NULL

The completed duration cannot be negative.

Each session log references a focus preset.

Deleting a preset automatically deletes its
related session logs through ON DELETE CASCADE.

Foreign-key enforcement is enabled when the
database connection opens.

## Repository Operations

The FocusPresetRepositoryImpl class provides:

### Create
Validates the preset and inserts it into SQLite.
Returns the generated record ID.

### Read
Retrieves one preset by ID or all presets
in newest-first order.

### Update
Updates the name, mood, and duration of an
existing preset.

### Delete
Deletes a preset by ID.

Related session logs are deleted automatically
through the database foreign-key relationship.

## Testing

### Unit Tests

Domain tests verify:
- FocusPreset entity behavior
- CreateFocusPreset validation
- Input normalization
- Repository communication

### Database Tests

SQLite tests verify:
- Table creation
- Model conversion
- CRUD operations
- Foreign-key relationships
- Cascade deletion
- Invalid input handling

Database tests use sqflite_common_ffi with
an in-memory SQLite database.

## Current Implementation

### Commit 1
Flutter project initialization and welcome screen.

### Commit 2
Clean architecture structure, shared theme,
domain entity, repository interface, and tests.

### Commit 3
Five main screens and navigation.

### Commit 4
SQLite database schema, data models, and tests.

### Commit 5
FocusPresetRepository implementation,
CRUD operations, CreateFocusPreset use case,
and repository tests.

## Future Improvements

- Connect repository operations to the UI
- Add Riverpod state management
- Implement focus timer logic
- Implement session log repository
- Add Session Scout recommendations
- Add background statistics processing
- Implement local notifications
- Add JSON file operations
- Complete integration testing


# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio follows clean architecture to
separate the user interface, business logic, and
data storage.

I chose this approach to keep the application
organized and make individual components easier
to test and maintain.

## Architecture Layers

### Presentation Layer

The presentation layer contains screens, widgets,
and application state.

Responsibilities:
- Display information
- Handle user interactions
- Navigate between screens
- Show validation messages
- Communicate with the domain layer

The five main screens were introduced in Commit 3.

### Domain Layer

The domain layer contains business entities,
repository interfaces, and application rules.

Current entities:
- FocusPreset
- SessionLog

The FocusPreset entity stores the preset ID, name,
mood tag, and planned duration.

The SessionLog entity stores the session ID,
related preset ID, date, completed duration,
status, and notes.

Repository interfaces define the operations
available to the application without depending
on SQLite.

### Data Layer

The data layer handles local storage and data
conversion.

Current components:
- FocusPresetModel
- SessionLogModel
- DatabaseHelper

The models convert domain objects into database
maps and convert database rows back into objects.

DatabaseHelper initializes the SQLite database
and creates the required tables.

## Dependency Direction

Presentation -> Domain <- Data

The domain layer remains independent of Flutter
UI components and SQLite implementations.

The data layer depends on domain entities and
repository interfaces.

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

The duration must be greater than zero.

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

The database uses ON DELETE CASCADE so deleting
a preset automatically deletes its related logs.

Foreign-key enforcement is enabled when the
database connection opens.

## State Management

Riverpod will be used for application state
management and dependency injection.

## Database Testing

The database tests use sqflite_common_ffi
with an in-memory SQLite database.

Tests verify:
- Database table creation
- Preset insertion and retrieval
- Session log insertion
- Foreign-key relationships
- Cascade deletion
- Invalid duration handling

## Current Implementation

### Commit 1
Flutter project initialization and welcome screen.

### Commit 2
Clean architecture structure, theme, domain entity,
repository interface, and unit tests.

### Commit 3
Five main screens and application navigation.

### Commit 4
SQLite database schema, data models, and
database tests.

## Future Improvements

- Repository implementations
- Database CRUD operations through repositories
- Riverpod state management
- Focus timer logic
- Session Scout recommendations
- Background statistics processing
- Local notifications
- JSON file operations
- Integration testing

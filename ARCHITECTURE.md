
# Adaptive Focus Studio - Architecture

## Overview

Adaptive Focus Studio uses clean architecture to separate
the user interface, business logic, and data storage.

I chose this structure to make the application easier to
maintain, test, and extend as new features are added.

## Architecture Layers

### Presentation Layer

The presentation layer contains the screens, widgets,
and state management used by the application.

Responsibilities:
- Display application information
- Handle user interactions
- Show validation messages
- Communicate with the domain layer

Riverpod will be used for state management in later commits.

### Domain Layer

The domain layer contains the application's core
business objects and rules.

Responsibilities:
- Define domain entities
- Define repository interfaces
- Implement business use cases
- Keep business logic independent of Flutter UI and SQLite

The FocusPreset entity and FocusPresetRepository interface
are introduced in Commit 2.

### Data Layer

The data layer will handle local storage.

Responsibilities:
- Read and write SQLite records
- Convert database rows into application models
- Implement repository interfaces
- Manage local data sources

SQLite operations will be implemented in later commits.

## Dependency Direction

Presentation -> Domain <- Data

The domain layer does not depend on the presentation
or data layers.

Repository interfaces are defined in the domain layer,
while their implementations belong to the data layer.

## State Management

Riverpod will be used to manage application state and
provide dependencies to the presentation layer.

## Current Implementation

Commit 1:
- Flutter project initialization
- Welcome screen
- Initial widget tests

Commit 2:
- Clean architecture folder structure
- Separate application configuration
- Shared application theme
- FocusPreset domain entity
- FocusPresetRepository interface
- Domain unit tests

## Future Improvements

The following features will be added incrementally:

- SQLite database and repository implementations
- Navigation between five application screens
- Focus timer and session management
- Riverpod state management
- Session Scout recommendations
- Background statistics processing
- Local notifications
- JSON file operations
- Automated integration testing

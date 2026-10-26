
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/app.dart';
import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper databaseHelper;
  late FocusDependencies dependencies;

  setUp(() {
    databaseHelper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    dependencies = FocusDependencies(
      databaseHelper: databaseHelper,
    );
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  Future<void> openDashboard(WidgetTester tester) async {
    await tester.pumpWidget(
      AdaptiveFocusStudioApp(
        dependencies: dependencies,
      ),
    );

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
  }

  Future<int> addTestPreset({
    String name = 'Algorithms Practice',
    String mood = 'Focused',
    int duration = 25,
  }) {
    return dependencies.presetRepository.createPreset(
      FocusPreset(
        name: name,
        moodTag: mood,
        durationMinutes: duration,
      ),
    );
  }

  Future<void> selectMood(
    WidgetTester tester,
    String mood,
  ) async {
    await tester.tap(
      find.byKey(const ValueKey('mood_filter')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(mood).last);
    await tester.pumpAndSettle();
  }

  testWidgets('Welcome screen displays expected content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AdaptiveFocusStudioApp(
        dependencies: dependencies,
      ),
    );

    expect(
      find.text('Welcome to Adaptive Focus Studio'),
      findsOneWidget,
    );

    expect(find.text('Get Started'), findsOneWidget);
    expect(
      find.byIcon(Icons.timer_outlined),
      findsOneWidget,
    );
  });

  testWidgets('Get Started opens the Dashboard', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    expect(find.text('My Focus Presets'), findsOneWidget);
    expect(find.text('Study Summary'), findsOneWidget);
  });

  testWidgets('Dashboard shows empty state', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    expect(
      find.text('No focus presets yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Bottom navigation opens History and Settings', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(
      find.text('History & Insights'),
      findsOneWidget,
    );

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Default Focus Duration'),
      findsOneWidget,
    );
  });

  testWidgets('New button opens the create form', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Preset Name'), findsOneWidget);
  });

  testWidgets('Create form rejects an empty name', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a preset name'),
      findsOneWidget,
    );
  });

  testWidgets('Create form rejects duration above 180', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Algorithms Practice',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '200',
    );

    await tester.ensureVisible(find.text('Save Preset'));
    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a duration between 1 and 180'),
      findsOneWidget,
    );
  });

  testWidgets('Creating a preset updates the Dashboard', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Algorithms Practice',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Algorithms Practice'),
      findsOneWidget,
    );

    expect(find.text('Mood: Focused'), findsOneWidget);
    expect(
      find.text('Duration: 25 minutes'),
      findsOneWidget,
    );

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets.length, 1);
  });

  testWidgets('Edit opens the form with existing values', (
    WidgetTester tester,
  ) async {
    await addTestPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Preset'), findsOneWidget);

    final nameField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );

    final durationField = tester.widget<TextFormField>(
      find.byType(TextFormField).last,
    );

    expect(
      nameField.controller!.text,
      'Algorithms Practice',
    );

    expect(durationField.controller!.text, '25');
  });

  testWidgets('Editing a preset updates SQLite and Dashboard', (
    WidgetTester tester,
  ) async {
    final id = await addTestPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Advanced Algorithms',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '45',
    );

    await tester.ensureVisible(find.text('Update Preset'));
    await tester.tap(find.text('Update Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Advanced Algorithms'),
      findsOneWidget,
    );

    expect(
      find.text('Duration: 45 minutes'),
      findsOneWidget,
    );

    final updatedPreset =
        await dependencies.presetRepository.getPresetById(id);

    expect(updatedPreset!.name, 'Advanced Algorithms');
    expect(updatedPreset.durationMinutes, 45);
  });

  testWidgets('Cancel editing keeps the original values', (
    WidgetTester tester,
  ) async {
    final id = await addTestPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Changed Name',
    );

    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final preset =
        await dependencies.presetRepository.getPresetById(id);

    expect(preset!.name, 'Algorithms Practice');
    expect(
      find.text('Algorithms Practice'),
      findsOneWidget,
    );
  });

  testWidgets('Start opens the selected preset timer', (
    WidgetTester tester,
  ) async {
    await addTestPreset(
      name: 'Mobile Development',
      mood: 'Motivated',
      duration: 40,
    );

    await openDashboard(tester);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(
      find.text('Mobile Development'),
      findsOneWidget,
    );

    expect(find.text('40:00'), findsOneWidget);
    expect(
      find.text('Planned: 40 minutes'),
      findsOneWidget,
    );
  });

  testWidgets('Delete button opens a confirmation dialog', (
    WidgetTester tester,
  ) async {
    await addTestPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Preset?'), findsOneWidget);
    expect(
      find.textContaining('Algorithms Practice'),
      findsWidgets,
    );
    expect(
      find.textContaining('cannot be undone'),
      findsOneWidget,
    );
  });

  testWidgets('Cancel deletion keeps the preset', (
    WidgetTester tester,
  ) async {
    final id = await addTestPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final preset =
        await dependencies.presetRepository.getPresetById(id);

    expect(preset, isNotNull);
    expect(preset!.name, 'Algorithms Practice');

    expect(
      find.text('Algorithms Practice'),
      findsOneWidget,
    );
  });

  testWidgets('Confirm deletion removes the preset', (
    WidgetTester tester,
  ) async {
    final id = await addTestPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextButton, 'Delete'),
    );
    await tester.pumpAndSettle();

    final preset =
        await dependencies.presetRepository.getPresetById(id);

    expect(preset, isNull);
    expect(
      find.text('No focus presets yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Deleting one preset keeps other presets', (
    WidgetTester tester,
  ) async {
    final firstId = await addTestPreset(
      name: 'Algorithms',
    );

    final secondId = await addTestPreset(
      name: 'Flutter Practice',
      mood: 'Motivated',
    );

    await openDashboard(tester);

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextButton, 'Delete'),
    );
    await tester.pumpAndSettle();

    // Presets are displayed newest first.
    final deletedPreset =
        await dependencies.presetRepository.getPresetById(
      secondId,
    );

    final remainingPreset =
        await dependencies.presetRepository.getPresetById(
      firstId,
    );

    expect(deletedPreset, isNull);
    expect(remainingPreset, isNotNull);
    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Flutter Practice'), findsNothing);
  });

  testWidgets('Mood filter displays only matching presets', (
    WidgetTester tester,
  ) async {
    await addTestPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addTestPreset(
      name: 'Flutter Practice',
      mood: 'Motivated',
    );

    await openDashboard(tester);

    await selectMood(tester, 'Focused');

    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Flutter Practice'), findsNothing);
  });

  testWidgets('Mood filter shows empty matching state', (
    WidgetTester tester,
  ) async {
    await addTestPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await openDashboard(tester);

    await selectMood(tester, 'Relaxed');

    expect(
      find.text('No Relaxed presets found.'),
      findsOneWidget,
    );

    expect(find.text('Algorithms'), findsNothing);
  });

  testWidgets('Selecting All displays every preset', (
    WidgetTester tester,
  ) async {
    await addTestPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addTestPreset(
      name: 'Flutter Practice',
      mood: 'Motivated',
    );

    await openDashboard(tester);

    await selectMood(tester, 'Focused');

    expect(find.text('Flutter Practice'), findsNothing);

    await selectMood(tester, 'All');

    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Flutter Practice'), findsOneWidget);
  });

  testWidgets('Mood filter does not delete database records', (
    WidgetTester tester,
  ) async {
    await addTestPreset(
      name: 'Algorithms',
      mood: 'Focused',
    );

    await addTestPreset(
      name: 'Flutter Practice',
      mood: 'Motivated',
    );

    await openDashboard(tester);

    await selectMood(tester, 'Relaxed');

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets.length, 2);
    expect(
      find.text('No Relaxed presets found.'),
      findsOneWidget,
    );
  });
}

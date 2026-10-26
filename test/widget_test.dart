
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/app.dart';
import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper helper;
  late FocusDependencies dependencies;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    dependencies = FocusDependencies(
      databaseHelper: helper,
    );
  });

  tearDown(() async {
    await helper.close();
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

  Future<int> addPreset({
    String name = 'Algorithms',
    String mood = 'Focused',
    int minutes = 25,
  }) {
    return dependencies.presetRepository.createPreset(
      FocusPreset(
        name: name,
        moodTag: mood,
        durationMinutes: minutes,
      ),
    );
  }

  testWidgets('Welcome screen opens Dashboard', (tester) async {
    await openDashboard(tester);

    expect(find.text('My Focus Presets'), findsOneWidget);
  });

  testWidgets('Dashboard shows empty preset state', (tester) async {
    await openDashboard(tester);

    expect(find.text('No focus presets yet.'), findsOneWidget);
  });

  testWidgets('Creating a preset updates Dashboard', (tester) async {
    await openDashboard(tester);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Flutter Practice',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Practice'), findsOneWidget);
    expect(
      (await dependencies.presetRepository.getAllPresets()).length,
      1,
    );
  });

  testWidgets('Editing a preset updates its name', (tester) async {
    final id = await addPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'Advanced Algorithms',
    );

    await tester.tap(find.text('Update Preset'));
    await tester.pumpAndSettle();

    final preset =
        await dependencies.presetRepository.getPresetById(id);

    expect(preset!.name, 'Advanced Algorithms');
  });

  testWidgets('Cancel deletion preserves preset', (tester) async {
    final id = await addPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      await dependencies.presetRepository.getPresetById(id),
      isNotNull,
    );
  });

  testWidgets('Confirm deletion removes preset', (tester) async {
    final id = await addPreset();
    await openDashboard(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextButton, 'Delete'),
    );
    await tester.pumpAndSettle();

    expect(
      await dependencies.presetRepository.getPresetById(id),
      isNull,
    );
  });

  testWidgets('Mood filter shows matching presets', (tester) async {
    await addPreset(name: 'Algorithms');
    await addPreset(
      name: 'Flutter',
      mood: 'Motivated',
    );

    await openDashboard(tester);

    await tester.tap(
      find.byKey(const ValueKey('mood_filter')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Focused').last);
    await tester.pumpAndSettle();

    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Flutter'), findsNothing);
  });

  testWidgets('Timer starts and pauses', (tester) async {
    await addPreset(minutes: 1);
    await openDashboard(tester);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('01:00'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Start'),
    );
    await tester.pump();

    expect(find.text('Running'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
  });

  testWidgets('Timer can finish and save a session', (tester) async {
    await addPreset(minutes: 1);
    await openDashboard(tester);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Start'),
    );
    await tester.pump();

    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Finish'));
    await tester.pump();
    await tester.runAsync(() async {
      for (var i = 0; i < 100; i++) {
        final sessions =
            await dependencies.sessionRepository.getAllSessions();
        if (sessions.isNotEmpty) break;
        await Future<void>.delayed(
          const Duration(milliseconds: 10),
        );
      }
    });

    final sessions =
        await dependencies.sessionRepository.getAllSessions();

    expect(sessions.length, 1);
    expect(sessions.first.status, 'partial');
  });

  testWidgets('History shows saved sessions', (tester) async {
    final id = await addPreset();

    await dependencies.saveSessionLog(
      presetId: id,
      date: DateTime(2026, 10, 26),
      completedSeconds: 1500,
      status: 'completed',
    );

    await openDashboard(tester);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(find.text('Completed Sessions: 1'), findsOneWidget);
    expect(
      find.text('Total Study Time: 25.0 minutes'),
      findsOneWidget,
    );
  });

  testWidgets('Settings screen opens', (tester) async {
    await openDashboard(tester);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Default Focus Duration'),
      findsOneWidget,
    );
    expect(find.text('Save Settings'), findsOneWidget);
  });

  testWidgets('Settings can save preferences', (tester) async {
    await openDashboard(tester);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Settings'));
    await tester.pumpAndSettle();

    final preferences =
        await SharedPreferences.getInstance();

    expect(
      preferences.getInt('default_focus_duration'),
      25,
    );
    expect(preferences.getBool('sound_enabled'), true);
  });
}

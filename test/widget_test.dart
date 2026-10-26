
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

  testWidgets('Dashboard shows empty state when no presets exist', (
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

  testWidgets('New button opens the preset form', (
    WidgetTester tester,
  ) async {
    await openDashboard(tester);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Preset Name'), findsOneWidget);
  });

  testWidgets('Preset form rejects an empty name', (
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

    expect(
      find.text('Mood: Focused | Duration: 25 minutes'),
      findsOneWidget,
    );

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets.length, 1);
    expect(presets.first.name, 'Algorithms Practice');
  });

  testWidgets('Start opens the selected preset timer', (
    WidgetTester tester,
  ) async {
    await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Mobile Development',
        moodTag: 'Motivated',
        durationMinutes: 40,
      ),
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
}

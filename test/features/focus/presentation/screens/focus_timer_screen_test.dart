
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/screens/focus_timer_screen.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper helper;
  late FocusDependencies dependencies;
  late FocusPreset preset;

  setUp(() async {
    helper = DatabaseHelper(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    dependencies = FocusDependencies(
      databaseHelper: helper,
    );

    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Algorithms',
        moodTag: 'Focused',
        durationMinutes: 1,
      ),
    );

    preset = (await dependencies.presetRepository.getPresetById(id))!;
  });

  tearDown(() async {
    await helper.close();
  });

  Future<void> openTimer(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FocusTimerScreen(
          preset: preset,
          saveSessionLog: dependencies.saveSessionLog,
        ),
      ),
    );

    await tester.pump();
  }

  final Finder timerStatus = find.byKey(
    const ValueKey('timer_status'),
  );

  final Finder timerDisplay = find.byKey(
    const ValueKey('timer_display'),
  );

  testWidgets('Timer starts in ready state', (tester) async {
    await openTimer(tester);

    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Mood: Focused'), findsOneWidget);

    expect(
      tester.widget<Text>(timerStatus).data,
      'Ready',
    );

    expect(
      tester.widget<Text>(timerDisplay).data,
      '01:00',
    );
  });

  testWidgets('Start changes status to running', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(
      tester.widget<Text>(timerStatus).data,
      'Running',
    );
  });

  testWidgets('Pause changes status to paused', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(
      tester.widget<Text>(timerStatus).data,
      'Paused',
    );
  });

  testWidgets('Resume returns timer to running', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pump();

    await tester.tap(find.text('Resume'));
    await tester.pump();

    expect(
      tester.widget<Text>(timerStatus).data,
      'Running',
    );
  });

  testWidgets('Reset returns timer to ready state', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pump();

    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(
      tester.widget<Text>(timerStatus).data,
      'Ready',
    );

    expect(
      tester.widget<Text>(timerDisplay).data,
      '01:00',
    );
  });

  testWidgets('Finish ends an active timer', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Finish'));
    await tester.pump();

    expect(
      tester.widget<Text>(timerStatus).data,
      'Finished',
    );
  });

  testWidgets('Start button is disabled while running', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    final startButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Start'),
    );

    expect(startButton.onPressed, isNull);
  });

  testWidgets('Pause button is disabled before starting', (tester) async {
    await openTimer(tester);

    final pauseButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pause'),
    );

    expect(pauseButton.onPressed, isNull);
  });

  testWidgets('Reset does not create a session log', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Reset'));
    await tester.pump();

    final sessions =
        await dependencies.sessionRepository.getAllSessions();

    expect(sessions, isEmpty);
  });
}

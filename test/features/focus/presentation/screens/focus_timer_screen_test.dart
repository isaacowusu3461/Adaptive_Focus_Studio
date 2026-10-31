
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/screens/focus_timer_screen.dart';

void main() {
  sqfliteFfiInit();

  const preset = FocusPreset(
    id: 1,
    name: 'Algorithms',
    moodTag: 'Focused',
    durationMinutes: 1,
  );

  late FocusDependencies dependencies;

  setUp(() {
    dependencies = FocusDependencies(
      databaseHelper: DatabaseHelper(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      ),
    );
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

  // The timer screen is scrollable, so a button may be below the test viewport.
  // This helper makes sure the button is visible before tapping it.
  Future<void> tapTimerButton(
    WidgetTester tester,
    String buttonText,
  ) async {
    final button = find.text(buttonText);

    expect(button, findsOneWidget);

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pump();
  }

  final timerStatus = find.byKey(const ValueKey('timer_status'));

  final timerDisplay = find.byKey(const ValueKey('timer_display'));

  testWidgets('Timer starts in ready state', (tester) async {
    await openTimer(tester);

    expect(find.text('Algorithms'), findsOneWidget);

    // Check the preset mood without depending on its exact label formatting.
    expect(find.textContaining('Focused'), findsWidgets);

    expect(tester.widget<Text>(timerStatus).data, 'Ready');
    expect(tester.widget<Text>(timerDisplay).data, '01:00');
  });

  testWidgets('Start changes status to running', (tester) async {
    await openTimer(tester);

    await tapTimerButton(tester, 'Start');

    expect(tester.widget<Text>(timerStatus).data, 'Running');
  });

  testWidgets('Pause changes status to paused', (tester) async {
    await openTimer(tester);

    await tapTimerButton(tester, 'Start');
    await tapTimerButton(tester, 'Pause');

    expect(tester.widget<Text>(timerStatus).data, 'Paused');
  });

  testWidgets('Resume returns timer to running', (tester) async {
    await openTimer(tester);

    await tapTimerButton(tester, 'Start');
    await tapTimerButton(tester, 'Pause');
    await tapTimerButton(tester, 'Resume');

    expect(tester.widget<Text>(timerStatus).data, 'Running');
  });

  testWidgets('Reset returns timer to ready state', (tester) async {
    await openTimer(tester);

    await tapTimerButton(tester, 'Start');
    await tapTimerButton(tester, 'Pause');
    await tapTimerButton(tester, 'Reset');

    expect(tester.widget<Text>(timerStatus).data, 'Ready');
    expect(tester.widget<Text>(timerDisplay).data, '01:00');
  });

  testWidgets('Start button is disabled while running', (tester) async {
    await openTimer(tester);

    await tapTimerButton(tester, 'Start');

    // Once the timer starts, Start should no longer be clickable.
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Start'),
    );

    expect(button.onPressed, isNull);
  });

  testWidgets('Pause button is disabled before starting', (tester) async {
    await openTimer(tester);

    // Pause should be disabled until the user starts a session.
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pause'),
    );

    expect(button.onPressed, isNull);
  });
}

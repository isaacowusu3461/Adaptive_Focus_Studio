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

  final timerStatus = find.byKey(const ValueKey('timer_status'));

  final timerDisplay = find.byKey(const ValueKey('timer_display'));

  testWidgets('Timer starts in ready state', (tester) async {
    await openTimer(tester);

    expect(find.text('Algorithms'), findsOneWidget);
    expect(find.text('Mood: Focused'), findsOneWidget);
    expect(tester.widget<Text>(timerStatus).data, 'Ready');
    expect(tester.widget<Text>(timerDisplay).data, '01:00');
  });

  testWidgets('Start changes status to running', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(tester.widget<Text>(timerStatus).data, 'Running');
  });

  testWidgets('Pause changes status to paused', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pump();

    expect(tester.widget<Text>(timerStatus).data, 'Paused');
  });

  testWidgets('Resume returns timer to running', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pump();

    await tester.tap(find.text('Resume'));
    await tester.pump();

    expect(tester.widget<Text>(timerStatus).data, 'Running');
  });

  testWidgets('Reset returns timer to ready state', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    await tester.tap(find.text('Pause'));
    await tester.pump();

    await tester.tap(find.text('Reset'));
    await tester.pump();

    expect(tester.widget<Text>(timerStatus).data, 'Ready');
    expect(tester.widget<Text>(timerDisplay).data, '01:00');
  });

  testWidgets('Start button is disabled while running', (tester) async {
    await openTimer(tester);

    await tester.tap(find.text('Start'));
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Start'),
    );

    expect(button.onPressed, isNull);
  });

  testWidgets('Pause button is disabled before starting', (tester) async {
    await openTimer(tester);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pause'),
    );

    expect(button.onPressed, isNull);
  });
}

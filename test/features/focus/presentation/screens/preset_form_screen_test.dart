import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/screens/preset_form_screen.dart';

void main() {
  sqfliteFfiInit();

  late FocusDependencies dependencies;

  setUp(() {
    dependencies = FocusDependencies(
      databaseHelper: DatabaseHelper(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      ),
    );
  });

  Future<void> openForm(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PresetFormScreen(
          createFocusPreset: dependencies.createFocusPreset,
          updateFocusPreset: dependencies.updateFocusPreset,
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('Create form displays default values', (tester) async {
    await openForm(tester);

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Save Preset'), findsOneWidget);

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    expect(fields.length, 2);
    expect(fields.last.controller!.text, '25');
  });

  testWidgets('Empty preset name shows validation error', (tester) async {
    await openForm(tester);

    await tester.tap(find.text('Save Preset'));
    await tester.pump();

    expect(find.text('Please enter a preset name'), findsOneWidget);
  });

  testWidgets('Whitespace-only name is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextFormField).first, '   ');

    await tester.tap(find.text('Save Preset'));
    await tester.pump();

    expect(find.text('Please enter a preset name'), findsOneWidget);
  });

  testWidgets('Zero duration is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Algorithms');

    await tester.enterText(find.byType(TextFormField).last, '0');

    await tester.tap(find.text('Save Preset'));
    await tester.pump();

    expect(find.text('Enter a duration between 1 and 180'), findsOneWidget);
  });

  testWidgets('Duration above 180 is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Algorithms');

    await tester.enterText(find.byType(TextFormField).last, '181');

    await tester.tap(find.text('Save Preset'));
    await tester.pump();

    expect(find.text('Enter a duration between 1 and 180'), findsOneWidget);
  });

  testWidgets('Non-numeric duration is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Algorithms');

    await tester.enterText(find.byType(TextFormField).last, 'abc');

    await tester.tap(find.text('Save Preset'));
    await tester.pump();

    expect(find.text('Enter a duration between 1 and 180'), findsOneWidget);
  });
}

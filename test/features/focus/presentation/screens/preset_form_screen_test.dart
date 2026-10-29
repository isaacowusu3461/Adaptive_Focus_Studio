
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:adaptive_focus_studio/features/focus/data/datasources/database_helper.dart';
import 'package:adaptive_focus_studio/features/focus/domain/entities/focus_preset.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/providers/focus_dependencies.dart';
import 'package:adaptive_focus_studio/features/focus/presentation/screens/preset_form_screen.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper helper;
  late FocusDependencies dependencies;

  setUp(() {
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

  Future<void> openForm(
    WidgetTester tester, {
    FocusPreset? preset,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PresetFormScreen(
          createFocusPreset: dependencies.createFocusPreset,
          updateFocusPreset: dependencies.updateFocusPreset,
          preset: preset,
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('Create form displays default values', (tester) async {
    await openForm(tester);

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Save Preset'), findsOneWidget);

    final fields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    ).toList();

    expect(fields.length, 2);
    expect(fields[1].controller!.text, '25');
  });

  testWidgets('Empty preset name shows validation error', (tester) async {
    await openForm(tester);

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a preset name'),
      findsOneWidget,
    );

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets, isEmpty);
  });

  testWidgets('Whitespace-only name is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      '   ',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a preset name'),
      findsOneWidget,
    );
  });

  testWidgets('Zero duration is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Algorithms',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '0',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a duration between 1 and 180'),
      findsOneWidget,
    );
  });

  testWidgets('Duration above 180 is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Algorithms',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '181',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a duration between 1 and 180'),
      findsOneWidget,
    );
  });

  testWidgets('Non-numeric duration is rejected', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Algorithms',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      'abc',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a duration between 1 and 180'),
      findsOneWidget,
    );
  });

  testWidgets('Valid preset is saved to SQLite', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Flutter Practice',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '40',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets.length, 1);
    expect(presets.first.name, 'Flutter Practice');
    expect(presets.first.durationMinutes, 40);
    expect(presets.first.moodTag, 'Focused');
  });

  testWidgets('Preset name is trimmed before saving', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      '  Database Revision  ',
    );

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets.first.name, 'Database Revision');
  });

  testWidgets('Editing displays existing preset values', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Reading',
        moodTag: 'Relaxed',
        durationMinutes: 35,
      ),
    );

    final preset =
        await dependencies.presetRepository.getPresetById(id);

    await openForm(tester, preset: preset);

    expect(find.text('Edit Preset'), findsOneWidget);
    expect(find.text('Update Preset'), findsOneWidget);

    final fields = tester.widgetList<TextFormField>(
      find.byType(TextFormField),
    ).toList();

    expect(fields.first.controller!.text, 'Reading');
    expect(fields.last.controller!.text, '35');
  });

  testWidgets('Editing updates the existing preset', (tester) async {
    final id = await dependencies.presetRepository.createPreset(
      const FocusPreset(
        name: 'Old Name',
        moodTag: 'Focused',
        durationMinutes: 25,
      ),
    );

    final preset =
        await dependencies.presetRepository.getPresetById(id);

    await openForm(tester, preset: preset);

    await tester.enterText(
      find.byType(TextFormField).first,
      'New Name',
    );

    await tester.enterText(
      find.byType(TextFormField).last,
      '45',
    );

    await tester.tap(find.text('Update Preset'));
    await tester.pumpAndSettle();

    final updated =
        await dependencies.presetRepository.getPresetById(id);

    final allPresets =
        await dependencies.presetRepository.getAllPresets();

    expect(updated!.name, 'New Name');
    expect(updated.durationMinutes, 45);
    expect(allPresets.length, 1);
  });

  testWidgets('Cancel does not create a preset', (tester) async {
    await openForm(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Temporary Preset',
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final presets =
        await dependencies.presetRepository.getAllPresets();

    expect(presets, isEmpty);
  });
}

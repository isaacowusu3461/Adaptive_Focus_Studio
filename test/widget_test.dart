
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/app.dart';

void main() {
  testWidgets('Welcome screen displays expected content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    expect(
      find.text('Welcome to Adaptive Focus Studio'),
      findsOneWidget,
    );

    expect(
      find.text('Get Started'),
      findsOneWidget,
    );

    expect(
      find.byIcon(Icons.timer_outlined),
      findsOneWidget,
    );
  });

  testWidgets('Get Started opens the Dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('My Focus Presets'), findsOneWidget);
    expect(find.text('Study Summary'), findsOneWidget);
  });

  testWidgets('Bottom navigation opens History and Settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

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

  testWidgets('New button opens preset form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    expect(find.text('Create Preset'), findsOneWidget);
    expect(find.text('Preset Name'), findsOneWidget);
  });

  testWidgets('Preset form rejects an empty name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Preset'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a preset name'),
      findsOneWidget,
    );
  });
}

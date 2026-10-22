import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_focus_studio/main.dart';

void main() {
  testWidgets('Welcome screen displays expected content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    expect(find.text('Welcome to Adaptive Focus Studio'), findsOneWidget);

    expect(find.text('Get Started'), findsOneWidget);

    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
  });

  testWidgets('Get Started button displays a message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AdaptiveFocusStudioApp());

    await tester.tap(find.text('Get Started'));
    await tester.pump();

    expect(find.text('Study features are coming soon!'), findsOneWidget);
  });
}

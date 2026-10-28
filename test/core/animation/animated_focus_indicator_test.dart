
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/core/widgets/animated_focus_indicator.dart';

void main() {
  Widget buildTestWidget({
    required bool isActive,
    required bool reduceMotion,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AnimatedFocusIndicator(
            isActive: isActive,
            reduceMotion: reduceMotion,
          ),
        ),
      ),
    );
  }

  testWidgets('shows inactive indicator', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        isActive: false,
        reduceMotion: false,
      ),
    );

    expect(
      find.byIcon(Icons.self_improvement),
      findsOneWidget,
    );
  });

  testWidgets('shows active indicator', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        isActive: true,
        reduceMotion: false,
      ),
    );

    expect(
      find.byIcon(Icons.psychology),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion stops pulsing', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        isActive: true,
        reduceMotion: true,
      ),
    );

    final transition = tester.widget<ScaleTransition>(
      find.byType(ScaleTransition),
    );

    final initialScale = transition.scale.value;

    await tester.pump(const Duration(seconds: 2));

    expect(transition.scale.value, initialScale);
  });

  testWidgets('active indicator animates when allowed', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        isActive: true,
        reduceMotion: false,
      ),
    );

    final transition = tester.widget<ScaleTransition>(
      find.byType(ScaleTransition),
    );

    final initialScale = transition.scale.value;

    await tester.pump(const Duration(milliseconds: 300));

    expect(transition.scale.value, isNot(initialScale));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switches from active to inactive', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        isActive: true,
        reduceMotion: false,
      ),
    );

    await tester.pumpWidget(
      buildTestWidget(
        isActive: false,
        reduceMotion: false,
      ),
    );

    expect(
      find.byIcon(Icons.self_improvement),
      findsOneWidget,
    );
  });

  testWidgets('disposes animation controller safely', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        isActive: true,
        reduceMotion: false,
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(const SizedBox());

    expect(tester.takeException(), isNull);
  });
}

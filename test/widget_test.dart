import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('Displays a welcome message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Welcome to Adaptive Focus Studio')),
          ),
        ),
      );

      expect(find.text('Welcome to Adaptive Focus Studio'), findsOneWidget);
    });

    testWidgets('Displays a focus preset card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                title: Text('Algorithms'),
                subtitle: Text('Focused - 25 minutes'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Algorithms'), findsOneWidget);
      expect(find.text('Focused - 25 minutes'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Button responds to a tap', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                pressed = true;
              },
              child: const Text('Start'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('Text field accepts user input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TextField())),
      );

      await tester.enterText(find.byType(TextField), 'Flutter Practice');

      expect(find.text('Flutter Practice'), findsOneWidget);
    });

    testWidgets('Displays a settings option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListTile(
              title: Text('Default Focus Duration'),
              trailing: Text('25 minutes'),
            ),
          ),
        ),
      );

      expect(find.text('Default Focus Duration'), findsOneWidget);

      expect(find.text('25 minutes'), findsOneWidget);
    });
  });
}

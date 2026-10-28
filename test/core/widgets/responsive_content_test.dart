
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/core/widgets/responsive_content.dart';

void main() {
  testWidgets('renders content on a narrow screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 350,
            child: ResponsiveContent(
              child: Text('Dashboard Content'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dashboard Content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('limits content width on wide screens', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: ResponsiveContent(
              maxWidth: 700,
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: Text('Wide Content'),
              ),
            ),
          ),
        ),
      ),
    );

    final contentSize = tester.getSize(
      find.byType(SizedBox).last,
    );

    expect(contentSize.width, lessThanOrEqualTo(700));
  });

  testWidgets('uses custom padding', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            padding: EdgeInsets.all(24),
            child: Text('Padded Content'),
          ),
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find.ancestor(
        of: find.text('Padded Content'),
        matching: find.byType(Padding),
      ).first,
    );

    expect(padding.padding, const EdgeInsets.all(24));
  });
}

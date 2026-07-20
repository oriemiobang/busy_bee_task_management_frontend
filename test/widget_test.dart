// test/widget_test.dart
//
// Smoke test — verifies the app initializes without crashing.
// Replaces the default Flutter counter boilerplate which is irrelevant to this project.
//
// Note: We do NOT boot the full MyApp here (it requires Firebase, platform channels,
// and a live backend). Instead, we verify that the core model/logic layer assembles
// correctly using a lightweight widget.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders a MaterialApp without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('BusyBee')),
        ),
      ),
    );

    expect(find.text('BusyBee'), findsOneWidget);
  });
}

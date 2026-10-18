// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_app/main.dart';

void main() {
  testWidgets('Goico Plaza shows room availability and booking controls', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Goico Plaza'), findsOneWidget);
    expect(find.text('Book a room'), findsOneWidget);
    expect(find.text('Available rooms'), findsOneWidget);

    await tester.tap(find.text('Book a room'));
    await tester.pumpAndSettle();

    expect(find.text('Reserve room'), findsOneWidget);
  });
}

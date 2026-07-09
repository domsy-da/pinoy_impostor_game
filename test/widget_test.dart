// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinoy_impostor_game/main.dart';

void main() {
  testWidgets('Game app launches smoke test', (WidgetTester tester) async {
    // Change 'MyApp()' to your actual class name: 'PinoyImpostorApp()'
    await tester.pumpWidget(const PinoyImpostorApp());

    // Verify that our main title or menu exists
    expect(find.text('Pinoy Impostor Game'), findsWidgets);
  });
}
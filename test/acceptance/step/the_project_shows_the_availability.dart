import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the project {'Los Pinos'} shows the availability {'3 de 4 lotes disponibles (75 %)'}
Future<void> theProjectShowsTheAvailability(WidgetTester tester, String name, String availability) async {
  final card = projectCard(name);
  expect(find.descendant(of: card, matching: find.text(availability)), findsOneWidget);
  expect(find.descendant(of: card, matching: find.byType(LinearProgressIndicator)), findsOneWidget);
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the buyer runs the simulation
Future<void> theBuyerRunsTheSimulation(WidgetTester tester) async {
  await tapButton(tester, find.widgetWithText(FilledButton, 'Simular financiamiento'));
}

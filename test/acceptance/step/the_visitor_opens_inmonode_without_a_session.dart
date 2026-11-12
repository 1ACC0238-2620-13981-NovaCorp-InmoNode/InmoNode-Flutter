import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the visitor opens InmoNode without a session
Future<void> theVisitorOpensInmonodeWithoutASession(WidgetTester tester) async {
  await startApp(tester);
  expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
}

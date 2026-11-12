import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the visitor is offered the password recovery flow
Future<void> theVisitorIsOfferedThePasswordRecoveryFlow(WidgetTester tester) async {
  await tapButton(tester, find.widgetWithText(TextButton, '¿Olvidaste tu contraseña?'));
  expect(find.text('Recuperar contraseña'), findsOneWidget);
}

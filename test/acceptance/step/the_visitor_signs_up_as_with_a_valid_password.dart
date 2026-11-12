import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/world.dart';

/// Usage: the visitor signs up as {'ana@mail.com'} with a valid password
Future<void> theVisitorSignsUpAsWithAValidPassword(WidgetTester tester, String email) async {
  const password = 'Clave-Segura-2026';
  final world = World.current;
  world.accountsBefore = world.accounts.count;
  await tapButton(tester, find.widgetWithText(TextButton, 'Crear cuenta'));
  await enterField(tester, 'Correo electrónico', email);
  await enterField(tester, 'Contraseña', password);
  await enterField(tester, 'Confirmar contraseña', password);
  await tapButton(tester, find.widgetWithText(FilledButton, 'Crear cuenta'));
}

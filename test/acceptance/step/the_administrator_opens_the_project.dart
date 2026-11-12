import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/world.dart';

/// Usage: the administrator opens the project {'Los Pinos'}
Future<void> theAdministratorOpensTheProject(WidgetTester tester, String name) async {
  final project = World.current.catalog.projectNamed(name)!;
  await enterField(tester, 'ID del proyecto', '${project.id}');
  await tapButton(tester, find.widgetWithText(TextButton, 'Cargar proyecto'));
  expect(find.textContaining(RegExp('^${RegExp.escape(name)} · .+ · ID ${project.id}\$')), findsOneWidget);
}

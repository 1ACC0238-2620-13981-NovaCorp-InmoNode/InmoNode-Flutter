import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the administrator publishes the project
Future<void> theAdministratorPublishesTheProject(WidgetTester tester) async {
  await tapButton(tester, find.widgetWithText(FilledButton, 'Publicar proyecto'));
  expect(find.text('Proyecto publicado. Ahora publica los lotes que quieras ofrecer.'), findsOneWidget);
  expect(find.textContaining(RegExp(r' · Publicado · ID \d+$')), findsOneWidget);
}

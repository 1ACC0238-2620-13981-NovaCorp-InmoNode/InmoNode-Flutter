import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the administrator publishes the lot {'N-01'}
Future<void> theAdministratorPublishesTheLot(WidgetTester tester, String code) async {
  await tapButton(
    tester,
    find.descendant(of: adminLotCard(code), matching: find.widgetWithText(TextButton, 'Publicar lote')),
  );
  expect(find.text('Lote $code publicado: ya figura como disponible.'), findsOneWidget);
}

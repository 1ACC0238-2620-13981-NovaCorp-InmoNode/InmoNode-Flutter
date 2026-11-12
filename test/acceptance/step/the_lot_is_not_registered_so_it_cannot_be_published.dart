import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/world.dart';

/// Usage: the lot {'N-02'} is not registered, so it cannot be published
Future<void> theLotIsNotRegisteredSoItCannotBePublished(WidgetTester tester, String code) async {
  expect(World.current.catalog.lotCoded(code), isNull);
  expect(find.text('Revisa los campos marcados.'), findsOneWidget);
  expect(adminLotCard(code), findsNothing);
  // Only the lot registered before keeps its publication button.
  expect(find.widgetWithText(TextButton, 'Publicar lote'), findsOneWidget);
}

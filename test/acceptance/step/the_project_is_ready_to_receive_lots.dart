import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: the project {'Los Pinos'} is ready to receive lots
Future<void> theProjectIsReadyToReceiveLots(WidgetTester tester, String name) async {
  expect(find.text('Registrar lote'), findsOneWidget);
  expect(find.widgetWithText(FilledButton, 'Registrar lote borrador'), findsOneWidget);
  expect(find.text('Aún no hay lotes registrados.'), findsOneWidget);
}

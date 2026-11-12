import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: no quotation is requested
Future<void> noQuotationIsRequested(WidgetTester tester) async {
  expect(World.current.quotations.requests, isEmpty);
  expect(find.text('Resultado de la simulación'), findsNothing);
}

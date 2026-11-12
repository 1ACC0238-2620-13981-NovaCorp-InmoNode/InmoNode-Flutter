import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: no project is created
Future<void> noProjectIsCreated(WidgetTester tester) async {
  expect(World.current.catalog.projects, isEmpty);
  expect(find.text('Revisa los campos marcados.'), findsOneWidget);
  expect(find.text('Registrar lote'), findsNothing);
}

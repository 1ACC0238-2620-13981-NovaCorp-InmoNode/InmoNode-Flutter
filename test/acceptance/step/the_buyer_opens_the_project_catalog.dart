import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: the buyer opens the project catalog
Future<void> theBuyerOpensTheProjectCatalog(WidgetTester tester) async {
  await openSection(tester, 'Proyectos');
  expect(find.text('Explora los proyectos publicados, sus precios y la disponibilidad de lotes.'), findsOneWidget);
}

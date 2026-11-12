import 'package:flutter_test/flutter_test.dart';

/// Usage: the administrator is asked to fix the polygon with {'El polígono se cruza consigo mismo ...'}
Future<void> theAdministratorIsAskedToFixThePolygonWith(WidgetTester tester, String message) async {
  expect(find.text(message), findsOneWidget);
}

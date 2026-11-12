import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: its lot {'N-01'} was registered at {45000} with its polygon
Future<void> itsLotWasRegisteredAtWithItsPolygon(WidgetTester tester, String code, num price) async {
  final catalog = World.current.catalog;
  catalog.addLot(catalog.projects.last, code: code, price: price.toDouble());
}

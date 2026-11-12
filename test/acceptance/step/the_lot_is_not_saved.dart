import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/world.dart';

/// Usage: the lot {'N-02'} is not saved
Future<void> theLotIsNotSaved(WidgetTester tester, String code) async {
  expect(World.current.catalog.lotCoded(code), isNull);
  expect(adminLotCard(code), findsNothing);
}

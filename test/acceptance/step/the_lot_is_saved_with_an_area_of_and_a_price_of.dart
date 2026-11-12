import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/formatting/formats.dart';

import '../support/app_driver.dart';
import '../support/world.dart';

/// Usage: the lot {'N-01'} is saved with an area of {120} and a price of {45000}
Future<void> theLotIsSavedWithAnAreaOfAndAPriceOf(WidgetTester tester, String code, num area, num price) async {
  final lot = World.current.catalog.lotCoded(code)!;
  expect(lot.area, area);
  expect(lot.price, price);
  expect(lot.boundary.vertices, hasLength(4));
  expect(
    find.descendant(
      of: adminLotCard(code),
      matching: find.textContaining('${Formats.area(area)} · ${Formats.money(price)}'),
    ),
    findsOneWidget,
  );
}

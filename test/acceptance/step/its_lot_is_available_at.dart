import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';

import '../support/world.dart';

/// Usage: its lot {'N-01'} is available at {45000}
Future<void> itsLotIsAvailableAt(WidgetTester tester, String code, num price) async {
  final catalog = World.current.catalog;
  catalog.addLot(catalog.projects.last, code: code, price: price.toDouble(), status: LotStatus.available);
}

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

import '../support/world.dart';

/// Usage: the published project {'Los Pinos'} in {'Carabayllo, Lima'} with these lots:
Future<void> thePublishedProjectInWithTheseLots(
  WidgetTester tester,
  String name,
  String location,
  bdd.DataTable lots,
) async {
  final catalog = World.current.catalog;
  final project = catalog.addProject(name: name, location: location, status: ProjectStatus.published);
  for (final lot in lots.asMaps()) {
    catalog.addLot(
      project,
      code: lot['code'] as String,
      price: (lot['price'] as num).toDouble(),
      status: LotStatus.fromApiName(lot['status'] as String),
    );
  }
}

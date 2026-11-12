import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

import '../support/admin_forms.dart';

/// Usage: the administrator registers this lot:
Future<void> theAdministratorRegistersThisLot(WidgetTester tester, bdd.DataTable lot) async {
  final row = lot.asMaps().single;
  await submitLotForm(
    tester,
    code: row['code'] as String,
    stage: row['stage'] as String,
    area: '${row['area']}',
    front: '${row['front']}',
    depth: '${row['depth']}',
    price: '${row['price']}',
    polygon: row['polygon'] as String,
  );
}

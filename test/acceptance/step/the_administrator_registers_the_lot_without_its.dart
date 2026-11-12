import 'package:flutter_test/flutter_test.dart';

import '../support/admin_forms.dart';

/// Usage: the administrator registers the lot {'N-02'} without its {'price'}
Future<void> theAdministratorRegistersTheLotWithoutIts(WidgetTester tester, String code, String missingData) async {
  await submitLotForm(
    tester,
    code: code,
    price: missingData == 'price' ? '' : '45000',
    polygon: missingData == 'polygon' ? '' : squarePolygon,
  );
}

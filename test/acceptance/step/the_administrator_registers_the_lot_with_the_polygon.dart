import 'package:flutter_test/flutter_test.dart';

import '../support/admin_forms.dart';

/// Usage: the administrator registers the lot {'N-02'} with the polygon {'-77.0428,-12.0464; ...'}
Future<void> theAdministratorRegistersTheLotWithThePolygon(WidgetTester tester, String code, String polygon) async {
  await submitLotForm(tester, code: code, polygon: polygon);
}

import 'package:flutter_test/flutter_test.dart';

import '../support/admin_forms.dart';

/// Usage: the administrator creates the project {'Los Pinos'} without a location
Future<void> theAdministratorCreatesTheProjectWithoutALocation(WidgetTester tester, String name) async {
  await submitProjectForm(tester, name: name, location: null, stages: 'Norte, Sur');
}

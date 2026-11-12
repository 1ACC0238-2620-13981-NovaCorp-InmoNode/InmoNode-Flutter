import 'package:flutter_test/flutter_test.dart';

import '../support/admin_forms.dart';

/// Usage: the administrator creates the project {'Los Pinos'} in {'Carabayllo, Lima'} with the stages {'Norte, Sur'}
Future<void> theAdministratorCreatesTheProjectInWithTheStages(
  WidgetTester tester,
  String name,
  String location,
  String stages,
) async {
  await submitProjectForm(tester, name: name, location: location, stages: stages);
}

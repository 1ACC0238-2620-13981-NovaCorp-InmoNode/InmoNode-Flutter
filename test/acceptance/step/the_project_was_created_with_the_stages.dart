import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: the project {'Los Pinos'} was created with the stages {'Norte, Sur'}
Future<void> theProjectWasCreatedWithTheStages(WidgetTester tester, String name, String stages) async {
  World.current.catalog.addProject(name: name, stages: [for (final stage in stages.split(',')) stage.trim()]);
}

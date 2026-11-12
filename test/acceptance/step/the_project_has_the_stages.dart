import 'package:flutter_test/flutter_test.dart';

import '../support/world.dart';

/// Usage: the project {'Los Pinos'} has the stages {'Norte, Sur'}
Future<void> theProjectHasTheStages(WidgetTester tester, String name, String stages) async {
  final project = World.current.catalog.projectNamed(name)!;
  expect(project.stages.join(', '), stages);
  expect(find.text('${project.location} · Etapas: $stages'), findsOneWidget);
}

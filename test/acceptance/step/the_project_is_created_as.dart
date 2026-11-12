import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

import '../support/world.dart';

/// Usage: the project {'Los Pinos'} is created as {'Borrador'}
Future<void> theProjectIsCreatedAs(WidgetTester tester, String name, String status) async {
  final project = World.current.catalog.projectNamed(name);
  expect(project?.status, ProjectStatus.draft);
  expect(find.text('$name · $status · ID ${project!.id}'), findsOneWidget);
  expect(find.textContaining('creado como borrador con el ID ${project.id}'), findsOneWidget);
}

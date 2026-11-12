import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/presentation/project_card.dart';

/// Usage: the catalog lists the projects {'Brisas del Sur, Los Pinos'}
Future<void> theCatalogListsTheProjects(WidgetTester tester, String names) async {
  final cards = tester.widgetList<ProjectCard>(find.byType(ProjectCard));
  expect([for (final card in cards) card.project.name], names.split(', '));
}

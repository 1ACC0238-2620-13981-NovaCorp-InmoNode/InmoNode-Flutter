import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/presentation/project_card.dart';

import '../support/app_driver.dart';

/// Usage: buyers cannot see the lot {'N-01'}
Future<void> buyersCannotSeeTheLot(WidgetTester tester, String code) async {
  await switchToBuyer(tester);
  final projects = [for (final card in tester.widgetList<ProjectCard>(find.byType(ProjectCard))) card.project.name];
  for (final name in projects) {
    await tapButton(tester, projectCard(name));
    expect(find.text('Lote $code'), findsNothing, reason: name);
    await tester.pageBack();
    await tester.pumpAndSettle();
  }
  expect(find.text('Lote $code'), findsNothing);
}

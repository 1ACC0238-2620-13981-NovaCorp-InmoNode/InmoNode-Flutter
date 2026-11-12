import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/presentation/project_cover.dart';

import '../support/app_driver.dart';

/// Usage: the project {'Los Pinos'} shows a thumbnail
Future<void> theProjectShowsAThumbnail(WidgetTester tester, String name) async {
  expect(find.descendant(of: projectCard(name), matching: find.byType(ProjectCover)), findsOneWidget);
}

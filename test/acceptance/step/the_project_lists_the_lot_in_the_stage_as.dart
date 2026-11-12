import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';
import '../support/world.dart';

/// Usage: the project {'Los Pinos'} lists the lot {'N-01'} in the stage {'Sur'} as {'Borrador'}
Future<void> theProjectListsTheLotInTheStageAs(
  WidgetTester tester,
  String projectName,
  String code,
  String stage,
  String status,
) async {
  final catalog = World.current.catalog;
  final lot = catalog.lotCoded(code);
  expect(lot?.projectId, catalog.projectNamed(projectName)!.id);
  expect(lot!.stageName, stage);
  final card = adminLotCard(code);
  expect(find.descendant(of: card, matching: find.text('$code · Etapa $stage')), findsOneWidget);
  expect(
    find.descendant(of: card, matching: find.textContaining(RegExp('^${RegExp.escape(status)} · '))),
    findsOneWidget,
  );
}

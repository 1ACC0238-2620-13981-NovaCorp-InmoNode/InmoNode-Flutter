import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_driver.dart';

/// Usage: a buyer finds the lot {'N-01'} of {'Los Pinos'} available in the catalog
Future<void> aBuyerFindsTheLotOfAvailableInTheCatalog(WidgetTester tester, String code, String projectName) async {
  await switchToBuyer(tester);
  expect(find.descendant(of: projectCard(projectName), matching: find.text('1 de 1 lote disponible (100 %)')), findsOneWidget);
  await tapButton(tester, projectCard(projectName));
  final tile = find.ancestor(of: find.text('Lote $code'), matching: find.byType(ListTile));
  expect(find.descendant(of: tile, matching: find.text('Disponible')), findsOneWidget);
}

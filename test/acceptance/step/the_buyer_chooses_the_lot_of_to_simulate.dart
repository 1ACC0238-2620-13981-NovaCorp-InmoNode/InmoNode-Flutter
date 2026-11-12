import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/quotations/presentation/simulation_panel.dart';

import '../support/app_driver.dart';

/// Usage: the buyer chooses the lot {'N-01'} of {'Los Pinos'} to simulate
Future<void> theBuyerChoosesTheLotOfToSimulate(WidgetTester tester, String code, String projectName) async {
  await openSection(tester, 'Proyectos');
  await tapButton(tester, projectCard(projectName));
  await tapButton(tester, find.text('Lote $code'));
  expect(find.byType(SimulationPanel), findsOneWidget);
  expect(find.text('Lote $code'), findsOneWidget);
}

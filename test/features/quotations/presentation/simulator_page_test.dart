import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/quotations/application/simulate_financing_use_case.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';
import 'package:inmonode/features/quotations/presentation/simulator_page.dart';
import 'package:inmonode/features/quotations/presentation/simulator_view_model.dart';

import '../../catalog/catalog_fakes.dart';
import '../quotation_fakes.dart';

void main() {
  late FakeProjectRepository projects;
  late FakeQuotationRepository quotations;

  setUp(() {
    projects = FakeProjectRepository();
    projects.onGetPublished = () async => [testSummary(), soldOutSummary()];
    projects.onGetProject = (id) async => testProject(id: id);
    projects.onGetLots = (_) async => [
      testLot(id: 1, code: 'A-01'),
      testLot(id: 2, code: 'A-02', status: LotStatus.sold),
    ];
    quotations = FakeQuotationRepository()..onSimulate = (_) async => testQuotation();
  });

  Future<void> pumpSimulator(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SimulatorViewModel create() => SimulatorViewModel(
      getPublishedProjects: GetPublishedProjectsUseCase(repository: projects),
      getProjectDetail: GetProjectDetailUseCase(repository: projects),
      createSimulation: (lot) => SimulationViewModel(
        simulateFinancing: SimulateFinancingUseCase(repository: quotations),
        lot: lot,
      ),
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SimulatorPage(createViewModel: create))));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String label, String option) async {
    await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  testWidgets('simulates an available lot chosen from its project', (tester) async {
    await pumpSimulator(tester);

    await choose(tester, 'Proyecto', 'Villa del Sol');
    expect(find.text('Elige su único lote disponible para simular su financiamiento.'), findsOneWidget);
    await choose(tester, 'Lote', 'Lote A-01 · 120 m² · S/ 45,000.00');
    await tester.tap(find.text('Simular financiamiento'));
    await tester.pumpAndSettle();

    expect(quotations.calls.single.lotId, 1);
    expect(find.text('Cuota mensual'), findsOneWidget);
  });

  testWidgets('leaves sold-out projects and unavailable lots out of the choices', (tester) async {
    await pumpSimulator(tester);

    await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'Proyecto'));
    await tester.pumpAndSettle();
    expect(find.text('Los Olivos II'), findsNothing);
    await tester.tap(find.text('Villa del Sol').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'Lote'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Lote A-02'), findsNothing);
  });

  testWidgets('says so when no lot is available', (tester) async {
    projects.onGetPublished = () async => [soldOutSummary()];

    await pumpSimulator(tester);

    expect(find.text('Por ahora no hay lotes disponibles para simular.'), findsOneWidget);
  });
}

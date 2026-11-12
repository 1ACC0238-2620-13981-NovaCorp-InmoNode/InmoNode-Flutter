import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/di/dependency_injection.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/presentation/project_detail_view_model.dart';
import 'package:inmonode/features/catalog/presentation/projects_page.dart';
import 'package:inmonode/features/catalog/presentation/projects_view_model.dart';
import 'package:inmonode/features/quotations/application/simulate_financing_use_case.dart';
import 'package:inmonode/features/quotations/domain/quotable_lot.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';

import '../../quotations/quotation_fakes.dart';
import '../catalog_fakes.dart';

void main() {
  late FakeProjectRepository repository;

  late FakeQuotationRepository quotations;

  setUp(() {
    repository = FakeProjectRepository();
    quotations = FakeQuotationRepository()..onSimulate = (_) async => testQuotation();
    getIt.registerFactory<ProjectDetailViewModel>(
      () => ProjectDetailViewModel(getProjectDetail: GetProjectDetailUseCase(repository: repository)),
    );
    getIt.registerFactoryParam<SimulationViewModel, QuotableLot, void>(
      (lot, _) => SimulationViewModel(simulateFinancing: SimulateFinancingUseCase(repository: quotations), lot: lot),
    );
  });

  tearDown(() => getIt.reset());

  Future<void> pumpProjectsPage(WidgetTester tester) async {
    final viewModel = ProjectsViewModel(
      getPublishedProjects: GetPublishedProjectsUseCase(repository: repository),
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ProjectsPage(viewModel: viewModel))));
    await tester.pumpAndSettle();
  }

  testWidgets('shows a card per published project, sold-out ones included', (tester) async {
    repository.onGetPublished = () async => [testSummary(), soldOutSummary()];

    await pumpProjectsPage(tester);

    expect(find.text('Villa del Sol'), findsOneWidget);
    expect(find.text('Los Olivos II'), findsOneWidget);
    expect(find.text('VENDIDO TOTALMENTE'), findsOneWidget);
  });

  testWidgets('stacks the cards in one column on a phone', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository.onGetPublished = () async => [testSummary(), soldOutSummary()];

    await pumpProjectsPage(tester);

    final first = tester.getTopLeft(find.text('Villa del Sol'));
    await tester.scrollUntilVisible(find.text('Los Olivos II'), 200);
    final second = tester.getTopLeft(find.text('Los Olivos II'));
    expect(second.dx, first.dx);
  });

  testWidgets('shows the cards side by side on a wide screen', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository.onGetPublished = () async => [testSummary(), soldOutSummary()];

    await pumpProjectsPage(tester);

    final first = tester.getTopLeft(find.text('Villa del Sol'));
    final second = tester.getTopLeft(find.text('Los Olivos II'));
    expect(second.dy, first.dy);
    expect(second.dx, greaterThan(first.dx));
  });

  testWidgets('says so when nothing is published yet', (tester) async {
    repository.onGetPublished = () async => [];

    await pumpProjectsPage(tester);

    expect(find.text('Aún no hay proyectos publicados'), findsOneWidget);
  });

  testWidgets('lets the user retry when the catalog cannot be reached', (tester) async {
    repository.onGetPublished = () async => throw const ApiException.network();
    await pumpProjectsPage(tester);
    expect(find.textContaining('No se pudo conectar'), findsOneWidget);

    repository.onGetPublished = () async => [testSummary()];
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Villa del Sol'), findsOneWidget);
    expect(repository.publishedCalls, 2);
  });

  testWidgets('opens a project with its financing conditions and lots', (tester) async {
    repository.onGetPublished = () async => [testSummary()];
    repository.onGetProject = (_) async => testProject();
    repository.onGetLots = (_) async => [
      testLot(id: 1, code: 'A-01'),
      testLot(id: 2, code: 'A-02', status: LotStatus.reserved),
    ];
    await pumpProjectsPage(tester);

    await tester.tap(find.text('Villa del Sol'));
    await tester.pumpAndSettle();

    expect(find.text('Condiciones de financiamiento'), findsOneWidget);
    expect(find.text('10 %'), findsOneWidget);
    expect(find.text('60 meses'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Etapa 1'), 200);
    expect(find.text('Etapa 2'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Lote A-02'), 200);
    expect(find.text('Lote A-01'), findsOneWidget);
    expect(find.text('1 de 2 disponibles'), findsOneWidget);
    expect(find.text('Reservado'), findsOneWidget);
    expect(find.text('120 m² · 8 m × 15 m'), findsNWidgets(2));
  });

  testWidgets('simulates an available lot from its project and refreshes the lots afterwards', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var lotLoads = 0;
    repository.onGetPublished = () async => [testSummary()];
    repository.onGetProject = (_) async => testProject();
    repository.onGetLots = (_) async {
      lotLoads++;
      return [testLot(id: 1, code: 'A-01'), testLot(id: 2, code: 'A-02', status: LotStatus.reserved)];
    };
    await pumpProjectsPage(tester);
    await tester.tap(find.text('Villa del Sol'));
    await tester.pumpAndSettle();

    // Only the available lot opens the simulator.
    await tester.scrollUntilVisible(find.text('Lote A-02'), 200);
    await tester.tap(find.text('Lote A-02'));
    await tester.pumpAndSettle();
    expect(find.text('Simular financiamiento'), findsNothing);

    await tester.tap(find.text('Lote A-01'));
    await tester.pumpAndSettle();
    expect(find.text('Simular financiamiento'), findsNWidgets(2));
    expect(find.text('Mínimo S/ 4,500.00 (10 % del precio)'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Simular financiamiento'));
    await tester.pumpAndSettle();
    expect(quotations.calls.single, (lotId: 1, initialPayment: 4500.0, termMonths: 60));

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(lotLoads, 2);
  });
}

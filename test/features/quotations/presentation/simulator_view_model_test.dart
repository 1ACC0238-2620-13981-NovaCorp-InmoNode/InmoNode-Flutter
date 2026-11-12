import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/quotations/application/simulate_financing_use_case.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';
import 'package:inmonode/features/quotations/presentation/simulator_view_model.dart';

import '../../catalog/catalog_fakes.dart';
import '../quotation_fakes.dart';

void main() {
  late FakeProjectRepository projects;
  late List<SimulationViewModel> created;
  late SimulatorViewModel viewModel;

  setUp(() {
    projects = FakeProjectRepository();
    projects.onGetPublished = () async => [testSummary(), soldOutSummary()];
    projects.onGetProject = (id) async => testProject(id: id);
    projects.onGetLots = (_) async => [
      testLot(id: 1, code: 'A-01'),
      testLot(id: 2, code: 'A-02', status: LotStatus.reserved),
      testLot(id: 3, code: 'A-03'),
    ];
    created = [];
    viewModel = SimulatorViewModel(
      getPublishedProjects: GetPublishedProjectsUseCase(repository: projects),
      getProjectDetail: GetProjectDetailUseCase(repository: projects),
      createSimulation: (lot) {
        final simulation = SimulationViewModel(
          simulateFinancing: SimulateFinancingUseCase(repository: FakeQuotationRepository()),
          lot: lot,
        );
        created.add(simulation);
        return simulation;
      },
    );
  });

  test('offers only the projects that still have an available lot', () async {
    await viewModel.load();

    expect(viewModel.hasLoaded, isTrue);
    expect([for (final project in viewModel.projects) project.name], ['Villa del Sol']);
  });

  test('offers the available lots of the chosen project with its financing rules', () async {
    await viewModel.load();

    await viewModel.selectProject(1);

    expect([for (final lot in viewModel.lots) lot.lotCode], ['A-01', 'A-03']);
    expect(viewModel.lots.first.annualInterestRate, 12.5);
    expect(viewModel.lots.first.maxTermMonths, 60);
    expect(viewModel.isLoadingLots, isFalse);
  });

  test('opens a simulator for the chosen lot and discards the previous one', () async {
    await viewModel.load();
    await viewModel.selectProject(1);

    viewModel.selectLot(1);
    final first = viewModel.simulation!;
    viewModel.selectLot(3);

    expect(first.lot.lotCode, 'A-01');
    expect(viewModel.simulation?.lot.lotCode, 'A-03');
    expect(created, hasLength(2));
    expect(() => first.addListener(() {}), throwsA(predicate((error) => error.toString().contains('disposed'))));
  });

  test('forgets the chosen lot when the buyer picks another project', () async {
    await viewModel.load();
    await viewModel.selectProject(1);
    viewModel.selectLot(1);

    await viewModel.selectProject(3);

    expect(viewModel.selectedLot, isNull);
    expect(viewModel.simulation, isNull);
  });

  test('lets the buyer retry when the lots cannot be loaded', () async {
    await viewModel.load();
    projects.onGetLots = (_) async => throw const ApiException.network();
    await viewModel.selectProject(1);
    expect(viewModel.lotsErrorMessage, const ApiException.network().message);

    projects.onGetLots = (_) async => [testLot(id: 1)];
    await viewModel.selectProject(1);

    expect(viewModel.lotsErrorMessage, isNull);
    expect(viewModel.lots, hasLength(1));
  });

  test('reports a catalog that cannot be reached', () async {
    projects.onGetPublished = () async => throw const ApiException.network();

    await viewModel.load();

    expect(viewModel.hasLoaded, isFalse);
    expect(viewModel.errorMessage, const ApiException.network().message);
  });
}

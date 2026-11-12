import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_labels.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_view_model.dart';

import '../catalog_admin_fakes.dart';

void main() {
  late FakeAdminCatalogRepository repository;
  late AdminCatalogViewModel viewModel;

  setUp(() {
    repository = FakeAdminCatalogRepository();
    viewModel = adminCatalogViewModel(repository);
  });

  test('works on the project it creates, starting with its first stage', () async {
    final created = await viewModel.submitProject(testNewProject());

    expect(created, isTrue);
    expect(viewModel.project!.id, 5);
    expect(viewModel.stage, 'Norte');
    expect(
      viewModel.feedbackFor(CatalogAction.createProject)!.message,
      'Proyecto «Los Pinos» creado como borrador con el ID 5. Registra sus lotes y luego publícalo.',
    );
    expect(viewModel.feedbackFor(CatalogAction.openProject), isNull);
  });

  test('keeps the chosen stage after registering a lot', () async {
    await viewModel.openProject(5);
    viewModel.selectStage('Sur');

    await viewModel.submitLot(testNewLot(code: 'S-01', stage: 'Sur'));

    expect(viewModel.stage, 'Sur');
    expect([for (final lot in viewModel.lots) lot.code], ['S-01']);
    expect(
      viewModel.feedbackFor(CatalogAction.registerLot)!.message,
      'Lote S-01 registrado como borrador en la etapa Sur.',
    );
  });

  test('runs one action at a time', () async {
    repository.gate = Completer<void>();

    final first = viewModel.submitProject(testNewProject());
    final second = viewModel.submitProject(testNewProject());
    expect(viewModel.running, CatalogAction.createProject);
    repository.gate!.complete();

    expect(await first, isTrue);
    expect(await second, isFalse);
    expect(repository.createdProjects, hasLength(1));
    expect(viewModel.isBusy, isFalse);
  });

  test('answers a failure in Spanish next to its action and keeps the form', () async {
    await viewModel.openProject(5);
    repository.failure = const LotCodeTaken('N-01');

    final registered = await viewModel.submitLot(testNewLot());

    expect(registered, isFalse);
    final feedback = viewModel.feedbackFor(CatalogAction.registerLot)!;
    expect(feedback.message, 'Ya existe un lote con el código N-01 en este proyecto.');
    expect(feedback.isError, isTrue);
  });

  test('answers the publication of a lot on that lot only', () async {
    repository.lots = [testAdminLot(), testAdminLot(id: 10, code: 'N-02')];
    await viewModel.openProject(5);
    await viewModel.publishSelectedProject();

    await viewModel.publishDraftLot(viewModel.lots.first);

    expect(
      viewModel.feedbackFor(CatalogAction.publishLot, lotId: 9)!.message,
      'Lote N-01 publicado: ya figura como disponible.',
    );
    expect(viewModel.feedbackFor(CatalogAction.publishLot, lotId: 10), isNull);
    expect(viewModel.lots.first.status, LotStatus.available);
  });

  test('marks the form to correct', () {
    viewModel.reportInvalidForm(CatalogAction.registerLot);

    expect(viewModel.feedbackFor(CatalogAction.registerLot)!.message, AdminCatalogLabels.invalidForm);
    expect(viewModel.feedbackFor(CatalogAction.registerLot)!.isError, isTrue);
  });

  test('finishes quietly when the page is gone', () async {
    repository.gate = Completer<void>();
    final opening = viewModel.openProject(5);

    viewModel.dispose();
    repository.gate!.complete();

    await expectLater(opening, completes);
  });
}

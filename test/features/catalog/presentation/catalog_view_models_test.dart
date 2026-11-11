import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/presentation/project_detail_view_model.dart';
import 'package:inmonode/features/catalog/presentation/projects_view_model.dart';

import '../catalog_fakes.dart';

void main() {
  late FakeProjectRepository repository;

  setUp(() => repository = FakeProjectRepository());

  group('ProjectsViewModel', () {
    late ProjectsViewModel viewModel;

    setUp(() {
      viewModel = ProjectsViewModel(
        getPublishedProjects: GetPublishedProjectsUseCase(repository: repository),
      );
    });

    test('loads the published projects, sold-out ones included', () async {
      repository.onGetPublished = () async => [testSummary(), soldOutSummary()];

      await viewModel.load();

      expect(viewModel.hasLoaded, isTrue);
      expect(viewModel.projects, hasLength(2));
      expect(viewModel.projects.last.soldOut, isTrue);
      expect(viewModel.isLoading, isFalse);
    });

    test('shows the error when the catalog cannot be reached', () async {
      repository.onGetPublished = () async => throw const ApiException.network();

      await viewModel.load();

      expect(viewModel.hasLoaded, isFalse);
      expect(viewModel.errorMessage, contains('No se pudo conectar'));
    });

    test('keeps the catalog on screen when a refresh fails', () async {
      repository.onGetPublished = () async => [testSummary()];
      await viewModel.load();

      repository.onGetPublished = () async => throw const ApiException.network();
      await viewModel.load();

      expect(viewModel.projects, hasLength(1));
      expect(viewModel.errorMessage, isNotNull);
    });

    test('does not stay loading when the answer cannot be read', () async {
      repository.onGetPublished = () async => throw const FormatException('Unknown lot status: X');

      await viewModel.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, ProjectsViewModel.unreadableMessage);
    });
  });

  group('ProjectDetailViewModel', () {
    late ProjectDetailViewModel viewModel;

    setUp(() {
      viewModel = ProjectDetailViewModel(
        getProjectDetail: GetProjectDetailUseCase(repository: repository),
      );
    });

    test('loads the project with its published lots only', () async {
      repository.onGetProject = (_) async => testProject();
      repository.onGetLots = (_) async => [
        testLot(id: 1, code: 'A-01'),
        testLot(id: 2, code: 'A-02', status: LotStatus.sold),
        testLot(id: 3, code: 'A-03', status: LotStatus.draft),
      ];

      await viewModel.load(1);

      expect(viewModel.project?.financingRules.maxTermMonths, 60);
      expect(viewModel.lots.map((lot) => lot.code), ['A-01', 'A-02']);
      expect(viewModel.availableLots, 1);
    });

    test('shows the server message when the lots fail to load', () async {
      repository.onGetProject = (_) async => testProject();
      repository.onGetLots = (_) async => throw const ApiException(
        statusCode: 404,
        code: 'PROJECT_NOT_FOUND',
        message: 'No se encontró el proyecto',
      );

      await viewModel.load(1);

      expect(viewModel.project, isNull);
      expect(viewModel.errorMessage, 'No se encontró el proyecto');
      expect(viewModel.isLoading, isFalse);
    });
  });
}

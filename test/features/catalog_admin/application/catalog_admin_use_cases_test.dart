import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/catalog_admin/application/get_admin_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/publish_lot_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/publish_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

import '../catalog_admin_fakes.dart';

void main() {
  late FakeAdminCatalogRepository repository;

  setUp(() => repository = FakeAdminCatalogRepository());

  test('loads a project together with all its lots', () async {
    repository.lots = [testAdminLot(), testAdminLot(id: 10, code: 'S-01', stage: 'Sur')];

    final detail = await GetAdminProjectUseCase(repository: repository).execute(5);

    expect(detail.project.name, 'Los Pinos');
    expect([for (final lot in detail.lots) lot.code], ['N-01', 'S-01']);
  });

  test('does not ask to publish a project without lots', () async {
    final publish = PublishProjectUseCase(repository: repository);

    await expectLater(
      publish.execute((project: testAdminProject(), lots: const [])),
      throwsA(isA<ProjectWithoutLots>()),
    );
    expect(repository.publishedProjects, isEmpty);

    await publish.execute((project: testAdminProject(), lots: [testAdminLot()]));
    expect(repository.publishedProjects, [5]);
  });

  test('does not ask to publish a lot while its project is a draft', () async {
    repository.lots = [testAdminLot()];
    final publish = PublishLotUseCase(repository: repository);

    await expectLater(publish.execute(testAdminProject(), testAdminLot()), throwsA(isA<ProjectNotPublished>()));
    expect(repository.publishedLots, isEmpty);

    await publish.execute(testAdminProject(status: ProjectStatus.published), testAdminLot());
    expect(repository.publishedLots, [9]);
  });
}

import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';

typedef AdminProjectDetail = ({AdminProject project, List<AdminLot> lots});

/// Loads a project of the back-office, draft or published, with all its lots.
class GetAdminProjectUseCase {
  final AdminCatalogRepository repository;

  const GetAdminProjectUseCase({required this.repository});

  Future<AdminProjectDetail> execute(int projectId) async {
    // Future.wait rethrows the first failure as is, so callers still get a CatalogRejection or an ApiException.
    final results = await Future.wait<Object>([repository.getProject(projectId), repository.getProjectLots(projectId)]);
    return (project: results[0] as AdminProject, lots: results[1] as List<AdminLot>);
  }
}

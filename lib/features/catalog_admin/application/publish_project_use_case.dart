import 'package:inmonode/features/catalog_admin/application/get_admin_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';

/// Shows a project to buyers. Its lots stay drafts until each one is published (US-53).
class PublishProjectUseCase {
  final AdminCatalogRepository repository;

  const PublishProjectUseCase({required this.repository});

  /// Throws [ProjectWithoutLots] without asking the Web Services when the project has no lot yet.
  Future<AdminProject> execute(AdminProjectDetail detail) async {
    if (detail.lots.isEmpty) throw const ProjectWithoutLots();
    return repository.publishProject(detail.project.id);
  }
}

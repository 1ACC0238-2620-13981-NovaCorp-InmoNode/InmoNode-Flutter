import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';

/// US-51: creates a project as a draft, still hidden from buyers.
class CreateProjectUseCase {
  final AdminCatalogRepository repository;

  const CreateProjectUseCase({required this.repository});

  Future<AdminProject> execute(NewProject project) => repository.createProject(project);
}

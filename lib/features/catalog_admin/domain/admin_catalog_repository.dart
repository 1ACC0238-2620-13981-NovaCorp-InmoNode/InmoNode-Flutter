import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';

/// Catalog back-office of `CATALOG_ADMIN`. Broken rules are thrown as a `CatalogRejection`.
abstract class AdminCatalogRepository {
  Future<AdminProject> createProject(NewProject project);

  /// A project, even a draft one.
  Future<AdminProject> getProject(int projectId);

  /// Every lot of a project, drafts included.
  Future<List<AdminLot>> getProjectLots(int projectId);

  Future<AdminLot> registerLot(int projectId, NewLot lot);

  Future<AdminProject> publishProject(int projectId);

  Future<AdminLot> publishLot(int lotId);
}

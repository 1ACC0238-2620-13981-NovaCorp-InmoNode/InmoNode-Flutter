import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';

/// US-53: offers a draft lot to buyers, which turns it available.
class PublishLotUseCase {
  final AdminCatalogRepository repository;

  const PublishLotUseCase({required this.repository});

  /// Throws [ProjectNotPublished] without asking the Web Services while its project is a draft.
  Future<AdminLot> execute(AdminProject project, AdminLot lot) async {
    if (!project.isPublished) throw const ProjectNotPublished();
    return repository.publishLot(lot.id);
  }
}

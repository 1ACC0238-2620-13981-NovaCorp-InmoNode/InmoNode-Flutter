import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';

/// US-52: registers a lot as a draft, with its measures and boundary, in a stage of its project.
class RegisterLotUseCase {
  final AdminCatalogRepository repository;

  const RegisterLotUseCase({required this.repository});

  Future<AdminLot> execute(int projectId, NewLot lot) => repository.registerLot(projectId, lot);
}

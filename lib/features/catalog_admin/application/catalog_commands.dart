import '../domain/admin_catalog.dart';

class CatalogCommands {
  final AdminCatalogRepository repository;
  const CatalogCommands(this.repository);

  Future<AdminProject> createProject(Map<String, dynamic> values) =>
      repository.createProject(values);
  Future<AdminProject> getProject(int id) => repository.getProject(id);
}

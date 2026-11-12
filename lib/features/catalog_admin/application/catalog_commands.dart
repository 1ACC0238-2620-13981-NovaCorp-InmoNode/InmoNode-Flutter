import '../domain/admin_catalog.dart';

class CatalogCommands {
  final AdminCatalogRepository repository;
  const CatalogCommands(this.repository);

  Future<AdminProject> createProject(Map<String, dynamic> values) =>
      repository.createProject(values);
  Future<AdminProject> getProject(int id) => repository.getProject(id);

  Future<List<AdminLot>> getLots(int projectId) =>
      repository.getLots(projectId);

  Future<AdminLot> registerLot(int projectId, Map<String, dynamic> values) {
    final points = values['polygon'] as List<List<List<double>>>;
    if (points.length != 1 ||
        points.first.length < 4 ||
        points.first.first[0] != points.first.last[0] ||
        points.first.first[1] != points.first.last[1]) {
      throw ArgumentError(
        'El polígono necesita al menos tres vértices y debe cerrarse.',
      );
    }
    return repository.registerLot(projectId, values);
  }
}

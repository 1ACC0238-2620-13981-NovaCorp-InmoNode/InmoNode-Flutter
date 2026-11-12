class AdminProject {
  final int id;
  final String name;
  final String status;
  final List<String> stages;

  const AdminProject(this.id, this.name, this.status, this.stages);
}

class AdminLot {
  final int id;
  final String code;
  final String stageName;
  final String status;
  final double price;

  const AdminLot(this.id, this.code, this.stageName, this.status, this.price);
}

abstract class AdminCatalogRepository {
  Future<AdminProject> createProject(Map<String, dynamic> values);
  Future<AdminProject> getProject(int id);
  Future<AdminLot> registerLot(int projectId, Map<String, dynamic> values);
  Future<List<AdminLot>> getLots(int projectId);
  Future<AdminProject> publishProject(int id);
  Future<AdminLot> publishLot(int id);
}

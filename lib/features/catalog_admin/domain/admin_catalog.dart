class AdminProject {
  final int id;
  final String name;
  final String status;
  final List<String> stages;

  const AdminProject(this.id, this.name, this.status, this.stages);
}

abstract class AdminCatalogRepository {
  Future<AdminProject> createProject(Map<String, dynamic> values);
  Future<AdminProject> getProject(int id);
}

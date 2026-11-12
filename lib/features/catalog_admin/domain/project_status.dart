/// Whether buyers can see a project: it is created as a draft and published once it has lots (US-53).
enum ProjectStatus {
  draft('DRAFT'),
  published('PUBLISHED');

  final String apiName;

  const ProjectStatus(this.apiName);

  static ProjectStatus fromApiName(String name) {
    for (final status in values) {
      if (status.apiName == name) return status;
    }
    throw FormatException('Unknown project status: $name');
  }
}

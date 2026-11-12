import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

/// A project as the catalog back-office sees it, drafts included.
class AdminProject {
  final int id;
  final String name;
  final String location;
  final ProjectStatus status;

  /// The stages its lots are registered in.
  final List<String> stages;

  const AdminProject({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.stages,
  });

  bool get isPublished => status == ProjectStatus.published;
}

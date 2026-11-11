import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';

abstract class ProjectRepository {
  /// The published projects, sold-out ones included.
  Future<List<ProjectSummary>> getPublishedProjects();

  Future<Project> getProject(int projectId);

  Future<List<Lot>> getProjectLots(int projectId);
}

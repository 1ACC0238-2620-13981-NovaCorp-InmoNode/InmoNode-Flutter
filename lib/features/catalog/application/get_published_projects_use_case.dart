import 'package:inmonode/features/catalog/domain/project_repository.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';

class GetPublishedProjectsUseCase {
  final ProjectRepository repository;

  const GetPublishedProjectsUseCase({required this.repository});

  Future<List<ProjectSummary>> execute() => repository.getPublishedProjects();
}

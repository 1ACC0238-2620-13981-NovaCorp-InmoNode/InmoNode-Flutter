import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/catalog/domain/project_repository.dart';

typedef ProjectDetail = ({Project project, List<Lot> lots});

/// Loads a project and its lots at the same time.
class GetProjectDetailUseCase {
  final ProjectRepository repository;

  const GetProjectDetailUseCase({required this.repository});

  Future<ProjectDetail> execute(int projectId) async {
    // Future.wait rethrows the first failure as is, so callers still get an ApiException.
    final results = await Future.wait<Object>([
      repository.getProject(projectId),
      repository.getProjectLots(projectId),
    ]);
    return (project: results[0] as Project, lots: results[1] as List<Lot>);
  }
}

import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';

class ProjectsViewModel extends ChangeNotifier {
  static const String unreadableMessage = 'No pudimos mostrar el catálogo. Inténtalo de nuevo en unos minutos.';

  final GetPublishedProjectsUseCase getPublishedProjects;

  ProjectsViewModel({required this.getPublishedProjects});

  List<ProjectSummary> projects = const [];
  bool isLoading = false;
  String? errorMessage;

  /// The catalog arrived at least once; a failed refresh keeps showing it.
  bool hasLoaded = false;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      projects = await getPublishedProjects.execute();
      hasLoaded = true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      // An answer that does not match the expected contract.
      errorMessage = unreadableMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/catalog/presentation/projects_view_model.dart';

class ProjectDetailViewModel extends ChangeNotifier {
  final GetProjectDetailUseCase getProjectDetail;

  ProjectDetailViewModel({required this.getProjectDetail});

  Project? project;

  /// The published lots; drafts are left out.
  List<Lot> lots = const [];
  bool isLoading = false;
  String? errorMessage;

  bool _disposed = false;

  int get availableLots => lots.where((lot) => lot.isAvailable).length;

  Future<void> load(int projectId) async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final detail = await getProjectDetail.execute(projectId);
      project = detail.project;
      lots = [for (final lot in detail.lots) if (lot.status != LotStatus.draft) lot];
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = ProjectsViewModel.unreadableMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

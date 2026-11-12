import 'package:flutter/foundation.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/application/get_project_detail_use_case.dart';
import 'package:inmonode/features/catalog/application/get_published_projects_use_case.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/quotations/domain/quotable_lot.dart';
import 'package:inmonode/features/quotations/presentation/simulation_view_model.dart';

/// Simulador section: the buyer picks a project and one of its available lots, then simulates it.
class SimulatorViewModel extends ChangeNotifier {
  static const String unreadableMessage =
      'No pudimos cargar los lotes disponibles. Inténtalo de nuevo en unos minutos.';

  final GetPublishedProjectsUseCase getPublishedProjects;
  final GetProjectDetailUseCase getProjectDetail;
  final SimulationViewModel Function(QuotableLot lot) createSimulation;

  SimulatorViewModel({
    required this.getPublishedProjects,
    required this.getProjectDetail,
    required this.createSimulation,
  });

  /// Published projects that still have an available lot.
  List<ProjectSummary> projects = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;

  int? selectedProjectId;

  /// Available lots of the selected project.
  List<QuotableLot> lots = const [];
  bool isLoadingLots = false;
  String? lotsErrorMessage;

  QuotableLot? selectedLot;

  /// Simulator of the selected lot.
  SimulationViewModel? simulation;

  bool _disposed = false;

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final published = await getPublishedProjects.execute();
      projects = [for (final project in published) if (project.availableLots > 0) project];
      hasLoaded = true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = unreadableMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProject(int projectId) async {
    if (projectId == selectedProjectId && lotsErrorMessage == null) return;
    selectedProjectId = projectId;
    lots = const [];
    _selectLot(null);
    isLoadingLots = true;
    lotsErrorMessage = null;
    notifyListeners();
    try {
      final detail = await getProjectDetail.execute(projectId);
      // The buyer may have picked another project meanwhile.
      if (selectedProjectId != projectId) return;
      lots = [
        for (final lot in detail.lots)
          if (lot.isAvailable) QuotableLot.of(detail.project, lot),
      ];
    } on ApiException catch (e) {
      if (selectedProjectId == projectId) lotsErrorMessage = e.message;
    } catch (_) {
      if (selectedProjectId == projectId) lotsErrorMessage = unreadableMessage;
    } finally {
      if (selectedProjectId == projectId) {
        isLoadingLots = false;
        notifyListeners();
      }
    }
  }

  void selectLot(int lotId) {
    if (lotId == selectedLot?.lotId) return;
    _selectLot(lots.firstWhere((lot) => lot.lotId == lotId));
    notifyListeners();
  }

  void _selectLot(QuotableLot? lot) {
    simulation?.dispose();
    selectedLot = lot;
    simulation = lot == null ? null : createSimulation(lot);
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    simulation?.dispose();
    super.dispose();
  }
}

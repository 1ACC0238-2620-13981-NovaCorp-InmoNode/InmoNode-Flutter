import 'package:flutter/foundation.dart';
import 'package:inmonode/features/catalog_admin/application/create_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/get_admin_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/publish_lot_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/publish_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/register_lot_use_case.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_labels.dart';

/// The actions of the catalog back-office. Each one answers next to its own button.
enum CatalogAction { createProject, openProject, publishProject, registerLot, publishLot }

/// The answer to the last action.
class CatalogFeedback {
  final CatalogAction action;
  final String message;
  final bool isError;

  /// The lot the answer is about, for [CatalogAction.publishLot].
  final int? lotId;

  const CatalogFeedback(this.action, this.message, {this.isError = false, this.lotId});
}

/// Catalog back-office of `CATALOG_ADMIN`: creates a draft project (US-51), registers its lots (US-52) and
/// publishes both (US-53).
class AdminCatalogViewModel extends ChangeNotifier {
  final CreateProjectUseCase createProject;
  final GetAdminProjectUseCase getProject;
  final RegisterLotUseCase registerLot;
  final PublishProjectUseCase publishProject;
  final PublishLotUseCase publishLot;

  AdminCatalogViewModel({
    required this.createProject,
    required this.getProject,
    required this.registerLot,
    required this.publishProject,
    required this.publishLot,
  });

  /// The project being worked on, with all its lots.
  AdminProject? project;
  List<AdminLot> lots = const [];

  /// The stage new lots are registered in.
  String? stage;

  CatalogFeedback? feedback;

  /// The action waiting for the Web Services. Only one runs at a time.
  CatalogAction? running;

  bool _disposed = false;

  bool get isBusy => running != null;

  /// The answer to show next to [action], if the last action was that one.
  CatalogFeedback? feedbackFor(CatalogAction action, {int? lotId}) {
    final current = feedback;
    return current != null && current.action == action && current.lotId == lotId ? current : null;
  }

  void selectStage(String? value) {
    stage = value;
    notifyListeners();
  }

  /// Answers [action] when its form still has fields to correct.
  void reportInvalidForm(CatalogAction action) {
    feedback = CatalogFeedback(action, AdminCatalogLabels.invalidForm, isError: true);
    notifyListeners();
  }

  /// Whether the project was created, so that its form can be cleared.
  Future<bool> submitProject(NewProject newProject) {
    return _run(CatalogAction.createProject, () async {
      final created = await createProject.execute(newProject);
      project = created;
      lots = const [];
      stage = created.stages.firstOrNull;
      return 'Proyecto «${created.name}» creado como borrador con el ID ${created.id}. '
          'Registra sus lotes y luego publícalo.';
    });
  }

  /// The back-office has no list of draft projects, so one is opened by its ID.
  Future<void> openProject(int projectId) async {
    await _run(CatalogAction.openProject, () async {
      await _reload(projectId);
      return null;
    });
  }

  /// Whether the lot was registered, so that its form can be cleared.
  Future<bool> submitLot(NewLot lot) async {
    final selected = project;
    if (selected == null) return false;
    return _run(CatalogAction.registerLot, () async {
      await registerLot.execute(selected.id, lot);
      await _reload(selected.id);
      return 'Lote ${lot.code} registrado como borrador en la etapa ${lot.stageName}.';
    });
  }

  Future<void> publishSelectedProject() async {
    final selected = project;
    if (selected == null) return;
    await _run(CatalogAction.publishProject, () async {
      await publishProject.execute((project: selected, lots: lots));
      await _reload(selected.id);
      return 'Proyecto publicado. Ahora publica los lotes que quieras ofrecer.';
    });
  }

  Future<void> publishDraftLot(AdminLot lot) async {
    final selected = project;
    if (selected == null) return;
    await _run(CatalogAction.publishLot, () async {
      await publishLot.execute(selected, lot);
      await _reload(selected.id);
      return 'Lote ${lot.code} publicado: ya figura como disponible.';
    }, lotId: lot.id);
  }

  Future<void> _reload(int projectId) async {
    final detail = await getProject.execute(projectId);
    // The chosen stage stays while the same project is reloaded.
    if (project?.id != detail.project.id || !detail.project.stages.contains(stage)) {
      stage = detail.project.stages.firstOrNull;
    }
    project = detail.project;
    lots = detail.lots;
  }

  /// Runs [action] unless another one is running, and keeps its answer: the message [body] returns, if
  /// any, or why it failed.
  Future<bool> _run(CatalogAction action, Future<String?> Function() body, {int? lotId}) async {
    if (isBusy) return false;
    running = action;
    feedback = null;
    notifyListeners();
    try {
      final message = await body();
      feedback = message == null ? null : CatalogFeedback(action, message, lotId: lotId);
      return true;
    } catch (error) {
      feedback = CatalogFeedback(action, AdminCatalogLabels.failure(error), isError: true, lotId: lotId);
      return false;
    } finally {
      running = null;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

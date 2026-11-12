import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/presentation/catalog_labels.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

/// Texts of the catalog back-office: statuses and why an action failed.
class AdminCatalogLabels {
  static const String invalidForm = 'Revisa los campos marcados.';
  static const String unexpected = 'No se pudo completar la operación. Inténtalo de nuevo.';

  static String projectStatus(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.draft => 'Borrador',
      ProjectStatus.published => 'Publicado',
    };
  }

  /// Buyers never see drafts, so the back-office names them on its own.
  static String lotStatus(LotStatus status) {
    return status == LotStatus.draft ? 'Borrador' : CatalogLabels.lotStatus(status);
  }

  static String rejection(CatalogRejection rejection) {
    return switch (rejection) {
      ProjectNotFound(:final projectId) => 'No existe un proyecto con el ID $projectId.',
      LotNotFound() => 'Ese lote ya no existe. Vuelve a cargar el proyecto.',
      ProjectWithoutLots() => 'Registra al menos un lote antes de publicar el proyecto.',
      ProjectNotPublished() => 'Publica el proyecto antes de publicar sus lotes.',
      LotCodeTaken(:final code) => 'Ya existe un lote con el código $code en este proyecto.',
      StageNotInProject() => 'La etapa elegida no pertenece a este proyecto.',
      RepeatedStages() => 'Las etapas deben tener nombres distintos.',
      InvalidLotBoundary(problem: BoundaryProblem.selfIntersecting) =>
        'El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.',
      InvalidLotBoundary(problem: BoundaryProblem.outOfRange) =>
        'Cada vértice debe tener una longitud entre -180 y 180 y una latitud entre -90 y 90.',
      InvalidLotBoundary(problem: BoundaryProblem.tooFewVertices) =>
        'El polígono necesita al menos tres vértices distintos.',
    };
  }

  /// What to tell the administrator about a failed action.
  static String failure(Object error) {
    if (error is CatalogRejection) return rejection(error);
    if (error is ApiException) {
      if (error.code == 'FORBIDDEN') return 'Tu cuenta no puede administrar el catálogo.';
      // Any other broken rule comes with its reason in English, which is not shown.
      if (error.code == 'VALIDATION_ERROR' || error.code == 'BUSINESS_RULE_VIOLATION') {
        return 'El servidor rechazó los datos. Revisa el formulario e inténtalo de nuevo.';
      }
      return error.message;
    }
    return unexpected;
  }
}

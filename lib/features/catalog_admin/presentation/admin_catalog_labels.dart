import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/presentation/catalog_labels.dart';

/// Texts of the catalog back-office: the statuses of projects and lots, and the rejections of the Web
/// Services, whose `details` arrive in English.
class AdminCatalogLabels {
  static String projectStatus(String status) {
    return switch (status) {
      'DRAFT' => 'Borrador',
      'PUBLISHED' => 'Publicado',
      _ => status,
    };
  }

  static String lotStatus(String status) {
    if (status == LotStatus.draft.apiName) return 'Borrador';
    try {
      return CatalogLabels.lotStatus(LotStatus.fromApiName(status));
    } on FormatException {
      return status;
    }
  }

  /// Why the Web Services turned an operation down. [lotCode] and [projectId] name what was asked for.
  static String rejection(
    ApiException error, {
    String? lotCode,
    int? projectId,
  }) {
    switch (error.code) {
      case 'LOT_CONFLICT':
        return lotCode == null || lotCode.isEmpty
            ? 'Ya existe un lote con ese código en este proyecto.'
            : 'Ya existe un lote con el código $lotCode en este proyecto.';
      case 'PROJECT_NOT_FOUND':
        return projectId == null
            ? 'No existe ese proyecto.'
            : 'No existe un proyecto con el ID $projectId.';
      case 'LOT_NOT_FOUND':
        return 'Ese lote ya no existe. Vuelve a cargar el proyecto.';
      case 'FORBIDDEN':
        return 'Tu cuenta no puede administrar el catálogo.';
    }
    final details = error.details ?? '';
    for (final (fragment, message) in _knownDetails) {
      if (details.contains(fragment)) return message;
    }
    if (error.code == 'VALIDATION_ERROR' ||
        error.code == 'BUSINESS_RULE_VIOLATION') {
      return 'El servidor rechazó los datos. Revisa el formulario e inténtalo de nuevo.';
    }
    return error.message;
  }

  static const List<(String, String)> _knownDetails = [
    (
      'at least one lot',
      'Registra al menos un lote antes de publicar el proyecto.',
    ),
    (
      'Publish the project before',
      'Publica el proyecto antes de publicar sus lotes.',
    ),
    (
      'stageName does not belong',
      'La etapa elegida no pertenece a este proyecto.',
    ),
    ('stage names must be unique', 'Las etapas deben tener nombres distintos.'),
    (
      'crosses itself or has no area',
      'El polígono se cruza consigo mismo o no tiene área. Revisa el orden de los vértices.',
    ),
    (
      'within range',
      'Cada vértice debe tener una longitud entre -180 y 180 y una latitud entre -90 y 90.',
    ),
    (
      'needs at least',
      'El polígono necesita al menos tres vértices distintos.',
    ),
    ('latitude and longitude', 'Ingresa la latitud y la longitud juntas.'),
  ];
}

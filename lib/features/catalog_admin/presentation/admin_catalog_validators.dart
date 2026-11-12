import 'package:inmonode/core/formatting/formats.dart';
import 'package:inmonode/features/catalog_admin/domain/lot_boundary.dart';

/// Field rules of the catalog back-office forms, aligned with the limits of the `/catalog` Web Services.
class AdminCatalogValidators {
  static const int maxNameLength = 150;
  static const int maxLocationLength = 255;
  static const int maxCoverImageUrlLength = 500;
  static const int maxStages = 50;
  static const int maxStageLength = 80;
  static const int maxLotCodeLength = 30;
  static const int maxTermMonths = 360;

  static String? requiredText(String? value, {required int maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Completa este campo';
    return text.length > maxLength ? 'Usa hasta $maxLength caracteres' : null;
  }

  static String? optionalText(String? value, {required int maxLength}) {
    return (value?.trim() ?? '').length > maxLength ? 'Usa hasta $maxLength caracteres' : null;
  }

  /// A decimal written with a point, as `12.5`; null when it is empty or cannot be read.
  static double? parseDecimal(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number != null && number.isFinite ? number : null;
  }

  static String? decimal(String? value, {bool required = true, double? min, double? max, bool positive = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'Completa este campo' : null;
    final number = parseDecimal(text);
    if (number == null) return 'Ingresa un número con punto decimal, por ejemplo 12.5';
    if (positive && number <= 0) return 'Debe ser mayor que cero';
    if (min != null && max != null && (number < min || number > max)) {
      return 'Debe estar entre ${_plain(min)} y ${_plain(max)}';
    }
    return null;
  }

  static String? percentage(String? value) => decimal(value, min: 0, max: 100);

  /// The position of a project is optional, but it needs both coordinates.
  static String? latitude(String? value, {required String longitude}) {
    return _coordinate(value, limit: 90, other: longitude, missing: 'Ingresa también la latitud');
  }

  static String? longitude(String? value, {required String latitude}) {
    return _coordinate(value, limit: 180, other: latitude, missing: 'Ingresa también la longitud');
  }

  static String? _coordinate(String? value, {required double limit, required String other, required String missing}) {
    if ((value?.trim() ?? '').isEmpty) return other.trim().isEmpty ? null : missing;
    return decimal(value, min: -limit, max: limit);
  }

  static int? parseMonths(String? value) => int.tryParse(value?.trim() ?? '');

  static String? months(String? value) {
    final months = parseMonths(value);
    if (months == null || months < 1 || months > maxTermMonths) {
      return 'Ingresa un número entero de meses entre 1 y $maxTermMonths';
    }
    return null;
  }

  static List<String> parseStages(String? value) {
    return [
      for (final name in (value ?? '').split(','))
        if (name.trim().isNotEmpty) name.trim(),
    ];
  }

  static String? stages(String? value) {
    final stages = parseStages(value);
    if (stages.isEmpty) return 'Escribe al menos una etapa, por ejemplo: Norte, Sur';
    if (stages.length > maxStages) return 'Un proyecto admite hasta $maxStages etapas';
    final seen = <String>{};
    for (final stage in stages) {
      if (stage.length > maxStageLength) return 'La etapa «$stage» supera los $maxStageLength caracteres';
      if (!seen.add(stage.toLowerCase())) return 'La etapa «$stage» está repetida';
    }
    return null;
  }

  /// Prices are written as the app shows them: `45000` or `45,000.50`.
  static String? price(String? value) {
    final price = Formats.parseAmount(value ?? '');
    return price == null || price <= 0 ? 'Ingresa el precio en soles, por ejemplo 45000 o 45,000.50' : null;
  }

  static int? parseProjectId(String? value) => int.tryParse(value?.trim() ?? '');

  static String? projectId(String? value) {
    final id = parseProjectId(value);
    return id == null || id <= 0 ? 'Ingresa el ID numérico del proyecto, por ejemplo 12' : null;
  }

  /// The boundary written with one `longitude,latitude` vertex per line, or null while it has a mistake.
  static LotBoundary? parseBoundary(String? value) => _readBoundary(value).boundary;

  static String? boundary(String? value) => _readBoundary(value).error;

  static ({LotBoundary? boundary, String? error}) _readBoundary(String? value) {
    final lines = [
      for (final line in (value ?? '').split('\n'))
        if (line.trim().isNotEmpty) line.trim(),
    ];
    final vertices = <Vertex>[];
    for (final (index, line) in lines.indexed) {
      final parts = line.split(',');
      final longitude = parts.length == 2 ? parseDecimal(parts[0]) : null;
      final latitude = parts.length == 2 ? parseDecimal(parts[1]) : null;
      if (longitude == null || latitude == null) {
        return (
          boundary: null,
          error: 'La línea ${index + 1} debe ser longitud,latitud, por ejemplo -77.0428,-12.0464',
        );
      }
      if (longitude.abs() > 180 || latitude.abs() > 90) {
        return (
          boundary: null,
          error: 'La línea ${index + 1} está fuera de rango: la longitud va de -180 a 180 y la latitud de -90 a 90',
        );
      }
      vertices.add((longitude: longitude, latitude: latitude));
    }
    // A last vertex that repeats the first one only closes the polygon.
    final distinct = vertices.length > 1 && vertices.first == vertices.last ? vertices.length - 1 : vertices.length;
    if (distinct < LotBoundary.minVertices) {
      return (boundary: null, error: 'Ingresa al menos ${LotBoundary.minVertices} vértices, uno por línea');
    }
    return (boundary: LotBoundary(vertices), error: null);
  }

  static String _plain(double value) => value == value.roundToDouble() ? '${value.toInt()}' : '$value';
}

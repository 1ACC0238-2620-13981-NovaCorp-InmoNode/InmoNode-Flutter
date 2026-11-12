import 'package:inmonode/features/catalog_admin/domain/lot_boundary.dart';

/// A lot to register as a draft in a stage of its project (US-52).
class NewLot {
  final String code;
  final String stageName;

  /// Square meters.
  final double area;

  /// Meters; only regular lots have them.
  final double? front;
  final double? depth;
  final double price;
  final LotBoundary boundary;

  const NewLot({
    required this.code,
    required this.stageName,
    required this.area,
    this.front,
    this.depth,
    required this.price,
    required this.boundary,
  });
}

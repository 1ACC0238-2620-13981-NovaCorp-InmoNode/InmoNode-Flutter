import 'package:inmonode/features/catalog/domain/price_range.dart';

/// A published project as the catalog card shows it (US-15).
class ProjectSummary {
  final int id;
  final String name;
  final String location;
  final String? coverImageUrl;

  /// `null` while the project has no lots.
  final PriceRange? priceRange;
  final int totalLots;

  /// Share of lots still available, from 0 to 100.
  final double availabilityPercentage;

  /// Every lot is sold. The project stays in the catalog with a "Vendido totalmente" label (US-15, Scenario 2).
  final bool soldOut;

  const ProjectSummary({
    required this.id,
    required this.name,
    required this.location,
    this.coverImageUrl,
    this.priceRange,
    required this.totalLots,
    required this.availabilityPercentage,
    required this.soldOut,
  });

  int get availableLots => (totalLots * availabilityPercentage / 100).round();
}

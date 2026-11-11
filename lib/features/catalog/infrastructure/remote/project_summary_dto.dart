/// Card of `GET /projects`. Prices and percentages arrive as JSON numbers.
class ProjectSummaryDto {
  final int id;
  final String name;
  final String location;
  final String? coverImageUrl;
  final PriceRangeDto? priceRange;
  final int totalLots;
  final double availabilityPercentage;
  final bool soldOut;

  const ProjectSummaryDto({
    required this.id,
    required this.name,
    required this.location,
    required this.coverImageUrl,
    required this.priceRange,
    required this.totalLots,
    required this.availabilityPercentage,
    required this.soldOut,
  });

  factory ProjectSummaryDto.fromJson(Map<String, dynamic> json) {
    final priceRange = json['priceRange'];
    return ProjectSummaryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      priceRange: priceRange == null ? null : PriceRangeDto.fromJson(priceRange as Map<String, dynamic>),
      totalLots: json['totalLots'] as int,
      availabilityPercentage: (json['availabilityPercentage'] as num).toDouble(),
      soldOut: json['soldOut'] as bool,
    );
  }
}

class PriceRangeDto {
  final double min;
  final double max;
  final String currency;

  const PriceRangeDto({required this.min, required this.max, required this.currency});

  factory PriceRangeDto.fromJson(Map<String, dynamic> json) {
    return PriceRangeDto(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}

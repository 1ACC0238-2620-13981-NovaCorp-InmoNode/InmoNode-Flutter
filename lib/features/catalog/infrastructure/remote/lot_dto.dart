/// One feature of the GeoJSON `FeatureCollection` of `GET /projects/{projectId}/lots`.
///
/// Only the lot data is read; the polygon is for the map of US-16.
class LotDto {
  final int id;
  final String code;
  final double area;
  final double? front;
  final double? depth;
  final double price;
  final String currency;
  final String status;

  const LotDto({
    required this.id,
    required this.code,
    required this.area,
    required this.front,
    required this.depth,
    required this.price,
    required this.currency,
    required this.status,
  });

  factory LotDto.fromFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    return LotDto(
      id: feature['id'] as int,
      code: properties['code'] as String,
      area: (properties['area'] as num).toDouble(),
      front: (properties['front'] as num?)?.toDouble(),
      depth: (properties['depth'] as num?)?.toDouble(),
      price: (properties['price'] as num).toDouble(),
      currency: properties['currency'] as String? ?? 'PEN',
      status: properties['status'] as String,
    );
  }
}

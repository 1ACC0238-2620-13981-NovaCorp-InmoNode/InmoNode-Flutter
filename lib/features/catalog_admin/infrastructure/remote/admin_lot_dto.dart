/// A lot of the back-office (`CatalogLotResource`), drafts included.
class AdminLotDto {
  final int id;
  final String code;
  final String stageName;
  final String status;
  final double area;
  final double price;
  final String currency;

  const AdminLotDto({
    required this.id,
    required this.code,
    required this.stageName,
    required this.status,
    required this.area,
    required this.price,
    required this.currency,
  });

  factory AdminLotDto.fromJson(Map<String, dynamic> json) {
    return AdminLotDto(
      id: json['id'] as int,
      code: json['code'] as String,
      stageName: json['stageName'] as String,
      status: json['status'] as String,
      area: (json['area'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'PEN',
    );
  }
}

/// Body of `POST /catalog/projects/{id}/lots`. The polygon is a GeoJSON ring of `[longitude, latitude]`
/// positions whose last one repeats the first.
class RegisterLotRequestDto {
  final String code;
  final String stageName;
  final double area;
  final double? front;
  final double? depth;
  final double price;
  final List<List<double>> ring;

  const RegisterLotRequestDto({
    required this.code,
    required this.stageName,
    required this.area,
    required this.front,
    required this.depth,
    required this.price,
    required this.ring,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'stageName': stageName,
      'area': area,
      'front': ?front,
      'depth': ?depth,
      'price': price,
      'polygon': [ring],
    };
  }
}

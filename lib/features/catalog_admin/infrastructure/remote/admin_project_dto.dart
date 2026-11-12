/// A project of `POST /catalog/projects`, `PUT /catalog/projects/{id}/publish` and `GET /projects/{id}`.
class AdminProjectDto {
  final int id;
  final String name;
  final String location;
  final String status;
  final List<String> stages;

  const AdminProjectDto({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.stages,
  });

  factory AdminProjectDto.fromJson(Map<String, dynamic> json) {
    return AdminProjectDto(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      stages: [for (final stage in json['stages'] as List<dynamic>? ?? const []) stage as String],
    );
  }
}

/// Body of `POST /catalog/projects`. Rates and percentages go as percentages: 12.5 means 12.5 %.
class CreateProjectRequestDto {
  final String name;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? coverImageUrl;
  final double minDownPaymentPercentage;
  final double annualInterestRate;
  final int maxTermMonths;
  final double lateFeeRate;
  final List<String> stages;

  const CreateProjectRequestDto({
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.coverImageUrl,
    required this.minDownPaymentPercentage,
    required this.annualInterestRate,
    required this.maxTermMonths,
    required this.lateFeeRate,
    required this.stages,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'coverImageUrl': ?coverImageUrl,
      'financingRules': {
        'minDownPaymentPercentage': minDownPaymentPercentage,
        'annualInterestRate': annualInterestRate,
        'maxTermMonths': maxTermMonths,
        'lateFeeRate': lateFeeRate,
      },
      'stages': stages,
    };
  }
}

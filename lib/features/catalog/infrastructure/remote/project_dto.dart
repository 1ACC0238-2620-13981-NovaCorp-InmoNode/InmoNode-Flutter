/// `GET /projects/{projectId}`: the project with its financing rules.
class ProjectDto {
  final int id;
  final String name;
  final String location;
  final String? coverImageUrl;
  final FinancingRulesDto financingRules;
  final List<String> stages;

  const ProjectDto({
    required this.id,
    required this.name,
    required this.location,
    required this.coverImageUrl,
    required this.financingRules,
    required this.stages,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      financingRules: FinancingRulesDto.fromJson(json['financingRules'] as Map<String, dynamic>),
      stages: [for (final stage in json['stages'] as List<dynamic>? ?? const []) stage as String],
    );
  }
}

class FinancingRulesDto {
  final double minDownPaymentPercentage;
  final double annualInterestRate;
  final int maxTermMonths;
  final double lateFeeRate;

  const FinancingRulesDto({
    required this.minDownPaymentPercentage,
    required this.annualInterestRate,
    required this.maxTermMonths,
    required this.lateFeeRate,
  });

  factory FinancingRulesDto.fromJson(Map<String, dynamic> json) {
    return FinancingRulesDto(
      minDownPaymentPercentage: (json['minDownPaymentPercentage'] as num).toDouble(),
      annualInterestRate: (json['annualInterestRate'] as num).toDouble(),
      maxTermMonths: json['maxTermMonths'] as int,
      lateFeeRate: (json['lateFeeRate'] as num).toDouble(),
    );
  }
}

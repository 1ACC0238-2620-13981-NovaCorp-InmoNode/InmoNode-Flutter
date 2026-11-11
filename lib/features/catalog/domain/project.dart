import 'package:inmonode/features/catalog/domain/financing_rules.dart';

/// A published project with its financing conditions and stages.
class Project {
  final int id;
  final String name;
  final String location;
  final String? coverImageUrl;
  final FinancingRules financingRules;
  final List<String> stages;

  const Project({
    required this.id,
    required this.name,
    required this.location,
    this.coverImageUrl,
    required this.financingRules,
    required this.stages,
  });
}

import 'package:inmonode/features/catalog/domain/financing_rules.dart';

/// A project to create as a draft (US-51), with the financing rules its lots will be sold under.
class NewProject {
  final String name;
  final String location;

  /// The map position of the project; both or neither.
  final double? latitude;
  final double? longitude;
  final String? coverImageUrl;
  final FinancingRules financingRules;
  final List<String> stages;

  NewProject({
    required this.name,
    required this.location,
    this.latitude,
    this.longitude,
    this.coverImageUrl,
    required this.financingRules,
    required this.stages,
  }) {
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError('The latitude and the longitude of a project go together');
    }
  }
}

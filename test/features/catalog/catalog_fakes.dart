import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/price_range.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/catalog/domain/project_repository.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';

ProjectSummary testSummary({
  int id = 1,
  String name = 'Villa del Sol',
  int totalLots = 30,
  double availabilityPercentage = 40,
  bool soldOut = false,
  PriceRange? priceRange = const PriceRange(min: 35000, max: 80000, currency: 'PEN'),
}) {
  return ProjectSummary(
    id: id,
    name: name,
    location: 'Carabayllo, Lima',
    priceRange: priceRange,
    totalLots: totalLots,
    availabilityPercentage: availabilityPercentage,
    soldOut: soldOut,
  );
}

ProjectSummary soldOutSummary({int id = 2}) {
  return testSummary(id: id, name: 'Los Olivos II', totalLots: 12, availabilityPercentage: 0, soldOut: true);
}

Project testProject({int id = 1, List<String> stages = const ['Etapa 1', 'Etapa 2']}) {
  return Project(
    id: id,
    name: 'Villa del Sol',
    location: 'Carabayllo, Lima',
    financingRules: const FinancingRules(
      minDownPaymentPercentage: 10,
      annualInterestRate: 12.5,
      maxTermMonths: 60,
      lateFeeRate: 1,
    ),
    stages: stages,
  );
}

Lot testLot({int id = 1, String code = 'A-01', LotStatus status = LotStatus.available}) {
  return Lot(
    id: id,
    code: code,
    area: 120,
    front: 8,
    depth: 15,
    price: 45000,
    currency: 'PEN',
    status: status,
  );
}

class FakeProjectRepository implements ProjectRepository {
  Future<List<ProjectSummary>> Function()? onGetPublished;
  Future<Project> Function(int projectId)? onGetProject;
  Future<List<Lot>> Function(int projectId)? onGetLots;

  int publishedCalls = 0;

  @override
  Future<List<ProjectSummary>> getPublishedProjects() {
    publishedCalls++;
    return onGetPublished!();
  }

  @override
  Future<Project> getProject(int projectId) => onGetProject!(projectId);

  @override
  Future<List<Lot>> getProjectLots(int projectId) => onGetLots!(projectId);
}

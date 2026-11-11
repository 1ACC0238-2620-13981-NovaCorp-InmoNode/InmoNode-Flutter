import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/price_range.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/catalog/domain/project_repository.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/lot_dto.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_api.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_dto.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_summary_dto.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectApi api;

  const ProjectRepositoryImpl({required this.api});

  @override
  Future<List<ProjectSummary>> getPublishedProjects() async {
    return [for (final dto in await api.getPublished()) _toSummary(dto)];
  }

  @override
  Future<Project> getProject(int projectId) async => _toProject(await api.getById(projectId));

  @override
  Future<List<Lot>> getProjectLots(int projectId) async {
    return [for (final dto in await api.getLots(projectId)) _toLot(dto)];
  }

  ProjectSummary _toSummary(ProjectSummaryDto dto) {
    final priceRange = dto.priceRange;
    return ProjectSummary(
      id: dto.id,
      name: dto.name,
      location: dto.location,
      coverImageUrl: dto.coverImageUrl,
      priceRange: priceRange == null
          ? null
          : PriceRange(min: priceRange.min, max: priceRange.max, currency: priceRange.currency),
      totalLots: dto.totalLots,
      availabilityPercentage: dto.availabilityPercentage,
      soldOut: dto.soldOut,
    );
  }

  Project _toProject(ProjectDto dto) {
    final rules = dto.financingRules;
    return Project(
      id: dto.id,
      name: dto.name,
      location: dto.location,
      coverImageUrl: dto.coverImageUrl,
      financingRules: FinancingRules(
        minDownPaymentPercentage: rules.minDownPaymentPercentage,
        annualInterestRate: rules.annualInterestRate,
        maxTermMonths: rules.maxTermMonths,
        lateFeeRate: rules.lateFeeRate,
      ),
      stages: dto.stages,
    );
  }

  Lot _toLot(LotDto dto) {
    return Lot(
      id: dto.id,
      code: dto.code,
      area: dto.area,
      front: dto.front,
      depth: dto.depth,
      price: dto.price,
      currency: dto.currency,
      status: LotStatus.fromApiName(dto.status),
    );
  }
}

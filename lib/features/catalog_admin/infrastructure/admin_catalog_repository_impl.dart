import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/remote/admin_catalog_api.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/remote/admin_lot_dto.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/remote/admin_project_dto.dart';

class AdminCatalogRepositoryImpl implements AdminCatalogRepository {
  // The Web Services explain a broken rule in `details`, in English, under a generic code such as
  // VALIDATION_ERROR or BUSINESS_RULE_VIOLATION.
  static const List<(String, CatalogRejection)> _rulesInDetails = [
    ('at least one lot', ProjectWithoutLots()),
    ('Publish the project before', ProjectNotPublished()),
    ('stageName does not belong', StageNotInProject()),
    ('stage names must be unique', RepeatedStages()),
    ('crosses itself or has no area', InvalidLotBoundary(BoundaryProblem.selfIntersecting)),
    ('within range', InvalidLotBoundary(BoundaryProblem.outOfRange)),
    ('needs at least', InvalidLotBoundary(BoundaryProblem.tooFewVertices)),
  ];

  final AdminCatalogApi api;

  const AdminCatalogRepositoryImpl({required this.api});

  @override
  Future<AdminProject> createProject(NewProject project) {
    return _guard(() async => _toProject(await api.createProject(_toProjectRequest(project))));
  }

  @override
  Future<AdminProject> getProject(int projectId) {
    return _guard(() async => _toProject(await api.getProject(projectId)), projectId: projectId);
  }

  @override
  Future<List<AdminLot>> getProjectLots(int projectId) {
    return _guard(() async => [for (final dto in await api.getLots(projectId)) _toLot(dto)], projectId: projectId);
  }

  @override
  Future<AdminLot> registerLot(int projectId, NewLot lot) {
    return _guard(
      () async => _toLot(await api.registerLot(projectId, _toLotRequest(lot))),
      projectId: projectId,
      lotCode: lot.code,
    );
  }

  @override
  Future<AdminProject> publishProject(int projectId) {
    return _guard(() async => _toProject(await api.publishProject(projectId)), projectId: projectId);
  }

  @override
  Future<AdminLot> publishLot(int lotId) => _guard(() async => _toLot(await api.publishLot(lotId)));

  /// Turns the rejections the domain knows into a [CatalogRejection]; any other failure goes on as is.
  Future<T> _guard<T>(Future<T> Function() request, {int? projectId, String? lotCode}) async {
    try {
      return await request();
    } on ApiException catch (e) {
      final rejection = _toRejection(e, projectId: projectId, lotCode: lotCode);
      if (rejection == null) rethrow;
      throw rejection;
    }
  }

  CatalogRejection? _toRejection(ApiException error, {int? projectId, String? lotCode}) {
    if (error.code == 'PROJECT_NOT_FOUND' && projectId != null) return ProjectNotFound(projectId);
    if (error.code == 'LOT_NOT_FOUND') return const LotNotFound();
    // Registering a lot only conflicts on its code; elsewhere LOT_CONFLICT means the lot is taken.
    if (error.code == 'LOT_CONFLICT' && lotCode != null) return LotCodeTaken(lotCode);
    final details = error.details;
    if (details == null) return null;
    for (final (fragment, rejection) in _rulesInDetails) {
      if (details.contains(fragment)) return rejection;
    }
    return null;
  }

  CreateProjectRequestDto _toProjectRequest(NewProject project) {
    final rules = project.financingRules;
    return CreateProjectRequestDto(
      name: project.name,
      location: project.location,
      latitude: project.latitude,
      longitude: project.longitude,
      coverImageUrl: project.coverImageUrl,
      minDownPaymentPercentage: rules.minDownPaymentPercentage,
      annualInterestRate: rules.annualInterestRate,
      maxTermMonths: rules.maxTermMonths,
      lateFeeRate: rules.lateFeeRate,
      stages: project.stages,
    );
  }

  RegisterLotRequestDto _toLotRequest(NewLot lot) {
    return RegisterLotRequestDto(
      code: lot.code,
      stageName: lot.stageName,
      area: lot.area,
      front: lot.front,
      depth: lot.depth,
      price: lot.price,
      ring: [
        for (final vertex in lot.boundary.ring) [vertex.longitude, vertex.latitude],
      ],
    );
  }

  AdminProject _toProject(AdminProjectDto dto) {
    return AdminProject(
      id: dto.id,
      name: dto.name,
      location: dto.location,
      status: ProjectStatus.fromApiName(dto.status),
      stages: dto.stages,
    );
  }

  AdminLot _toLot(AdminLotDto dto) {
    return AdminLot(
      id: dto.id,
      code: dto.code,
      stageName: dto.stageName,
      area: dto.area,
      price: dto.price,
      currency: dto.currency,
      status: LotStatus.fromApiName(dto.status),
    );
  }
}

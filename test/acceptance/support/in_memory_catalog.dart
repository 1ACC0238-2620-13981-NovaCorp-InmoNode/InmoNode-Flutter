import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/domain/price_range.dart';
import 'package:inmonode/features/catalog/domain/project.dart';
import 'package:inmonode/features/catalog/domain/project_repository.dart';
import 'package:inmonode/features/catalog/domain/project_summary.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/domain/lot_boundary.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';

/// The `/catalog` Web Services kept in memory with their rules. The administrator and the buyers share
/// it, so a lot the back-office publishes is the lot the buyer's catalog shows.
class InMemoryCatalog {
  static const String currency = 'PEN';

  static const FinancingRules standardRules = FinancingRules(
    minDownPaymentPercentage: 10,
    annualInterestRate: 12.5,
    maxTermMonths: 60,
    lateFeeRate: 1.5,
  );

  final List<StoredProject> projects = [];
  final List<StoredLot> lots = [];

  int _nextProjectId = 1;
  int _nextLotId = 1;

  late final AdminCatalogRepository admin = _AdminCatalog(this);
  late final ProjectRepository buyers = _BuyerCatalog(this);

  StoredProject? projectNamed(String name) => projects.where((project) => project.name == name).firstOrNull;

  StoredLot? lotCoded(String code) => lots.where((lot) => lot.code == code).firstOrNull;

  List<StoredLot> lotsOf(int projectId) => [
    for (final lot in lots)
      if (lot.projectId == projectId) lot,
  ];

  StoredProject addProject({
    required String name,
    String location = 'Carabayllo, Lima',
    List<String> stages = const ['Norte', 'Sur'],
    FinancingRules rules = standardRules,
    ProjectStatus status = ProjectStatus.draft,
  }) {
    final project = StoredProject(
      id: _nextProjectId++,
      name: name,
      location: location,
      stages: List.unmodifiable(stages),
      rules: rules,
      status: status,
    );
    projects.add(project);
    return project;
  }

  StoredLot addLot(
    StoredProject project, {
    required String code,
    required double price,
    String? stageName,
    double area = 120,
    double? front,
    double? depth,
    LotBoundary? boundary,
    LotStatus status = LotStatus.draft,
  }) {
    final lot = StoredLot(
      id: _nextLotId++,
      projectId: project.id,
      code: code,
      stageName: stageName ?? project.stages.first,
      area: area,
      front: front,
      depth: depth,
      price: price,
      boundary: boundary ?? squareBoundary,
      status: status,
    );
    lots.add(lot);
    return lot;
  }

  /// A lot of about 11 m by 11 m in Lima.
  static final LotBoundary squareBoundary = LotBoundary(const [
    (longitude: -77.0428, latitude: -12.0464),
    (longitude: -77.0427, latitude: -12.0464),
    (longitude: -77.0427, latitude: -12.0465),
    (longitude: -77.0428, latitude: -12.0465),
  ]);

  StoredProject _project(int projectId) {
    return projects.where((project) => project.id == projectId).firstOrNull ?? (throw ProjectNotFound(projectId));
  }
}

class StoredProject {
  final int id;
  final String name;
  final String location;
  final List<String> stages;
  final FinancingRules rules;
  ProjectStatus status;

  StoredProject({
    required this.id,
    required this.name,
    required this.location,
    required this.stages,
    required this.rules,
    required this.status,
  });

  bool get isPublished => status == ProjectStatus.published;

  AdminProject toAdmin() => AdminProject(id: id, name: name, location: location, status: status, stages: stages);

  Project toProject() => Project(id: id, name: name, location: location, financingRules: rules, stages: stages);
}

class StoredLot {
  final int id;
  final int projectId;
  final String code;
  final String stageName;
  final double area;
  final double? front;
  final double? depth;
  final double price;
  final LotBoundary boundary;
  LotStatus status;

  StoredLot({
    required this.id,
    required this.projectId,
    required this.code,
    required this.stageName,
    required this.area,
    this.front,
    this.depth,
    required this.price,
    required this.boundary,
    required this.status,
  });

  AdminLot toAdmin() => AdminLot(
    id: id,
    code: code,
    stageName: stageName,
    area: area,
    price: price,
    currency: InMemoryCatalog.currency,
    status: status,
  );

  Lot toLot() => Lot(
    id: id,
    code: code,
    area: area,
    front: front,
    depth: depth,
    price: price,
    currency: InMemoryCatalog.currency,
    status: status,
  );
}

/// The back-office endpoints, as `CATALOG_ADMIN`.
class _AdminCatalog implements AdminCatalogRepository {
  final InMemoryCatalog catalog;

  _AdminCatalog(this.catalog);

  @override
  Future<AdminProject> createProject(NewProject project) async {
    final names = {for (final stage in project.stages) stage.toLowerCase()};
    if (names.length != project.stages.length) throw const RepeatedStages();
    return catalog
        .addProject(
          name: project.name,
          location: project.location,
          stages: project.stages,
          rules: project.financingRules,
        )
        .toAdmin();
  }

  @override
  Future<AdminProject> getProject(int projectId) async => catalog._project(projectId).toAdmin();

  @override
  Future<List<AdminLot>> getProjectLots(int projectId) async {
    catalog._project(projectId);
    return [for (final lot in catalog.lotsOf(projectId)) lot.toAdmin()];
  }

  @override
  Future<AdminLot> registerLot(int projectId, NewLot lot) async {
    final project = catalog._project(projectId);
    if (!project.stages.contains(lot.stageName)) throw const StageNotInProject();
    final code = lot.code.toLowerCase();
    if (catalog.lotsOf(projectId).any((other) => other.code.toLowerCase() == code)) throw LotCodeTaken(lot.code);
    final problem = boundaryProblem(lot.boundary);
    if (problem != null) throw InvalidLotBoundary(problem);
    return catalog
        .addLot(
          project,
          code: lot.code,
          price: lot.price,
          stageName: lot.stageName,
          area: lot.area,
          front: lot.front,
          depth: lot.depth,
          boundary: lot.boundary,
        )
        .toAdmin();
  }

  @override
  Future<AdminProject> publishProject(int projectId) async {
    final project = catalog._project(projectId);
    if (catalog.lotsOf(projectId).isEmpty) throw const ProjectWithoutLots();
    project.status = ProjectStatus.published;
    return project.toAdmin();
  }

  @override
  Future<AdminLot> publishLot(int lotId) async {
    final lot = catalog.lots.where((lot) => lot.id == lotId).firstOrNull ?? (throw const LotNotFound());
    if (!catalog._project(lot.projectId).isPublished) throw const ProjectNotPublished();
    if (lot.status == LotStatus.draft) lot.status = LotStatus.available;
    return lot.toAdmin();
  }
}

/// The public catalog of the buyers: published projects, and their lots except the drafts.
class _BuyerCatalog implements ProjectRepository {
  final InMemoryCatalog catalog;

  _BuyerCatalog(this.catalog);

  @override
  Future<List<ProjectSummary>> getPublishedProjects() async {
    final published = [
      for (final project in catalog.projects)
        if (project.isPublished) project,
    ]..sort((a, b) => a.name.compareTo(b.name));
    return [for (final project in published) _summary(project)];
  }

  @override
  Future<Project> getProject(int projectId) async => _published(projectId).toProject();

  @override
  Future<List<Lot>> getProjectLots(int projectId) async {
    _published(projectId);
    return [for (final lot in _offered(projectId)) lot.toLot()];
  }

  StoredProject _published(int projectId) {
    final project = catalog.projects.where((project) => project.id == projectId && project.isPublished).firstOrNull;
    return project ??
        (throw const ApiException(statusCode: 404, code: 'PROJECT_NOT_FOUND', message: 'El proyecto no existe'));
  }

  List<StoredLot> _offered(int projectId) => [
    for (final lot in catalog.lotsOf(projectId))
      if (lot.status != LotStatus.draft) lot,
  ];

  /// The figures of `LotStatistics` in the Web Services, which leave the drafts out.
  ProjectSummary _summary(StoredProject project) {
    final lots = _offered(project.id);
    final available = lots.where((lot) => lot.status == LotStatus.available).length;
    final sold = lots.where((lot) => lot.status == LotStatus.sold).length;
    final prices = [for (final lot in lots) lot.price]..sort();
    return ProjectSummary(
      id: project.id,
      name: project.name,
      location: project.location,
      priceRange: prices.isEmpty
          ? null
          : PriceRange(min: prices.first, max: prices.last, currency: InMemoryCatalog.currency),
      totalLots: lots.length,
      availabilityPercentage: lots.isEmpty ? 0 : (available * 10000 / lots.length).round() / 100,
      soldOut: lots.isNotEmpty && sold == lots.length,
    );
  }
}

/// Why the Web Services reject a lot boundary, if they do: fewer than three distinct vertices, a vertex out
/// of range, or edges that cross each other or enclose no area.
BoundaryProblem? boundaryProblem(LotBoundary boundary) {
  final vertices = boundary.vertices;
  if (vertices.toSet().length < LotBoundary.minVertices) return BoundaryProblem.tooFewVertices;
  if (vertices.any((vertex) => vertex.longitude.abs() > 180 || vertex.latitude.abs() > 90)) {
    return BoundaryProblem.outOfRange;
  }
  final ring = boundary.ring;
  final edges = vertices.length;
  // Shoelace formula, relative to the first vertex so that large coordinates do not swamp small lots.
  final origin = ring.first;
  var doubleArea = 0.0;
  for (var i = 0; i < edges; i++) {
    final (x1, y1) = (ring[i].longitude - origin.longitude, ring[i].latitude - origin.latitude);
    final (x2, y2) = (ring[i + 1].longitude - origin.longitude, ring[i + 1].latitude - origin.latitude);
    doubleArea += x1 * y2 - x2 * y1;
  }
  if (doubleArea.abs() < 1e-12) return BoundaryProblem.selfIntersecting;
  for (var i = 0; i < edges; i++) {
    for (var j = i + 1; j < edges; j++) {
      final adjacent = j == i + 1 || (i == 0 && j == edges - 1);
      if (!adjacent && _cross(ring[i], ring[i + 1], ring[j], ring[j + 1])) return BoundaryProblem.selfIntersecting;
    }
  }
  return null;
}

bool _cross(Vertex a, Vertex b, Vertex c, Vertex d) {
  double side(Vertex p, Vertex q, Vertex r) =>
      (q.longitude - p.longitude) * (r.latitude - p.latitude) - (q.latitude - p.latitude) * (r.longitude - p.longitude);
  final abc = side(a, b, c);
  final abd = side(a, b, d);
  final cda = side(c, d, a);
  final cdb = side(c, d, b);
  return (abc > 0) != (abd > 0) && (cda > 0) != (cdb > 0) && abc != 0 && abd != 0 && cda != 0 && cdb != 0;
}

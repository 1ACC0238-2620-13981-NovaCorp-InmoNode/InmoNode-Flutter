import 'dart:async';

import 'package:inmonode/features/catalog/domain/financing_rules.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog_admin/application/create_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/get_admin_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/publish_lot_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/publish_project_use_case.dart';
import 'package:inmonode/features/catalog_admin/application/register_lot_use_case.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_catalog_repository.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/admin_project.dart';
import 'package:inmonode/features/catalog_admin/domain/lot_boundary.dart';
import 'package:inmonode/features/catalog_admin/domain/new_lot.dart';
import 'package:inmonode/features/catalog_admin/domain/new_project.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';
import 'package:inmonode/features/catalog_admin/presentation/admin_catalog_view_model.dart';

/// The view model wired as in the app, over [repository].
AdminCatalogViewModel adminCatalogViewModel(AdminCatalogRepository repository) {
  return AdminCatalogViewModel(
    createProject: CreateProjectUseCase(repository: repository),
    getProject: GetAdminProjectUseCase(repository: repository),
    registerLot: RegisterLotUseCase(repository: repository),
    publishProject: PublishProjectUseCase(repository: repository),
    publishLot: PublishLotUseCase(repository: repository),
  );
}

/// Draft project 5, Los Pinos, with the stages Norte and Sur.
AdminProject testAdminProject({int id = 5, ProjectStatus status = ProjectStatus.draft}) {
  return AdminProject(
    id: id,
    name: 'Los Pinos',
    location: 'Lurín, Lima',
    status: status,
    stages: const ['Norte', 'Sur'],
  );
}

/// Draft lot 9, N-01 of the stage Norte: 120 m² for S/ 45,000.00.
AdminLot testAdminLot({int id = 9, String code = 'N-01', String stage = 'Norte', LotStatus status = LotStatus.draft}) {
  return AdminLot(id: id, code: code, stageName: stage, area: 120, price: 45000, currency: 'PEN', status: status);
}

NewProject testNewProject() {
  return NewProject(
    name: 'Los Pinos',
    location: 'Lurín, Lima',
    financingRules: const FinancingRules(
      minDownPaymentPercentage: 10,
      annualInterestRate: 12.5,
      maxTermMonths: 60,
      lateFeeRate: 1.5,
    ),
    stages: const ['Norte', 'Sur'],
  );
}

NewLot testNewLot({String code = 'N-01', String stage = 'Norte'}) {
  return NewLot(
    code: code,
    stageName: stage,
    area: 120,
    price: 45000,
    boundary: LotBoundary(const [
      (longitude: -77.0, latitude: -12.0),
      (longitude: -77.1, latitude: -12.0),
      (longitude: -77.1, latitude: -12.1),
    ]),
  );
}

/// Back-office catalog kept in memory, which records what is sent to it.
class FakeAdminCatalogRepository implements AdminCatalogRepository {
  AdminProject project = testAdminProject();
  List<AdminLot> lots = [];

  /// Fails the next call with this error, if any.
  Object? failure;

  /// Holds every answer until it completes, if any.
  Completer<void>? gate;

  final List<NewProject> createdProjects = [];
  final List<NewLot> registeredLots = [];
  final List<int> publishedProjects = [];
  final List<int> publishedLots = [];

  Future<T> _answer<T>(T Function() value) async {
    await gate?.future;
    final error = failure;
    if (error != null) {
      failure = null;
      throw error;
    }
    return value();
  }

  @override
  Future<AdminProject> createProject(NewProject newProject) => _answer(() {
    createdProjects.add(newProject);
    return project;
  });

  @override
  Future<AdminProject> getProject(int projectId) => _answer(() => project);

  @override
  Future<List<AdminLot>> getProjectLots(int projectId) => _answer(() => List.of(lots));

  @override
  Future<AdminLot> registerLot(int projectId, NewLot lot) => _answer(() {
    registeredLots.add(lot);
    final registered = AdminLot(
      id: 10 + lots.length,
      code: lot.code,
      stageName: lot.stageName,
      area: lot.area,
      price: lot.price,
      currency: 'PEN',
      status: LotStatus.draft,
    );
    lots.add(registered);
    return registered;
  });

  @override
  Future<AdminProject> publishProject(int projectId) => _answer(() {
    publishedProjects.add(projectId);
    return project = testAdminProject(id: project.id, status: ProjectStatus.published);
  });

  @override
  Future<AdminLot> publishLot(int lotId) => _answer(() {
    publishedLots.add(lotId);
    final index = lots.indexWhere((lot) => lot.id == lotId);
    final lot = lots[index];
    return lots[index] = testAdminLot(id: lot.id, code: lot.code, stage: lot.stageName, status: LotStatus.available);
  });
}

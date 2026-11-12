import 'dart:async';

import 'package:inmonode/features/catalog_admin/domain/admin_catalog.dart';

const AdminProject draftProject = AdminProject(5, 'Los Pinos', 'DRAFT', ['Norte', 'Sur']);

AdminLot draftLot({int id = 9, String code = 'N-01', String stage = 'Norte', String status = 'DRAFT'}) {
  return AdminLot(id, code, stage, status, 45000);
}

/// Back-office catalog kept in memory, which records what the page sends.
class FakeAdminCatalogRepository implements AdminCatalogRepository {
  AdminProject project = draftProject;
  List<AdminLot> lots = [];

  /// Fails the next call with this error, if any.
  Object? failure;

  /// Holds every answer until it completes, if any.
  Completer<void>? gate;

  final List<Map<String, dynamic>> createdProjects = [];
  final List<Map<String, dynamic>> registeredLots = [];
  final List<int> publishedLots = [];
  int publishedProjects = 0;

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
  Future<AdminProject> createProject(Map<String, dynamic> values) => _answer(() {
    createdProjects.add(values);
    return project;
  });

  @override
  Future<AdminProject> getProject(int id) => _answer(() => project);

  @override
  Future<List<AdminLot>> getLots(int projectId) => _answer(() => List.of(lots));

  @override
  Future<AdminLot> registerLot(int projectId, Map<String, dynamic> values) => _answer(() {
    registeredLots.add(values);
    final lot = draftLot(id: 10 + lots.length, code: values['code'] as String, stage: values['stageName'] as String);
    lots.add(lot);
    return lot;
  });

  @override
  Future<AdminProject> publishProject(int id) => _answer(() {
    publishedProjects++;
    return project = AdminProject(project.id, project.name, 'PUBLISHED', project.stages);
  });

  @override
  Future<AdminLot> publishLot(int id) => _answer(() {
    publishedLots.add(id);
    final index = lots.indexWhere((lot) => lot.id == id);
    final lot = lots[index];
    return lots[index] = AdminLot(lot.id, lot.code, lot.stageName, 'AVAILABLE', lot.price);
  });
}

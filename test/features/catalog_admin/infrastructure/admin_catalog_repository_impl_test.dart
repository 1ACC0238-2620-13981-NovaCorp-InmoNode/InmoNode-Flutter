import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/core/network/authorized_client.dart';
import 'package:inmonode/core/network/token_provider.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog_admin/domain/catalog_rejection.dart';
import 'package:inmonode/features/catalog_admin/domain/project_status.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/admin_catalog_repository_impl.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/remote/admin_catalog_api.dart';

import '../catalog_admin_fakes.dart';

class _Tokens implements TokenProvider {
  @override
  Future<String?> accessToken() async => 'test-token';

  @override
  Future<bool> refresh() async => false;
}

/// `ProjectResource`, as the Web Services answer it.
Map<String, Object?> projectJson({String status = 'DRAFT'}) {
  return {
    'id': 5,
    'name': 'Los Pinos',
    'location': 'Lurín, Lima',
    'latitude': null,
    'longitude': null,
    'coverImageUrl': null,
    'financingRules': {
      'minDownPaymentPercentage': 10.00,
      'annualInterestRate': 12.5000,
      'maxTermMonths': 60,
      'lateFeeRate': 1.50,
    },
    'status': status,
    'stages': ['Norte', 'Sur'],
  };
}

/// `CatalogLotResource`, as the Web Services answer it.
Map<String, Object?> lotJson({String status = 'DRAFT'}) {
  return {
    'id': 9,
    'projectId': 5,
    'stageName': 'Norte',
    'code': 'N-01',
    'status': status,
    'area': 120.00,
    'front': null,
    'depth': null,
    'price': 45000.00,
    'currency': 'PEN',
    'geometry': {
      'type': 'Polygon',
      'coordinates': [
        [
          [-77.0, -12.0],
          [-77.1, -12.0],
          [-77.1, -12.1],
          [-77.0, -12.0],
        ],
      ],
    },
  };
}

void main() {
  late List<http.Request> calls;
  late Map<String, http.Response> answers;
  late AdminCatalogRepositoryImpl repository;

  http.Response json(Object body, [int statusCode = 200]) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), statusCode);
  }

  http.Response error(int statusCode, String code, String message, [String? details]) {
    return json({'code': code, 'message': message, 'details': details}, statusCode);
  }

  setUp(() {
    calls = [];
    answers = {};
    final client = AuthorizedClient(
      tokenProvider: _Tokens(),
      inner: MockClient((request) async {
        calls.add(request);
        return answers['${request.method} ${request.url.path}'] ?? http.Response('', 500);
      }),
    );
    repository = AdminCatalogRepositoryImpl(api: AdminCatalogApi(client: client));
  });

  test('US-51 creates a draft with its stages and financing rules', () async {
    answers['POST /api/v1/catalog/projects'] = json(projectJson(), 201);

    final project = await repository.createProject(testNewProject());

    final sent = calls.single;
    expect(sent.headers['Authorization'], 'Bearer test-token');
    expect(jsonDecode(sent.body), {
      'name': 'Los Pinos',
      'location': 'Lurín, Lima',
      'financingRules': {
        'minDownPaymentPercentage': 10,
        'annualInterestRate': 12.5,
        'maxTermMonths': 60,
        'lateFeeRate': 1.5,
      },
      'stages': ['Norte', 'Sur'],
    });
    expect(project.status, ProjectStatus.draft);
    expect(project.stages, ['Norte', 'Sur']);
  });

  test('reads a draft project through the endpoint that shows drafts to the back-office', () async {
    answers['GET /api/v1/projects/5'] = json(projectJson());

    final project = await repository.getProject(5);

    expect(project.name, 'Los Pinos');
    expect(calls.single.headers['Authorization'], 'Bearer test-token');
  });

  test('US-52 registers a draft lot with a closed ring and lists the lots', () async {
    answers['POST /api/v1/catalog/projects/5/lots'] = json(lotJson(), 201);
    answers['GET /api/v1/catalog/projects/5/lots'] = json([lotJson()]);

    final registered = await repository.registerLot(5, testNewLot());
    final lots = await repository.getProjectLots(5);

    expect(jsonDecode(calls.first.body), {
      'code': 'N-01',
      'stageName': 'Norte',
      'area': 120,
      'price': 45000,
      'polygon': [
        [
          [-77.0, -12.0],
          [-77.1, -12.0],
          [-77.1, -12.1],
          [-77.0, -12.0],
        ],
      ],
    });
    expect(registered.status, LotStatus.draft);
    expect(lots.single.price, 45000);
    expect(
      [for (final call in calls) '${call.method} ${call.url.path}'],
      ['POST /api/v1/catalog/projects/5/lots', 'GET /api/v1/catalog/projects/5/lots'],
    );
  });

  test('US-53 publishes a project and then its draft lot', () async {
    answers['PUT /api/v1/catalog/projects/5/publish'] = json(projectJson(status: 'PUBLISHED'));
    answers['PUT /api/v1/catalog/lots/9/publish'] = json(lotJson(status: 'AVAILABLE'));

    final project = await repository.publishProject(5);
    final lot = await repository.publishLot(9);

    expect(project.isPublished, isTrue);
    expect(lot.status, LotStatus.available);
    expect(calls.every((call) => call.headers['Authorization'] == 'Bearer test-token'), isTrue);
  });

  test('turns the rules the Web Services explain in English into rejections', () async {
    answers['POST /api/v1/catalog/projects/5/lots'] = error(
      409,
      'LOT_CONFLICT',
      'El lote ya no está disponible; elige otro lote',
      'the code is already used in this project',
    );
    answers['PUT /api/v1/catalog/projects/5/publish'] = error(
      422,
      'BUSINESS_RULE_VIOLATION',
      'Violación de regla de negocio',
      'A project can be published only once it has at least one lot',
    );
    answers['GET /api/v1/projects/99'] = error(404, 'PROJECT_NOT_FOUND', 'Recurso no encontrado');

    await expectLater(
      repository.registerLot(5, testNewLot()),
      throwsA(isA<LotCodeTaken>().having((rejection) => rejection.code, 'code', 'N-01')),
    );
    await expectLater(repository.publishProject(5), throwsA(isA<ProjectWithoutLots>()));
    await expectLater(
      repository.getProject(99),
      throwsA(isA<ProjectNotFound>().having((rejection) => rejection.projectId, 'projectId', 99)),
    );
  });

  test('names what is wrong with a boundary', () async {
    answers['POST /api/v1/catalog/projects/5/lots'] = error(
      400,
      'VALIDATION_ERROR',
      'Validación fallida',
      'the boundary polygon crosses itself or has no area',
    );

    await expectLater(
      repository.registerLot(5, testNewLot()),
      throwsA(isA<InvalidLotBoundary>().having((r) => r.problem, 'problem', BoundaryProblem.selfIntersecting)),
    );
  });

  test('lets other failures through as they came', () async {
    answers['POST /api/v1/catalog/projects'] = error(
      400,
      'VALIDATION_ERROR',
      'Validación fallida',
      'Field name: must not be blank',
    );

    await expectLater(
      repository.createProject(testNewProject()),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'VALIDATION_ERROR')),
    );
  });
}

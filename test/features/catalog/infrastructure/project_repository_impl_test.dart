import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/catalog/domain/lot.dart';
import 'package:inmonode/features/catalog/infrastructure/project_repository_impl.dart';
import 'package:inmonode/features/catalog/infrastructure/remote/project_api.dart';

/// The Web Services answer UTF-8 JSON without a charset in the content type.
http.Response jsonResponse(Object body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  late List<http.Request> requests;

  ProjectRepositoryImpl repositoryAnswering(http.Response Function(http.Request) answer) {
    requests = [];
    return ProjectRepositoryImpl(
      api: ProjectApi(
        client: MockClient((request) async {
          requests.add(request);
          return answer(request);
        }),
      ),
    );
  }

  test('lists the published projects with their price range and availability', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse([
        {
          'id': 1,
          'name': 'Villa del Sol',
          'location': 'Carabayllo, Lima',
          'latitude': -11.85,
          'longitude': -77.03,
          'coverImageUrl': 'https://cdn.test/villa.jpg',
          'priceRange': {'min': 35000.00, 'max': 80000.50, 'currency': 'PEN'},
          'totalLots': 30,
          'availabilityPercentage': 66.67,
          'soldOut': false,
        },
        {
          'id': 2,
          'name': 'Los Olivos II',
          'location': 'Los Olivos, Lima',
          'latitude': null,
          'longitude': null,
          'coverImageUrl': null,
          'priceRange': null,
          'totalLots': 0,
          'availabilityPercentage': 0,
          'soldOut': false,
        },
      ], 200),
    );

    final projects = await repository.getPublishedProjects();

    final request = requests.single;
    expect(request.method, 'GET');
    expect(request.url.toString(), '${ApiConstants.baseUrl}/projects');
    expect(request.headers['Accept-Language'], 'es');
    // Without a content type, browsers send the request without a CORS preflight.
    expect(request.headers.containsKey('Content-Type'), isFalse);

    final villa = projects.first;
    expect(villa.name, 'Villa del Sol');
    expect(villa.coverImageUrl, 'https://cdn.test/villa.jpg');
    expect(villa.priceRange?.min, 35000);
    expect(villa.priceRange?.max, 80000.5);
    expect(villa.availabilityPercentage, 66.67);
    expect(villa.availableLots, 20);
    expect(projects.last.priceRange, isNull);
    expect(projects.last.coverImageUrl, isNull);
  });

  test('keeps a sold-out project in the catalog', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse([
        {
          'id': 3,
          'name': 'Las Lomas',
          'location': 'Lurín, Lima',
          'coverImageUrl': null,
          'priceRange': {'min': 40000, 'max': 40000, 'currency': 'PEN'},
          'totalLots': 12,
          'availabilityPercentage': 0.00,
          'soldOut': true,
        },
      ], 200),
    );

    final project = (await repository.getPublishedProjects()).single;

    expect(project.soldOut, isTrue);
    expect(project.availableLots, 0);
    expect(project.location, 'Lurín, Lima');
  });

  test('reads the financing rules and stages of a project', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({
        'id': 1,
        'name': 'Villa del Sol',
        'location': 'Carabayllo, Lima',
        'latitude': -11.85,
        'longitude': -77.03,
        'coverImageUrl': null,
        'financingRules': {
          'minDownPaymentPercentage': 10.00,
          'annualInterestRate': 12.50,
          'maxTermMonths': 60,
          'lateFeeRate': 1.00,
        },
        'status': 'PUBLISHED',
        'stages': ['Etapa 1', 'Etapa 2'],
      }, 200),
    );

    final project = await repository.getProject(1);

    expect(requests.single.url.toString(), '${ApiConstants.baseUrl}/projects/1');
    expect(project.financingRules.minDownPaymentPercentage, 10);
    expect(project.financingRules.annualInterestRate, 12.5);
    expect(project.financingRules.maxTermMonths, 60);
    expect(project.stages, ['Etapa 1', 'Etapa 2']);
  });

  test('reads the lots from the GeoJSON features of the plan', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'id': 11,
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [-77.03, -11.85],
                  [-77.02, -11.85],
                  [-77.02, -11.84],
                  [-77.03, -11.85],
                ],
              ],
            },
            'properties': {
              'code': 'A-01',
              'area': 120.00,
              'front': 8.00,
              'depth': 15.00,
              'price': 45000.00,
              'currency': 'PEN',
              'status': 'AVAILABLE',
            },
          },
          {
            'type': 'Feature',
            'id': 12,
            'geometry': null,
            'properties': {
              'code': 'A-02',
              'area': 98.75,
              'front': null,
              'depth': null,
              'price': 39000,
              'currency': 'PEN',
              'status': 'PENDING_VERIFICATION',
            },
          },
        ],
      }, 200),
    );

    final lots = await repository.getProjectLots(1);

    expect(requests.single.url.toString(), '${ApiConstants.baseUrl}/projects/1/lots');
    expect(lots.first.id, 11);
    expect(lots.first.code, 'A-01');
    expect(lots.first.front, 8);
    expect(lots.first.status, LotStatus.available);
    expect(lots.last.front, isNull);
    expect(lots.last.area, 98.75);
    expect(lots.last.status, LotStatus.pendingVerification);
  });

  test('reports a project that is not published with the server message', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({'code': 'PROJECT_NOT_FOUND', 'message': 'No se encontró el proyecto'}, 404),
    );

    await expectLater(
      repository.getProject(99),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.message, 'message', 'No se encontró el proyecto'),
      ),
    );
  });
}

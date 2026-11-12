import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inmonode/core/network/authorized_client.dart';
import 'package:inmonode/core/network/token_provider.dart';
import 'package:inmonode/features/catalog_admin/infrastructure/admin_catalog_repository_impl.dart';

class _Tokens implements TokenProvider {
  @override
  Future<String?> accessToken() async => 'test-token';
  @override
  Future<bool> refresh() async => false;
}

void main() {
  test('US-51 creates a draft with stages and financing rules', () async {
    late http.Request sent;
    final client = AuthorizedClient(
      tokenProvider: _Tokens(),
      inner: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'id': 5,
            'name': 'Los Pinos',
            'status': 'DRAFT',
            'stages': ['Norte'],
          }),
          201,
        );
      }),
    );
    final result = await AdminCatalogRepositoryImpl(client).createProject({
      'name': 'Los Pinos',
      'location': 'Lima',
      'stages': ['Norte'],
      'financingRules': {
        'minDownPaymentPercentage': 20,
        'annualInterestRate': 12,
        'maxTermMonths': 120,
        'lateFeeRate': 1.5,
      },
    });
    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/v1/catalog/projects');
    expect(sent.headers['Authorization'], 'Bearer test-token');
    expect((jsonDecode(sent.body) as Map<String, dynamic>)['stages'], [
      'Norte',
    ]);
    expect(result.status, 'DRAFT');
  });

  test('US-52 registers a draft lot and lists it', () async {
    final calls = <http.Request>[];
    final client = AuthorizedClient(
      tokenProvider: _Tokens(),
      inner: MockClient((request) async {
        calls.add(request);
        final lot = {
          'id': 9,
          'code': 'N-01',
          'stageName': 'Norte',
          'status': 'DRAFT',
          'price': 45000,
        };
        return http.Response(
          jsonEncode(request.method == 'POST' ? lot : [lot]),
          request.method == 'POST' ? 201 : 200,
        );
      }),
    );
    final repo = AdminCatalogRepositoryImpl(client);
    final polygon = [
      [
        [-77.0, -12.0],
        [-77.1, -12.0],
        [-77.1, -12.1],
        [-77.0, -12.0],
      ],
    ];
    final created = await repo.registerLot(5, {
      'code': 'N-01',
      'stageName': 'Norte',
      'area': 120,
      'price': 45000,
      'polygon': polygon,
    });
    final listed = await repo.getLots(5);
    expect(created.status, 'DRAFT');
    expect(listed.single.id, 9);
    expect(calls.map((r) => '${r.method} ${r.url.path}').toList(), [
      'POST /api/v1/catalog/projects/5/lots',
      'GET /api/v1/catalog/projects/5/lots',
    ]);
    expect(
      (jsonDecode(calls.first.body) as Map<String, dynamic>)['polygon'],
      polygon,
    );
  });

  test('US-53 publishes a project before its draft lot', () async {
    final calls = <http.Request>[];
    final client = AuthorizedClient(
      tokenProvider: _Tokens(),
      inner: MockClient((request) async {
        calls.add(request);
        if (request.url.path.endsWith('/projects/5/publish')) {
          return http.Response(
            jsonEncode({
              'id': 5,
              'name': 'Los Pinos',
              'status': 'PUBLISHED',
              'stages': ['Norte'],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'id': 9,
            'code': 'N-01',
            'stageName': 'Norte',
            'status': 'AVAILABLE',
            'price': 45000,
          }),
          200,
        );
      }),
    );
    final repo = AdminCatalogRepositoryImpl(client);
    final project = await repo.publishProject(5);
    final lot = await repo.publishLot(9);
    expect(project.status, 'PUBLISHED');
    expect(lot.status, 'AVAILABLE');
    expect(calls.map((r) => '${r.method} ${r.url.path}').toList(), [
      'PUT /api/v1/catalog/projects/5/publish',
      'PUT /api/v1/catalog/lots/9/publish',
    ]);
    expect(
      calls.every((r) => r.headers['Authorization'] == 'Bearer test-token'),
      isTrue,
    );
  });
}

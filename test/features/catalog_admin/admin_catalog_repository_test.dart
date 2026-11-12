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
}

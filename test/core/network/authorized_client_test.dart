import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inmonode/core/network/authorized_client.dart';
import 'package:inmonode/core/network/token_provider.dart';

class FakeTokenProvider implements TokenProvider {
  String? token;
  String? renewedToken;
  int refreshCalls = 0;

  FakeTokenProvider({this.token, this.renewedToken});

  @override
  Future<String?> accessToken() async => token;

  @override
  Future<bool> refresh() async {
    refreshCalls++;
    if (renewedToken == null) return false;
    token = renewedToken;
    return true;
  }
}

void main() {
  final uri = Uri.parse('https://api.test/lots/1/quotations');
  late List<http.Request> requests;

  AuthorizedClient clientAnswering(TokenProvider tokens, int Function(http.Request) status) {
    requests = [];
    return AuthorizedClient(
      tokenProvider: tokens,
      inner: MockClient((request) async {
        requests.add(request);
        return http.Response('{}', status(request));
      }),
    );
  }

  test('sends the access token and asks for Spanish messages', () async {
    final client = clientAnswering(FakeTokenProvider(token: 'access-1'), (_) => 200);

    await client.get(uri);

    expect(requests.single.headers['Authorization'], 'Bearer access-1');
    expect(requests.single.headers['Accept-Language'], 'es');
  });

  test('renews the session once and repeats a request answered with 401', () async {
    final tokens = FakeTokenProvider(token: 'access-1', renewedToken: 'access-2');
    final client = clientAnswering(
      tokens,
      (request) => request.headers['Authorization'] == 'Bearer access-2' ? 201 : 401,
    );

    final response = await client.post(uri, body: jsonEncode({'downPayment': 5000}));

    expect(response.statusCode, 201);
    expect(tokens.refreshCalls, 1);
    expect(requests, hasLength(2));
    expect(jsonDecode(requests.last.body), {'downPayment': 5000});
  });

  test('returns the 401 when the session can no longer be renewed', () async {
    final tokens = FakeTokenProvider(token: 'access-1');
    final client = clientAnswering(tokens, (_) => 401);

    final response = await client.get(uri);

    expect(response.statusCode, 401);
    expect(requests, hasLength(1));
  });

  test('sends public requests without a token and does not try to renew', () async {
    final tokens = FakeTokenProvider();
    final client = clientAnswering(tokens, (_) => 401);

    await client.get(uri);

    expect(requests.single.headers.containsKey('Authorization'), isFalse);
    expect(tokens.refreshCalls, 0);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/domain/account.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';
import 'package:inmonode/features/iam/infrastructure/auth_repository_impl.dart';
import 'package:inmonode/features/iam/infrastructure/remote/auth_api.dart';

import 'jwt_test_tokens.dart';

/// The Web Services answer UTF-8 JSON without a charset in the content type.
http.Response jsonResponse(Object body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  final now = DateTime.utc(2026, 11, 11, 12);
  late List<http.Request> requests;

  AuthRepositoryImpl repositoryAnswering(http.Response Function(http.Request) answer) {
    requests = [];
    final client = MockClient((request) async {
      requests.add(request);
      return answer(request);
    });
    return AuthRepositoryImpl(api: AuthApi(client: client), now: () => now);
  }

  test('registers a buyer whose account stays inactive until verified', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({'id': 7, 'email': 'ana@mail.com', 'role': 'BUYER', 'status': 'INACTIVE'}, 201),
    );

    final account = await repository.register('ana@mail.com', 'secret123');

    expect(account.status, AccountStatus.inactive);
    expect(account.role, UserRole.buyer);
    final request = requests.single;
    expect(request.url.toString(), '${ApiConstants.baseUrl}/auth/register');
    expect(jsonDecode(request.body), {'email': 'ana@mail.com', 'password': 'secret123'});
    expect(request.headers['Accept-Language'], 'es');
  });

  test('rejects an email that is already registered with the server message', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({
        'code': 'USER_CONFLICT',
        'message': 'El correo ya está registrado; usa la recuperación de contraseña',
      }, 409),
    );

    await expectLater(
      repository.register('ana@mail.com', 'secret123'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.code, 'code', 'USER_CONFLICT')
            .having((e) => e.message, 'message', contains('recuperación de contraseña')),
      ),
    );
  });

  test('activates the account with the token of the link', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({'id': 7, 'email': 'ana@mail.com', 'role': 'BUYER', 'status': 'ACTIVE'}, 200),
    );

    final account = await repository.verifyEmail('token-123');

    expect(account.status, AccountStatus.active);
    expect(jsonDecode(requests.single.body), {'token': 'token-123'});
  });

  test('builds the session from the tokens and the JWT claims', () async {
    final jwt = testJwt(role: 'CATALOG_ADMIN');
    final repository = repositoryAnswering(
      (_) => jsonResponse({
        'token': jwt,
        'tokenType': 'Bearer',
        'expiresIn': 3600,
        'refreshToken': 'refresh-1',
      }, 200),
    );

    final session = await repository.signIn('ana@mail.com', 'secret123');

    expect(session.accessToken, jwt);
    expect(session.refreshToken, 'refresh-1');
    expect(session.userId, 7);
    expect(session.role, UserRole.catalogAdmin);
    expect(session.expiresAt, now.add(const Duration(hours: 1)));
  });

  test('reports an account that has not been verified', () async {
    final repository = repositoryAnswering(
      (_) => jsonResponse({'code': 'ACCOUNT_INACTIVE', 'message': 'Cuenta no activa'}, 403),
    );

    await expectLater(
      repository.signIn('ana@mail.com', 'secret123'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'ACCOUNT_INACTIVE')),
    );
  });

  test('reports a connection failure as a network error', () async {
    final repository = AuthRepositoryImpl(
      api: AuthApi(client: MockClient((_) async => throw http.ClientException('offline'))),
    );

    await expectLater(
      repository.signIn('ana@mail.com', 'secret123'),
      throwsA(isA<ApiException>().having((e) => e.isNetworkError, 'isNetworkError', isTrue)),
    );
  });

  test('uses a generic message when the error is not an error resource', () async {
    final repository = repositoryAnswering((_) => http.Response('<html>Bad Gateway</html>', 502));

    await expectLater(
      repository.resendVerification('ana@mail.com'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'HTTP_502')),
    );
  });
}

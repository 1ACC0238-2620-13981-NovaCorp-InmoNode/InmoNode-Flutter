import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/application/session_token_provider.dart';
import 'package:inmonode/features/iam/domain/session.dart';

import '../iam_fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late InMemorySessionRepository sessions;
  late int sessionsEnded;
  late SessionTokenProvider provider;

  setUp(() {
    auth = FakeAuthRepository();
    sessions = InMemorySessionRepository();
    sessionsEnded = 0;
    provider = SessionTokenProvider(
      sessionRepository: sessions,
      refreshSession: RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions),
      onSessionEnded: () => sessionsEnded++,
      now: () => fixedNow,
    );
  });

  test('gives no token when nobody is signed in', () async {
    expect(await provider.accessToken(), isNull);
  });

  test('gives the access token of a valid session', () async {
    sessions.session = testSession(accessToken: 'access-1');

    expect(await provider.accessToken(), 'access-1');
    expect(auth.refreshedTokens, isEmpty);
  });

  test('renews an expired access token before giving it', () async {
    sessions.session = testSession(expiresAt: fixedNow.subtract(const Duration(seconds: 1)));
    auth.onRefresh = (_) async => testSession(accessToken: 'access-2', refreshToken: 'refresh-2');

    expect(await provider.accessToken(), 'access-2');
  });

  test('concurrent renewals share a single use of the refresh token', () async {
    sessions.session = testSession(refreshToken: 'refresh-1');
    final response = Completer<Session>();
    auth.onRefresh = (_) => response.future;

    final first = provider.refresh();
    final second = provider.refresh();
    response.complete(testSession(accessToken: 'access-2', refreshToken: 'refresh-2'));

    expect(await Future.wait([first, second]), [true, true]);
    expect(auth.refreshedTokens, ['refresh-1']);
  });

  test('ends the session when it can no longer be renewed', () async {
    sessions.session = testSession();
    auth.onRefresh = (_) async => throw apiError(401, 'INVALID_REFRESH_TOKEN');

    expect(await provider.refresh(), isFalse);
    expect(sessionsEnded, 1);
    expect(sessions.session, isNull);
  });

  test('keeps the session when the server cannot be reached', () async {
    sessions.session = testSession();
    auth.onRefresh = (_) async => throw apiError(503, 'HTTP_503');

    expect(await provider.refresh(), isFalse);
    expect(sessionsEnded, 0);
    expect(sessions.session, isNotNull);
  });
}

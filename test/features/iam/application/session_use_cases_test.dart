import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/core/network/api_exception.dart';
import 'package:inmonode/features/iam/application/refresh_session_use_case.dart';
import 'package:inmonode/features/iam/application/restore_session_use_case.dart';
import 'package:inmonode/features/iam/application/sign_in_use_case.dart';
import 'package:inmonode/features/iam/application/sign_out_use_case.dart';

import '../iam_fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late InMemorySessionRepository sessions;

  setUp(() {
    auth = FakeAuthRepository();
    sessions = InMemorySessionRepository();
  });

  group('SignInUseCase', () {
    test('keeps the session it obtains', () async {
      final session = testSession();
      auth.onSignIn = (_, _) async => session;

      final result = await SignInUseCase(authRepository: auth, sessionRepository: sessions)
          .execute('  ana@mail.com ', 'secret123');

      expect(result, same(session));
      expect(sessions.session, same(session));
      expect(auth.signedInEmails, ['ana@mail.com']);
    });

    test('keeps nothing when the credentials are rejected', () async {
      auth.onSignIn = (_, _) async => throw apiError(401, 'INVALID_CREDENTIALS');

      final signIn = SignInUseCase(authRepository: auth, sessionRepository: sessions);

      await expectLater(signIn.execute('ana@mail.com', 'wrong-pass'), throwsA(isA<ApiException>()));
      expect(sessions.session, isNull);
    });
  });

  group('SignOutUseCase', () {
    test('revokes the refresh token and clears the session', () async {
      sessions.session = testSession(refreshToken: 'refresh-9');

      await SignOutUseCase(authRepository: auth, sessionRepository: sessions).execute();

      expect(auth.signedOutTokens, ['refresh-9']);
      expect(sessions.session, isNull);
    });

    test('clears the session even when the server cannot be reached', () async {
      sessions.session = testSession();
      auth.onSignOut = (_) async => throw const ApiException.network();

      await SignOutUseCase(authRepository: auth, sessionRepository: sessions).execute();

      expect(sessions.session, isNull);
    });
  });

  group('RefreshSessionUseCase', () {
    test('replaces the session with the renewed one', () async {
      sessions.session = testSession(refreshToken: 'refresh-1');
      final renewed = testSession(accessToken: 'access-2', refreshToken: 'refresh-2');
      auth.onRefresh = (_) async => renewed;

      final result = await RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions)
          .execute();

      expect(result, same(renewed));
      expect(sessions.session, same(renewed));
      expect(auth.refreshedTokens, ['refresh-1']);
    });

    test('ends the session when the refresh token is rejected', () async {
      sessions.session = testSession();
      auth.onRefresh = (_) async => throw apiError(401, 'INVALID_REFRESH_TOKEN');

      final result = await RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions)
          .execute();

      expect(result, isNull);
      expect(sessions.session, isNull);
    });

    test('keeps the session and rethrows when the server cannot be reached', () async {
      final session = testSession();
      sessions.session = session;
      auth.onRefresh = (_) async => throw const ApiException.network();

      final refresh = RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions);

      await expectLater(refresh.execute(), throwsA(isA<ApiException>()));
      expect(sessions.session, same(session));
    });
  });

  group('RestoreSessionUseCase', () {
    RestoreSessionUseCase restore() => RestoreSessionUseCase(
      sessionRepository: sessions,
      refreshSession: RefreshSessionUseCase(authRepository: auth, sessionRepository: sessions),
      now: () => fixedNow,
    );

    test('returns null when nobody signed in before', () async {
      expect(await restore().execute(), isNull);
    });

    test('returns a session that has not expired without contacting the server', () async {
      final session = testSession();
      sessions.session = session;

      expect(await restore().execute(), same(session));
      expect(auth.refreshedTokens, isEmpty);
    });

    test('renews a session whose access token expired', () async {
      sessions.session = testSession(expiresAt: fixedNow.subtract(const Duration(minutes: 1)));
      final renewed = testSession(accessToken: 'access-2', refreshToken: 'refresh-2');
      auth.onRefresh = (_) async => renewed;

      expect(await restore().execute(), same(renewed));
    });

    test('returns null when the expired session can no longer be renewed', () async {
      sessions.session = testSession(expiresAt: fixedNow.subtract(const Duration(minutes: 1)));
      auth.onRefresh = (_) async => throw apiError(401, 'INVALID_REFRESH_TOKEN');

      expect(await restore().execute(), isNull);
      expect(sessions.session, isNull);
    });

    test('keeps the expired session when the server cannot be reached', () async {
      final session = testSession(expiresAt: fixedNow.subtract(const Duration(minutes: 1)));
      sessions.session = session;
      auth.onRefresh = (_) async => throw const ApiException.network();

      expect(await restore().execute(), same(session));
    });
  });
}

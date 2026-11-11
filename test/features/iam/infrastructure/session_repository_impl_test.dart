import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/domain/user_role.dart';
import 'package:inmonode/features/iam/infrastructure/session_repository_impl.dart';

import '../iam_fakes.dart';

void main() {
  test('keeps the session between launches', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final session = testSession(role: UserRole.catalogAdmin);

    await SessionRepositoryImpl(storage: const FlutterSecureStorage()).save(session);
    final restored = await SessionRepositoryImpl(storage: const FlutterSecureStorage()).load();

    expect(restored?.accessToken, session.accessToken);
    expect(restored?.refreshToken, session.refreshToken);
    expect(restored?.expiresAt, session.expiresAt);
    expect(restored?.role, UserRole.catalogAdmin);
  });

  test('forgets the session after signing out', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final repository = SessionRepositoryImpl(storage: const FlutterSecureStorage());
    await repository.save(testSession());

    await repository.clear();

    expect(await SessionRepositoryImpl(storage: const FlutterSecureStorage()).load(), isNull);
  });

  test('starts signed out when the stored value cannot be read', () async {
    FlutterSecureStorage.setMockInitialValues({'inmonode.session': '{"accessToken": 1}'});

    expect(await SessionRepositoryImpl(storage: const FlutterSecureStorage()).load(), isNull);
  });
}

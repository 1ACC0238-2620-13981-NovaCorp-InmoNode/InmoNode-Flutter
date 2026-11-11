import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/infrastructure/jwt_claims.dart';

import 'jwt_test_tokens.dart';

void main() {
  test('reads the user id, email and role of the access token', () {
    final claims = JwtClaims.decode(testJwt(sub: '42', email: 'admin@inmonode.pe', role: 'CATALOG_ADMIN'));

    expect(claims.userId, 42);
    expect(claims.email, 'admin@inmonode.pe');
    expect(claims.role, 'CATALOG_ADMIN');
  });

  test('rejects a value that is not a JWT', () {
    expect(() => JwtClaims.decode('not-a-jwt'), throwsFormatException);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/presentation/verification_link.dart';

void main() {
  test('reads the token of the verification link', () {
    expect(VerificationLink.tokenFrom(Uri.parse('/verify-email?token=abc-123')), 'abc-123');
    expect(
      VerificationLink.tokenFrom(Uri.parse('https://inmonode.vercel.app/verify-email?token=abc')),
      'abc',
    );
  });

  test('ignores other routes and links without a token', () {
    expect(VerificationLink.tokenFrom(Uri.parse('/')), isNull);
    expect(VerificationLink.tokenFrom(Uri.parse('/projects?token=abc')), isNull);
    expect(VerificationLink.tokenFrom(Uri.parse('/verify-email')), isNull);
    expect(VerificationLink.tokenFrom(Uri.parse('/verify-email?token=')), isNull);
    expect(VerificationLink.tokenFrom(null), isNull);
  });
}

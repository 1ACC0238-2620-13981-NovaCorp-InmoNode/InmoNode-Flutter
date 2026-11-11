import 'package:flutter_test/flutter_test.dart';
import 'package:inmonode/features/iam/presentation/email_link.dart';

void main() {
  test('reads the token of the verification link', () {
    final link = EmailLink.from(Uri.parse('/verify-email?token=abc-123'));

    expect(link?.type, EmailLinkType.verifyEmail);
    expect(link?.token, 'abc-123');
    expect(
      EmailLink.from(Uri.parse('https://inmonode.vercel.app/verify-email?token=abc'))?.token,
      'abc',
    );
  });

  test('reads the token of the password reset link', () {
    final link = EmailLink.from(Uri.parse('http://localhost:5173/reset-password?token=Zx_9-k'));

    expect(link?.type, EmailLinkType.resetPassword);
    expect(link?.token, 'Zx_9-k');
  });

  test('ignores other routes and links without a token', () {
    expect(EmailLink.from(Uri.parse('/')), isNull);
    expect(EmailLink.from(Uri.parse('/projects?token=abc')), isNull);
    expect(EmailLink.from(Uri.parse('/verify-email')), isNull);
    expect(EmailLink.from(Uri.parse('/verify-email?token=')), isNull);
    expect(EmailLink.from(Uri.parse('/reset-password')), isNull);
    expect(EmailLink.from(null), isNull);
  });
}

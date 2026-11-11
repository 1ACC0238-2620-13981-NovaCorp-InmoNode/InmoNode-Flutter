/// The verification email links to `<web app>/verify-email?token=...`.
class VerificationLink {
  static const String path = '/verify-email';

  /// The token of a verification link, or `null` when [uri] is not one.
  static String? tokenFrom(Uri? uri) {
    if (uri == null || !uri.path.endsWith(path)) return null;
    final token = uri.queryParameters['token'];
    return token == null || token.isEmpty ? null : token;
  }
}

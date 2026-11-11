/// The pages of the Web app that the account emails link to, as `<web app><path>?token=...`.
enum EmailLinkType {
  /// Activates a new account (`VERIFICATION_URL` of the Web Services).
  verifyEmail('/verify-email'),

  /// Sets a new password (`PASSWORD_RESET_URL` of the Web Services).
  resetPassword('/reset-password');

  final String path;

  const EmailLinkType(this.path);
}

class EmailLink {
  final EmailLinkType type;
  final String token;

  const EmailLink(this.type, this.token);

  /// The emailed link [uri] points to, or `null` when it is not one or has no token.
  static EmailLink? from(Uri? uri) {
    final token = uri?.queryParameters['token'];
    if (uri == null || token == null || token.isEmpty) return null;
    for (final type in EmailLinkType.values) {
      if (uri.path.endsWith(type.path)) return EmailLink(type, token);
    }
    return null;
  }
}

/// Gives [AuthorizedClient] the session tokens without making core depend on the iam feature.
abstract class TokenProvider {
  /// The current access token, or `null` when nobody is signed in.
  Future<String?> accessToken();

  /// Renews the access token. Returns `false` when the user has to sign in again.
  Future<bool> refresh();
}

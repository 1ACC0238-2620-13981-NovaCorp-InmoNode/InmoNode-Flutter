import 'dart:convert';

/// Claims the Web Services put in the access token. The signature is checked by the server, not here.
class JwtClaims {
  final int userId;
  final String email;
  final String role;

  const JwtClaims({
    required this.userId,
    required this.email,
    required this.role,
  });

  factory JwtClaims.decode(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) throw const FormatException('Malformed JWT');
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    return JwtClaims(
      userId: int.parse(payload['sub'] as String),
      email: payload['email'] as String,
      role: payload['role'] as String,
    );
  }
}

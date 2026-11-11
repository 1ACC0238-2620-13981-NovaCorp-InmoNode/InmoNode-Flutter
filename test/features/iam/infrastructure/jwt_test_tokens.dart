import 'dart:convert';

/// Unsigned JWT with the claims the Web Services issue; the app never checks the signature.
String testJwt({String sub = '7', String email = 'ana@mail.com', String role = 'BUYER'}) {
  String encode(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final header = encode({'alg': 'HS384', 'typ': 'JWT'});
  final payload = encode({'sub': sub, 'email': email, 'role': role, 'exp': 1893456000});
  return '$header.$payload.signature';
}

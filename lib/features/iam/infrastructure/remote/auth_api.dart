import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_response.dart';
import 'package:inmonode/features/iam/infrastructure/remote/token_dto.dart';
import 'package:inmonode/features/iam/infrastructure/remote/user_dto.dart';

/// Public endpoints of `/auth`. They need no access token, so they use a plain client.
class AuthApi {
  final http.Client client;

  AuthApi({http.Client? client}) : client = client ?? http.Client();

  Future<UserDto> register(String email, String password) async {
    final response = await _post('register', {'email': email, 'password': password});
    return UserDto.fromJson(response.json as Map<String, dynamic>);
  }

  Future<UserDto> verifyEmail(String token) async {
    final response = await _post('verify-email', {'token': token});
    return UserDto.fromJson(response.json as Map<String, dynamic>);
  }

  Future<void> resendVerification(String email) async {
    await _post('resend-verification', {'email': email});
  }

  Future<TokenDto> login(String email, String password) async {
    final response = await _post('login', {'email': email, 'password': password});
    return TokenDto.fromJson(response.json as Map<String, dynamic>);
  }

  Future<TokenDto> refresh(String refreshToken) async {
    final response = await _post('refresh', {'refreshToken': refreshToken});
    return TokenDto.fromJson(response.json as Map<String, dynamic>);
  }

  Future<void> logout(String refreshToken) async {
    await _post('logout', {'refreshToken': refreshToken});
  }

  Future<http.Response> _post(String path, Map<String, String> body) async {
    final response = await guardRequest(
      client.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/$path'),
        headers: ApiConstants.jsonHeaders,
        body: jsonEncode(body),
      ),
    );
    if (!response.isSuccessful) throw response.error;
    return response;
  }
}

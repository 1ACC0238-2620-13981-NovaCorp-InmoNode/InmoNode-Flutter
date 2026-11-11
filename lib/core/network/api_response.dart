import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inmonode/core/network/api_constants.dart';
import 'package:inmonode/core/network/api_exception.dart';

extension ApiResponse on http.Response {
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  /// The decoded JSON body. The Web Services answer UTF-8 without a charset, so it is decoded explicitly.
  dynamic get json => jsonDecode(utf8.decode(bodyBytes));

  ApiException get error => ApiException.fromBody(statusCode, bodyBytes);
}

/// Awaits [request] and turns timeouts and connection failures into [ApiException.network].
Future<http.Response> guardRequest(Future<http.Response> request) async {
  try {
    return await request.timeout(ApiConstants.timeout);
  } on TimeoutException {
    throw const ApiException.network();
  } on http.ClientException {
    throw const ApiException.network();
  }
}

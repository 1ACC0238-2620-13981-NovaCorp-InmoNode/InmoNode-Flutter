import 'package:http/http.dart' as http;
import 'package:inmonode/core/network/token_provider.dart';

/// HTTP client for the protected endpoints.
///
/// Sends `Authorization: Bearer <token>` and `Accept-Language: es` with every request. When the
/// Web Services answer 401, it renews the session once and repeats the request. Only plain
/// [http.Request]s are repeated, since streamed and multipart bodies cannot be sent twice.
///
/// Features receive it through get_it: `getIt<AuthorizedClient>().get(uri)`.
class AuthorizedClient extends http.BaseClient {
  final TokenProvider tokenProvider;
  final http.Client _inner;

  AuthorizedClient({required this.tokenProvider, http.Client? inner})
    : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await tokenProvider.accessToken();
    final retry = request is http.Request ? _copy(request) : null;
    final response = await _inner.send(_authorize(request, token));
    if (response.statusCode != 401 || token == null || retry == null) {
      return response;
    }

    // Another request may have renewed the session while this one was in flight.
    var current = await tokenProvider.accessToken();
    if (current == token) {
      if (!await tokenProvider.refresh()) return response;
      current = await tokenProvider.accessToken();
    }
    if (current == null) return response;

    await response.stream.drain<void>();
    return _inner.send(_authorize(retry, current));
  }

  @override
  void close() => _inner.close();

  http.BaseRequest _authorize(http.BaseRequest request, String? token) {
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.headers.putIfAbsent('Accept-Language', () => 'es');
    return request;
  }

  http.Request _copy(http.Request request) {
    return http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..bodyBytes = request.bodyBytes
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection;
  }
}

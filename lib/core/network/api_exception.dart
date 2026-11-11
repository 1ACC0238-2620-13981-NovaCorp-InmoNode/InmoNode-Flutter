import 'dart:convert';

/// Error answered by the Web Services (`{code, message, details}`) or a request that never got an answer.
class ApiException implements Exception {
  static const String networkErrorCode = 'NETWORK_ERROR';
  static const String _defaultMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';

  final int? statusCode;
  final String code;
  final String message;
  final String? details;

  const ApiException({
    this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  const ApiException.network()
    : statusCode = null,
      code = networkErrorCode,
      message = 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.',
      details = null;

  /// Reads the error resource of a failed response, falling back to a generic message.
  factory ApiException.fromBody(int statusCode, List<int> bodyBytes) {
    try {
      final json = jsonDecode(utf8.decode(bodyBytes));
      if (json is Map<String, dynamic> && json['code'] is String) {
        return ApiException(
          statusCode: statusCode,
          code: json['code'] as String,
          message: json['message'] as String? ?? _defaultMessage,
          details: json['details'] as String?,
        );
      }
    } on FormatException {
      // Not an error resource, e.g. a proxy page; use the generic message.
    }
    return ApiException(
      statusCode: statusCode,
      code: 'HTTP_$statusCode',
      message: _defaultMessage,
    );
  }

  bool get isNetworkError => code == networkErrorCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

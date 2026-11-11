class ApiConstants {
  static const String baseUrl = 'https://inmonode-backend.onrender.com/api/v1';

  /// Render puts idle services to sleep, so the first request can take close to a minute.
  static const Duration timeout = Duration(seconds: 60);

  /// Asks the Web Services for error messages in Spanish.
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept-Language': 'es',
  };
}

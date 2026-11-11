class ApiConstants {
  /// The Web Services on Render, or another backend given with
  /// `--dart-define=API_BASE_URL=http://localhost:8080/api/v1` (e.g. the backend's Docker Compose).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://inmonode-backend.onrender.com/api/v1',
  );

  /// Render puts idle services to sleep, so the first request can take close to a minute.
  static const Duration timeout = Duration(seconds: 60);

  /// Asks the Web Services for error messages in Spanish.
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept-Language': 'es',
  };
}

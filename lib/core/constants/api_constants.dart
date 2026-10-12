class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:5121';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';

  // Headers
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}

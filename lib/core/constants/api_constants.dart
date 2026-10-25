class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:5121';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';

  // Chat endpoints
  static const String chats = '/api/chats';
  static const String directChat = '/api/chats/direct';
  static const String groupChat = '/api/chats/group';

  static String messages(String chatId) => '/api/chats/$chatId/messages';

  // Realtime (SignalR)
  static const String chatHubPath = '/hubs/chat';

  // User endpoints
  static const String userSearch = '/api/users/search';

  // Headers
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}

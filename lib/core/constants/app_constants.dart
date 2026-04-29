class AppConstants {
  static const String appName = 'XFIGHTER';
  static const String appTitle = 'MMA Fighter Management System';

  /// Base URL for the Spring Boot API (no trailing slash)
  static const String baseUrl = 'http://localhost:8080';

  /// All API calls are prefixed with this
  static const String apiPrefix = '/api';

  // Routes
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String roleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userStatusKey = 'user_status';
  static const String userDataKey = 'user_data';

  // Legacy key kept for backwards compat (maps to accessTokenKey)
  static const String tokenKey = 'access_token';
}
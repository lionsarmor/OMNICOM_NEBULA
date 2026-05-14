class AppConfig {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:4400',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4400/api',
  );

  static const String backendWsBase = String.fromEnvironment(
    'BACKEND_WS_BASE',
    defaultValue: 'http://localhost:4400',
  );
}

/// Central app configuration. Replace base URLs when backend is ready.
class AppConfig {
  AppConfig._();

  static const String appName = 'GrowWealth MF';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/v1',
  );

  /// Set to false when REST API is available.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: true,
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

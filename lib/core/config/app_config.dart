abstract final class AppConfig {
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.shiftingwallah.com',
  );

  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 30);
}

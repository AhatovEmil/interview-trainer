import 'dart:io';

/// Адрес API задаётся при сборке:
/// flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8000
///
/// По умолчанию — localhost с поправкой на эмулятор Android, где хост-машина
/// доступна по 10.0.2.2, а не по 127.0.0.1.
class AppConfig {
  const AppConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) {
      return _override;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static const String apiPrefix = '/api/v1';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}

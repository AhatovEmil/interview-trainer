import 'dart:io';

import 'package:flutter/foundation.dart';

/// Адрес API задаётся при сборке:
/// flutter build appbundle --dart-define=API_BASE_URL=https://api.example.com
///
/// В отладочной сборке значение по умолчанию — localhost с поправкой на
/// эмулятор Android, где хост-машина доступна по 10.0.2.2. В релизной сборке
/// умолчания нет намеренно: приложение, случайно уехавшее в магазин с адресом
/// localhost, выглядит как полностью сломанное, и понять это по отзывам
/// невозможно. Лучше не собраться, чем собраться неправильно.
class AppConfig {
  const AppConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Проверяется на старте, до первого запроса: так ошибка сборки видна сразу,
  /// а не в момент, когда пользователь нажал «Войти».
  static void assertConfigured() {
    if (kReleaseMode && _override.isEmpty) {
      throw StateError(
        'Релизная сборка без API_BASE_URL. Передайте адрес боевого сервера: '
        'flutter build appbundle --dart-define=API_BASE_URL=https://…',
      );
    }
    if (kReleaseMode && !_override.startsWith('https://')) {
      throw StateError(
        'Релизная сборка обязана ходить по https: пароли и токены нельзя '
        'отправлять открытым текстом. Получено: $_override',
      );
    }
  }

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

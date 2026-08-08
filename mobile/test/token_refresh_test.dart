import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/core/network/api_client.dart';
import 'package:interview_trainer/core/network/api_exception.dart';
import 'package:interview_trainer/core/storage/token_storage.dart';

/// Хранилище в памяти: настоящее лезет в Keychain и в тестах недоступно.
class _MemoryStorage implements FlutterSecureStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      values[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Перехватчик: первый защищённый запрос отдаёт 401, дальше сценарий задаётся
/// поведением `/auth/refresh`.
class _Scenario extends Interceptor {
  _Scenario({required this.refreshBehaviour});

  /// 'ok' — обновление удалось, 'reject' — сервер отказал,
  /// 'offline' — ответа нет вовсе.
  final String refreshBehaviour;

  int protectedCalls = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path == '/auth/refresh') {
      switch (refreshBehaviour) {
        case 'ok':
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{
                'access_token': 'fresh-access',
                'refresh_token': 'fresh-refresh',
              },
            ),
          );
        case 'reject':
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<dynamic>(requestOptions: options, statusCode: 401),
            ),
          );
        default:
          // Ответа нет: обрыв связи, а не отказ сервера.
          handler.reject(
            DioException(requestOptions: options, type: DioExceptionType.connectionError),
          );
      }
      return;
    }

    protectedCalls++;
    if (protectedCalls == 1) {
      handler.resolve(
        Response<dynamic>(requestOptions: options, statusCode: 401),
      );
      return;
    }
    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{'ok': true},
      ),
    );
  }
}

({ApiClient client, _MemoryStorage storage, bool Function() expired}) build(
  String behaviour,
) {
  final _MemoryStorage storage = _MemoryStorage()
    ..values['access_token'] = 'stale'
    ..values['refresh_token'] = 'valid-refresh';

  // Транспорт со сценарием отдаём в конструктор: ApiClient не обязан открывать
  // свои внутренности ради тестов.
  final Dio dio = Dio(
    BaseOptions(validateStatus: (int? status) => status != null && status < 500),
  )..interceptors.add(_Scenario(refreshBehaviour: behaviour));

  final ApiClient client = ApiClient(tokens: TokenStorage(storage: storage), dio: dio);

  bool expired = false;
  client.onSessionExpired = () => expired = true;
  return (client: client, storage: storage, expired: () => expired);
}

void main() {
  group('Обновление токенов', () {
    test('успешное обновление повторяет запрос и сохраняет новые токены', () async {
      final ({ApiClient client, _MemoryStorage storage, bool Function() expired}) env =
          build('ok');

      final Map<String, dynamic> body = await env.client.get('/me');

      expect(body['ok'], isTrue);
      expect(env.storage.values['access_token'], 'fresh-access');
      expect(env.expired(), isFalse);
    });

    test('отказ сервера завершает сессию и чистит токены', () async {
      final ({ApiClient client, _MemoryStorage storage, bool Function() expired}) env =
          build('reject');

      await expectLater(
        env.client.get('/me'),
        throwsA(isA<ApiException>().having((ApiException e) => e.isUnauthorized, 'isUnauthorized', isTrue)),
      );
      expect(env.expired(), isTrue);
      expect(env.storage.values['refresh_token'], isNull);
    });

    test('обрыв связи не выкидывает из аккаунта и не стирает токены', () async {
      final ({ApiClient client, _MemoryStorage storage, bool Function() expired}) env =
          build('offline');

      await expectLater(
        env.client.get('/me'),
        throwsA(isA<ApiException>().having((ApiException e) => e.isNetworkIssue, 'isNetworkIssue', isTrue)),
      );
      // Главное: сессия цела, при возврате сети всё продолжится.
      expect(env.expired(), isFalse);
      expect(env.storage.values['refresh_token'], 'valid-refresh');
    });
  });
}

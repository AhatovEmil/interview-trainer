import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Клиент API: подставляет access-токен и один раз пробует обновить его
/// по refresh, если сервер ответил 401.
class ApiClient {
  ApiClient({required TokenStorage tokens, Dio? dio})
      : _tokens = tokens,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: '${AppConfig.baseUrl}${AppConfig.apiPrefix}',
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                contentType: Headers.jsonContentType,
                // Коды обрабатываем сами, чтобы не ловить исключения на 4xx.
                validateStatus: (int? status) => status != null && status < 500,
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          if (options.extra['skipAuth'] != true) {
            final String? token = await _tokens.readAccess();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokens;

  /// Чтобы параллельные запросы не устроили гонку обновлений.
  Future<bool>? _refreshInFlight;

  /// Вызывается, когда сессия окончательно протухла: роутер уводит на вход.
  void Function()? onSessionExpired;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) =>
      _send(
        () => _dio.get<dynamic>(
          path,
          queryParameters: query,
          options: Options(extra: <String, dynamic>{'skipAuth': skipAuth}),
        ),
        skipAuth: skipAuth,
      );

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool skipAuth = false,
  }) =>
      _send(
        () => _dio.post<dynamic>(
          path,
          data: body,
          options: Options(extra: <String, dynamic>{'skipAuth': skipAuth}),
        ),
        skipAuth: skipAuth,
      );

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) =>
      _send(
        () => _dio.patch<dynamic>(path, data: body),
      );

  Future<Map<String, dynamic>> _send(
    Future<Response<dynamic>> Function() request, {
    bool skipAuth = false,
  }) async {
    Response<dynamic> response;
    try {
      response = await request();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }

    if (response.statusCode == 401 && !skipAuth) {
      final bool refreshed = await _refreshTokens();
      if (!refreshed) {
        onSessionExpired?.call();
        throw const ApiException('Сессия истекла, войдите заново', statusCode: 401);
      }
      try {
        response = await request();
      } on DioException catch (error) {
        throw ApiException.fromDio(error);
      }
    }

    return _unwrap(response);
  }

  Map<String, dynamic> _unwrap(Response<dynamic> response) {
    final int status = response.statusCode ?? 0;
    if (status >= 400) {
      throw ApiException(
        _messageFrom(response.data) ?? 'Ошибка запроса (код $status)',
        statusCode: status,
      );
    }
    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return <String, dynamic>{};
  }

  static String? _messageFrom(dynamic data) {
    if (data is Map<String, dynamic> && data['detail'] is String) {
      return data['detail'] as String;
    }
    if (data is Map<String, dynamic> && data['detail'] is List) {
      final List<dynamic> details = data['detail'] as List<dynamic>;
      if (details.isNotEmpty && details.first is Map<String, dynamic>) {
        final Map<String, dynamic> first = details.first as Map<String, dynamic>;
        if (first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    return null;
  }

  Future<bool> _refreshTokens() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<bool> _doRefresh() async {
    final String? refresh = await _tokens.readRefresh();
    if (refresh == null) {
      return false;
    }

    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/auth/refresh',
        data: <String, dynamic>{'refresh_token': refresh},
        options: Options(extra: <String, dynamic>{'skipAuth': true}),
      );
      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        await _tokens.clear();
        return false;
      }
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      await _tokens.save(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String,
      );
      return true;
    } on DioException {
      return false;
    }
  }
}

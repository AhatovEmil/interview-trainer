import 'package:dio/dio.dart';

/// Ошибка API в виде, пригодном для показа пользователю.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  bool get isNotFound => statusCode == 404;

  bool get isPaymentRequired => statusCode == 402;

  bool get isNetworkIssue => statusCode == null;

  factory ApiException.fromDio(DioException error) {
    final Response<dynamic>? response = error.response;

    if (response == null) {
      return const ApiException(
        'Не удаётся связаться с сервером. Проверьте подключение.',
      );
    }

    return ApiException(
      _extractMessage(response.data) ?? 'Что-то пошло не так (код ${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final dynamic detail = data['detail'];
    if (detail is String) {
      return detail;
    }
    // FastAPI отдаёт ошибки валидации списком объектов.
    if (detail is List && detail.isNotEmpty) {
      final dynamic first = detail.first;
      if (first is Map<String, dynamic> && first['msg'] is String) {
        return first['msg'] as String;
      }
    }
    return null;
  }

  @override
  String toString() => message;
}

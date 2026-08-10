import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/core/network/api_client.dart';
import 'package:interview_trainer/core/storage/token_storage.dart';
import 'package:interview_trainer/data/repositories/practice_repository.dart';
import 'package:interview_trainer/domain/models/question_report.dart';

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

void main() {
  group('QuestionReportResult', () {
    test('разбирает ответ сервера', () {
      final QuestionReportResult result = QuestionReportResult.fromJson(<String, dynamic>{
        'id': '9f1c',
        'status': 'new',
        'specialization_id': 'backend_python',
        'topic_code': 'language',
        'title': 'Чем отличается процесс от потока?',
        'created_at': '2026-08-10T09:00:00Z',
        'is_duplicate': false,
      });

      expect(result.id, '9f1c');
      expect(result.status, 'new');
      expect(result.isDuplicate, isFalse);
    });

    test('отсутствие флага дубля не роняет разбор', () {
      final QuestionReportResult result = QuestionReportResult.fromJson(<String, dynamic>{
        'id': '9f1c',
        'status': 'new',
        'title': 'Чем отличается процесс от потока?',
      });

      expect(result.isDuplicate, isFalse);
    });
  });

  group('Отправка вопроса с собеседования', () {
    late Dio dio;
    late DioAdapter adapter;
    late PracticeRepository repository;

    setUp(() {
      final _MemoryStorage storage = _MemoryStorage();
      storage.values['access_token'] = 'token';
      dio = Dio(BaseOptions(baseUrl: 'http://localhost/api/v1'));
      adapter = DioAdapter();
      dio.httpClientAdapter = adapter;
      repository = PracticeRepository(
        client: ApiClient(tokens: TokenStorage(storage: storage), dio: dio),
      );
    });

    test('пустые необязательные поля не уходят на сервер', () async {
      await repository.reportQuestion(
        specializationId: 'backend_python',
        title: 'Чем отличается процесс от потока и когда что выбирать?',
        details: '',
        company: '',
      );

      final Map<String, dynamic> body = adapter.lastBody!;
      expect(body.containsKey('details'), isFalse);
      expect(body.containsKey('company'), isFalse);
      expect(body.containsKey('topic_code'), isFalse);
      expect(body.containsKey('asked_grade'), isFalse);
    });

    test('заполненные поля доходят как есть', () async {
      await repository.reportQuestion(
        specializationId: 'backend_python',
        title: 'Чем отличается процесс от потока и когда что выбирать?',
        topicCode: 'language',
        company: 'Яндекс',
        askedGrade: 4,
      );

      final Map<String, dynamic> body = adapter.lastBody!;
      expect(body['topic_code'], 'language');
      expect(body['company'], 'Яндекс');
      expect(body['asked_grade'], 4);
    });
  });
}

/// Перехватывает запрос и отдаёт заготовленный ответ, запоминая тело.
class DioAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastBody = options.data as Map<String, dynamic>?;
    return ResponseBody.fromString(
      '{"id":"9f1c","status":"new","specialization_id":"backend_python",'
      '"topic_code":null,"title":"вопрос",'
      '"created_at":"2026-08-10T09:00:00Z","is_duplicate":false}',
      201,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

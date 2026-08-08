import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/core/network/api_client.dart';
import 'package:interview_trainer/core/network/api_exception.dart';
import 'package:interview_trainer/data/local/app_database.dart';
import 'package:interview_trainer/data/local/question_mapper.dart';
import 'package:interview_trainer/data/repositories/offline_practice_repository.dart';
import 'package:interview_trainer/data/repositories/practice_repository.dart';
import 'package:interview_trainer/data/sync/sync_service.dart';
import 'package:interview_trainer/domain/models/question.dart';

const String kSpecialization = 'backend_python';

/// Сервер, которому можно отключить сеть.
///
/// Подменяем на уровне ApiClient: так проверяется настоящий путь запроса,
/// включая разбор ответа и обработку ошибок, а не заглушка репозитория.
class FakeApi implements ApiClient {
  FakeApi({required this.questions});

  final List<Map<String, dynamic>> questions;

  bool online = true;

  /// Ответы, дошедшие до «сервера»: ключ — submission_id.
  final Map<String, Map<String, dynamic>> received = <String, Map<String, dynamic>>{};

  @override
  void Function()? onSessionExpired;

  /// Сколько раз клиент дёргал загрузку ответов.
  int uploadCalls = 0;

  /// Вопросы, выданные по сети: сервер не повторяет уже отданное.
  final List<String> servedOnline = <String>[];

  /// Оборвать связь ровно один раз — имитация обрыва на середине отправки.
  bool failNextUpload = false;

  void _requireNetwork() {
    if (!online) {
      throw const ApiException('Не удаётся связаться с сервером. Проверьте подключение.');
    }
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) async {
    _requireNetwork();
    if (path == '/sync/questions') {
      return <String, dynamic>{
        'specialization_id': kSpecialization,
        'synced_at': DateTime.now().toUtc().toIso8601String(),
        'questions': questions,
      };
    }
    if (path == '/practice/next') {
      if (servedOnline.length >= questions.length) {
        throw const ApiException('вопросы закончились', statusCode: 404);
      }
      final Map<String, dynamic> question = questions[servedOnline.length];
      servedOnline.add(question['id'] as String);
      return <String, dynamic>{
        'question': question,
        'is_review': false,
        'due_at': null,
      };
    }
    throw ApiException('неожиданный GET $path', statusCode: 500);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    bool skipAuth = false,
  }) async {
    _requireNetwork();

    if (path == '/practice/answer') {
      final Map<String, dynamic> answer = body! as Map<String, dynamic>;
      received[answer['submission_id'] as String] = answer;
      return <String, dynamic>{
        'score': 1.0,
        'quality': 5,
        'rating_before': 1200.0,
        'rating_after': 1224.0,
        'rating_delta': 24.0,
        'grade': 2,
        'grade_code': 'junior_plus',
        'next_review_at': DateTime.now().toUtc().toIso8601String(),
        'is_duplicate': false,
        'explanation': <String, dynamic>{
          'answer_short': 'Короткий',
          'answer_detailed': 'Разбор',
          'common_mistakes': <String>[],
          'follow_ups': <String>[],
        },
      };
    }

    if (path != '/sync/answers') {
      throw ApiException('неожиданный POST $path', statusCode: 500);
    }

    uploadCalls++;
    if (failNextUpload) {
      failNextUpload = false;
      throw const ApiException('Не удаётся связаться с сервером. Проверьте подключение.');
    }

    final Map<String, dynamic> payload = body! as Map<String, dynamic>;
    final List<dynamic> answers = payload['answers'] as List<dynamic>;

    int accepted = 0;
    int duplicates = 0;
    final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];

    for (final dynamic item in answers) {
      final Map<String, dynamic> answer = item as Map<String, dynamic>;
      final String submissionId = answer['submission_id'] as String;
      final bool isDuplicate = received.containsKey(submissionId);
      if (isDuplicate) {
        duplicates++;
      } else {
        received[submissionId] = answer;
        accepted++;
      }
      results.add(<String, dynamic>{
        'submission_id': submissionId,
        'accepted': true,
        'is_duplicate': isDuplicate,
        'rating_after': 1200.0,
        'next_review_at': DateTime.now().toUtc().toIso8601String(),
        'error': null,
      });
    }

    return <String, dynamic>{
      'accepted': accepted,
      'duplicates': duplicates,
      'rejected': 0,
      'results': results,
    };
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    bool skipAuth = false,
  }) async {
    _requireNetwork();
    throw ApiException('неожиданный PATCH $path', statusCode: 500);
  }
}

Map<String, dynamic> questionJson(
  String id, {
  String type = 'single_choice',
  String topic = 'db',
  int minGrade = 1,
  int maxGrade = 6,
  int peakGrade = 3,
}) =>
    <String, dynamic>{
      'id': id,
      'type': type,
      'title': 'Вопрос $id',
      'topic_code': topic,
      'topic_title': 'Базы данных',
      'subtopic_code': null,
      'subtopic_title': null,
      'min_grade': minGrade,
      'peak_grade': peakGrade,
      'max_grade': maxGrade,
      'frequency': 4,
      'options': <Map<String, dynamic>>[
        <String, dynamic>{'code': 'a', 'text': 'Верный', 'is_correct': true},
        <String, dynamic>{'code': 'b', 'text': 'Неверный', 'is_correct': false},
      ],
      'is_verified': false,
      'answer_short': 'Короткий ответ $id',
      'answer_detailed': '### Junior\nРазбор $id',
      'common_mistakes': <String>['Ошибка'],
      'follow_ups': <String>['Follow-up'],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

void main() {
  late AppDatabase database;
  late FakeApi api;
  late OfflinePracticeRepository repository;
  late SyncService sync;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    api = FakeApi(
      questions: <Map<String, dynamic>>[
        questionJson('q1'),
        questionJson('q2'),
        questionJson('q3', type: 'open_answer'),
      ],
    );
    sync = SyncService(client: api, database: database);
    repository = OfflinePracticeRepository(
      remote: PracticeRepository(client: api),
      database: database,
      sync: sync,
    );
  });

  tearDown(() async => database.close());

  group('Скачивание пакета', () {
    test('вопросы оседают в локальной базе', () async {
      final int downloaded = await sync.downloadPackage(kSpecialization);

      expect(downloaded, 3);
      expect(await database.countQuestions(kSpecialization), 3);
    });

    test('повторная синхронизация не плодит дубли', () async {
      await sync.downloadPackage(kSpecialization);
      await sync.downloadPackage(kSpecialization);

      expect(await database.countQuestions(kSpecialization), 3);
    });

    test('вторым заходом отправляется метка since', () async {
      await sync.downloadPackage(kSpecialization);

      expect(await database.lastSyncedAt(kSpecialization), isNotNull);
    });
  });

  group('Тренировка в авиарежиме', () {
    setUp(() async {
      await sync.downloadPackage(kSpecialization);
      api.online = false;
    });

    test('вопрос выдаётся из локального банка', () async {
      final NextQuestion next = await repository.next(kSpecialization, grade: 3);

      expect(next.question.id, isNotEmpty);
      expect(next.question.topicTitle, 'Базы данных');
      expect(next.isReview, isFalse);
    });

    test('ответ засчитывается и показывает разбор', () async {
      final NextQuestion next = await repository.next(kSpecialization, grade: 3);

      final AnswerResult result = await repository.answer(
        submissionId: repository.newSubmissionId(),
        questionId: next.question.id,
        specializationId: kSpecialization,
        selectedOptions: <String>['a'],
      );

      expect(result.isOffline, isTrue);
      expect(result.isCorrect, isTrue);
      expect(result.explanation.answerShort, isNotEmpty);
      // Рейтинг офлайн неизвестен — врать числом нельзя.
      expect(result.hasRating, isFalse);
    });

    test('отвеченный вопрос второй раз не выдаётся', () async {
      final NextQuestion first = await repository.next(kSpecialization, grade: 3);
      await repository.answer(
        submissionId: repository.newSubmissionId(),
        questionId: first.question.id,
        specializationId: kSpecialization,
        selectedOptions: <String>['a'],
      );

      final NextQuestion second = await repository.next(kSpecialization, grade: 3);

      expect(second.question.id, isNot(first.question.id));
    });

    test('вопрос вне грейда не выдаётся и офлайн', () async {
      await database.wipe();
      await database.upsertQuestions(<CachedQuestionsCompanion>[
        const QuestionMapper().fromWire(
          questionJson('senior-only', minGrade: 5, maxGrade: 6, peakGrade: 5),
          kSpecialization,
        ),
      ]);

      expect(
        () => repository.next(kSpecialization, grade: 1),
        throwsA(isA<OfflineExhaustedException>()),
      );
    });

    test('когда локальный банк исчерпан — внятная ошибка', () async {
      for (int i = 0; i < 3; i++) {
        final NextQuestion next = await repository.next(kSpecialization, grade: 3);
        await repository.answer(
          submissionId: repository.newSubmissionId(),
          questionId: next.question.id,
          specializationId: kSpecialization,
          selectedOptions: <String>['a'],
          selfAssessment: 5,
        );
      }

      expect(
        () => repository.next(kSpecialization, grade: 3),
        throwsA(isA<OfflineExhaustedException>()),
      );
    });
  });

  group('Возвращение сети', () {
    setUp(() async {
      await sync.downloadPackage(kSpecialization);
      api.online = false;
    });

    Future<void> answerOffline(int count) async {
      for (int i = 0; i < count; i++) {
        final NextQuestion next = await repository.next(kSpecialization, grade: 3);
        await repository.answer(
          submissionId: repository.newSubmissionId(),
          questionId: next.question.id,
          specializationId: kSpecialization,
          selectedOptions: <String>['a'],
          selfAssessment: 5,
        );
      }
    }

    test('накопленные ответы улетают на сервер', () async {
      await answerOffline(3);
      expect(await database.pendingCount(), 3);

      api.online = true;
      final SyncOutcome outcome = await repository.sync(kSpecialization);

      expect(outcome.isSuccess, isTrue);
      expect(outcome.uploaded, 3);
      expect(api.received, hasLength(3));
      expect(await database.pendingCount(), 0);
    });

    test('приёмка этапа 5: повторная синхронизация не создаёт дублей', () async {
      await answerOffline(3);
      api.online = true;

      await repository.sync(kSpecialization);
      final SyncOutcome second = await repository.sync(kSpecialization);

      expect(second.uploaded, 0);
      expect(api.received, hasLength(3));
      expect(await database.pendingCount(), 0);
    });

    test('обрыв на середине оставляет очередь нетронутой', () async {
      await answerOffline(2);
      api.online = true;
      api.failNextUpload = true;

      final SyncOutcome failed = await repository.sync(kSpecialization);

      expect(failed.isSuccess, isFalse);
      expect(failed.stillPending, 2);
      expect(api.received, isEmpty);

      // Повтор после восстановления связи доносит всё без потерь.
      final SyncOutcome retried = await repository.sync(kSpecialization);

      expect(retried.isSuccess, isTrue);
      expect(retried.uploaded, 2);
      expect(await database.pendingCount(), 0);
    });

    test('ответы уходят по возрастанию времени', () async {
      await answerOffline(3);
      api.online = true;
      await repository.sync(kSpecialization);

      // Map сохраняет порядок вставки, то есть порядок прихода на «сервер».
      final List<DateTime> asSent = api.received.values
          .map(
            (Map<String, dynamic> answer) =>
                DateTime.parse(answer['answered_at'] as String),
          )
          .toList(growable: false);
      final List<DateTime> ascending = List<DateTime>.of(asSent)..sort();

      expect(asSent, ascending);
    });

    test('онлайновый ответ не попадает в очередь на отправку', () async {
      api.online = true;

      final NextQuestion next = await repository.next(kSpecialization, grade: 3);
      final AnswerResult result = await repository.answer(
        submissionId: repository.newSubmissionId(),
        questionId: next.question.id,
        specializationId: kSpecialization,
        selectedOptions: <String>['a'],
      );

      // Ответ ушёл сразу: рейтинг известен, очередь пуста.
      expect(result.isOffline, isFalse);
      expect(result.hasRating, isTrue);
      expect(await database.pendingCount(), 0);
    });

    test('онлайновый ответ запоминается, чтобы не выдаться снова офлайн', () async {
      api.online = true;
      final NextQuestion answered = await repository.next(kSpecialization, grade: 3);
      await repository.answer(
        submissionId: repository.newSubmissionId(),
        questionId: answered.question.id,
        specializationId: kSpecialization,
        selectedOptions: <String>['a'],
      );

      api.online = false;
      final NextQuestion offline = await repository.next(kSpecialization, grade: 3);

      expect(offline.question.id, isNot(answered.question.id));
    });

    test('счётчик неотправленного виден снаружи', () async {
      await answerOffline(2);

      expect(await database.pendingCount(), 2);

      api.online = true;
      await repository.sync(kSpecialization);

      expect(await database.pendingCount(), 0);
    });
  });

  group('Хранение ответа', () {
    test('выбранные варианты сохраняются как есть', () async {
      await sync.downloadPackage(kSpecialization);
      api.online = false;

      final NextQuestion next = await repository.next(kSpecialization, grade: 3);
      await repository.answer(
        submissionId: 'fixed-id',
        questionId: next.question.id,
        specializationId: kSpecialization,
        selectedOptions: <String>['a', 'b'],
      );

      final List<LocalAnswer> pending = await database.pendingAnswers();
      expect(pending, hasLength(1));
      expect(jsonDecode(pending.first.selectedOptionsJson), <String>['a', 'b']);
      expect(pending.first.submissionId, 'fixed-id');
    });

    test('выход из аккаунта стирает чужой прогресс', () async {
      await sync.downloadPackage(kSpecialization);
      api.online = false;
      await repository.answer(
        submissionId: repository.newSubmissionId(),
        questionId: 'q1',
        specializationId: kSpecialization,
        selectedOptions: <String>['a'],
      );

      await database.wipe();

      expect(await database.pendingCount(), 0);
      expect(await database.countQuestions(kSpecialization), 0);
    });
  });
}

import 'dart:convert';
import 'dart:math';

import '../../core/network/api_exception.dart';
import '../../domain/models/question.dart';
import '../local/app_database.dart';
import '../local/offline_grader.dart';
import '../local/question_mapper.dart';
import '../sync/sync_service.dart';
import 'practice_repository.dart';

/// Тренировка, которая переживает отсутствие сети.
///
/// Сеть — не признак «работает/не работает», а всего лишь удача: запрос может
/// упасть в любой момент. Поэтому решение принимается не заранее по флагу
/// connectivity, а по факту неудачи запроса.
class OfflinePracticeRepository {
  OfflinePracticeRepository({
    required PracticeRepository remote,
    required AppDatabase database,
    required SyncService sync,
    QuestionMapper mapper = const QuestionMapper(),
    OfflineGrader grader = const OfflineGrader(),
    Random? random,
  })  : _remote = remote,
        _database = database,
        _sync = sync,
        _mapper = mapper,
        _grader = grader,
        _random = random ?? Random.secure();

  final PracticeRepository _remote;
  final AppDatabase _database;
  final SyncService _sync;
  final QuestionMapper _mapper;
  final OfflineGrader _grader;
  final Random _random;

  /// Следующий вопрос: сначала сервер, при недоступности — локальный банк.
  Future<NextQuestion> next(String specialization, {required int grade}) async {
    try {
      return await _remote.next(specialization);
    } on ApiException catch (error) {
      // Сервер ответил — значит связь есть, и его отказ осмысленный: 404
      // «вопросы кончились», 401, ошибка валидации. Подменять их кешем нельзя.
      if (!error.isNetworkIssue) {
        rethrow;
      }
      return _nextFromCache(specialization, grade);
    }
  }

  Future<NextQuestion> _nextFromCache(String specialization, int grade) async {
    final List<CachedQuestion> candidates = await _database.unansweredQuestions(
      specializationId: specialization,
      grade: grade,
    );
    if (candidates.isEmpty) {
      throw const OfflineExhaustedException();
    }

    // Ближе peak_grade к грейду пользователя — выше приоритет; при равенстве
    // берём тот, что чаще встречается на собеседованиях.
    candidates.sort((CachedQuestion a, CachedQuestion b) {
      final int byPeak =
          (a.peakGrade - grade).abs().compareTo((b.peakGrade - grade).abs());
      if (byPeak != 0) {
        return byPeak;
      }
      return b.frequency.compareTo(a.frequency);
    });

    return NextQuestion(
      question: _mapper.toQuestion(candidates.first),
      isReview: false,
      dueAt: null,
    );
  }

  /// Ответ. Онлайн уходит сразу, офлайн ложится в очередь и считается локально.
  Future<AnswerResult> answer({
    required String submissionId,
    required String questionId,
    required String specializationId,
    List<String> selectedOptions = const <String>[],
    int? selfAssessment,
    String? freeText,
  }) async {
    try {
      final AnswerResult result = await _remote.answer(
        submissionId: submissionId,
        questionId: questionId,
        specializationId: specializationId,
        selectedOptions: selectedOptions,
        selfAssessment: selfAssessment,
        freeText: freeText,
      );
      // Онлайновый ответ тоже запоминаем: иначе после ухода в офлайн выдача
      // предложит вопрос, на который уже отвечали.
      await _remember(
        submissionId: submissionId,
        questionId: questionId,
        specializationId: specializationId,
        selectedOptions: selectedOptions,
        selfAssessment: selfAssessment,
        freeText: freeText,
        score: result.score,
        quality: result.quality,
        synced: true,
      );
      return result;
    } on ApiException catch (error) {
      // Сервер осознанно отказал — офлайн этого не исправит и не должен прятать.
      if (!error.isNetworkIssue) {
        rethrow;
      }
      return _answerOffline(
        submissionId: submissionId,
        questionId: questionId,
        specializationId: specializationId,
        selectedOptions: selectedOptions,
        selfAssessment: selfAssessment,
        freeText: freeText,
      );
    }
  }

  Future<AnswerResult> _answerOffline({
    required String submissionId,
    required String questionId,
    required String specializationId,
    required List<String> selectedOptions,
    int? selfAssessment,
    String? freeText,
  }) async {
    final CachedQuestion? row = await _database.questionById(questionId, specializationId);
    if (row == null) {
      throw const OfflineUnavailableException();
    }

    final GradedAnswer graded = _grader.grade(
      question: _mapper.toQuestion(row),
      selectedOptions: selectedOptions,
      selfAssessment: selfAssessment,
    );

    await _remember(
      submissionId: submissionId,
      questionId: questionId,
      specializationId: specializationId,
      selectedOptions: selectedOptions,
      selfAssessment: selfAssessment,
      freeText: freeText,
      score: graded.score,
      quality: graded.quality,
      synced: false,
    );

    return AnswerResult.offline(
      score: graded.score,
      quality: graded.quality,
      explanation: _mapper.toExplanation(row),
    );
  }

  Future<void> _remember({
    required String submissionId,
    required String questionId,
    required String specializationId,
    required List<String> selectedOptions,
    required double score,
    required int quality,
    required bool synced,
    int? selfAssessment,
    String? freeText,
  }) async {
    final DateTime now = DateTime.now();
    await _database.saveAnswer(
      SyncService.record(
        submissionId: submissionId,
        questionId: questionId,
        specializationId: specializationId,
        selectedOptionsJson: jsonEncode(selectedOptions),
        score: score,
        quality: quality,
        answeredAt: now,
        syncedAt: synced ? now : null,
        freeText: freeText,
        selfAssessment: selfAssessment,
      ),
    );
  }

  /// Сколько ответов ждут отправки — для индикатора в интерфейсе.
  Stream<int> watchPendingCount() => _database.watchPendingCount();

  Future<SyncOutcome> sync(String specializationId) => _sync.sync(specializationId);

  Future<int> cachedQuestionCount(String specializationId) =>
      _database.countQuestions(specializationId);

  String newSubmissionId() {
    // UUID v4 без внешней зависимости: 122 случайных бита плюс версия и вариант.
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final String hex = bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}'
        '-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

/// Локальный банк исчерпан: всё, что скачано и подходит по грейду, уже пройдено.
class OfflineExhaustedException implements Exception {
  const OfflineExhaustedException();

  @override
  String toString() =>
      'Скачанные вопросы закончились. Подключитесь к сети, чтобы догрузить банк.';
}

/// Вопроса нет в локальном банке — отвечать офлайн нечему.
class OfflineUnavailableException implements Exception {
  const OfflineUnavailableException();

  @override
  String toString() => 'Нет сети, а этот вопрос не скачан на устройство.';
}

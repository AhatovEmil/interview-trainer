import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../local/app_database.dart';
import '../local/question_mapper.dart';

/// Итог одного прогона синхронизации — то, что можно показать пользователю.
@immutable
class SyncOutcome {
  const SyncOutcome({
    this.downloaded = 0,
    this.uploaded = 0,
    this.duplicates = 0,
    this.rejected = 0,
    this.stillPending = 0,
    this.error,
  });

  final int downloaded;
  final int uploaded;
  final int duplicates;
  final int rejected;
  final int stillPending;
  final String? error;

  bool get isSuccess => error == null;
  bool get didSomething => downloaded > 0 || uploaded > 0 || duplicates > 0 || rejected > 0;
}

/// Обмен с сервером: скачать банк вопросов, отправить накопленные ответы.
///
/// Порядок операций важен. Сначала выгружаем ответы, потом скачиваем пакет:
/// иначе свежескачанные вопросы могли бы попасть в выдачу раньше, чем сервер
/// узнает, что часть из них уже отвечена.
class SyncService {
  SyncService({
    required ApiClient client,
    required AppDatabase database,
    QuestionMapper mapper = const QuestionMapper(),
  })  : _client = client,
        _database = database,
        _mapper = mapper;

  final ApiClient _client;
  final AppDatabase _database;
  final QuestionMapper _mapper;

  /// Пачками по столько ответов уходит на сервер. Ограничение зеркалит лимит
  /// схемы бэкенда и не даёт собрать гигантский запрос после долгого офлайна.
  static const int uploadBatchSize = 200;

  Future<SyncOutcome> sync(String specializationId) async {
    try {
      final UploadReport report = await uploadPending();
      final int downloaded = await downloadPackage(specializationId);
      return SyncOutcome(
        downloaded: downloaded,
        uploaded: report.accepted,
        duplicates: report.duplicates,
        rejected: report.rejected,
        stillPending: await _database.pendingCount(),
      );
    } on Object catch (error) {
      return SyncOutcome(
        stillPending: await _database.pendingCount(),
        error: error.toString(),
      );
    }
  }

  /// Скачивает вопросы, изменившиеся с прошлой синхронизации.
  Future<int> downloadPackage(String specializationId) async {
    final DateTime? since = await _database.lastSyncedAt(specializationId);
    final Map<String, dynamic> body = await _client.get(
      '/sync/questions',
      query: <String, dynamic>{
        'specialization': specializationId,
        if (since != null) 'since': since.toUtc().toIso8601String(),
      },
    );

    final List<dynamic> questions = body['questions'] as List<dynamic>;
    await _database.upsertQuestions(
      questions
          .map(
            (dynamic item) =>
                _mapper.fromWire(item as Map<String, dynamic>, specializationId),
          )
          .toList(growable: false),
    );

    await _database.setLastSyncedAt(
      specializationId,
      DateTime.parse(body['synced_at'] as String),
    );
    return questions.length;
  }

  /// Отправляет накопленные ответы. Возвращает, что сервер с ними сделал.
  Future<UploadReport> uploadPending() async {
    int accepted = 0;
    int duplicates = 0;
    int rejected = 0;

    while (true) {
      final List<LocalAnswer> pending = await _database.pendingAnswers(limit: uploadBatchSize);
      if (pending.isEmpty) {
        return UploadReport(accepted: accepted, duplicates: duplicates, rejected: rejected);
      }

      final Map<String, dynamic> response;
      try {
        response = await _client.post(
          '/sync/answers',
          body: <String, dynamic>{
            'answers': pending.map(_toWire).toList(growable: false),
          },
        );
      } on Object {
        // Сеть отвалилась на середине — ответы остаются в очереди нетронутыми.
        await _database.recordFailure(
          pending.map((LocalAnswer answer) => answer.submissionId).toList(growable: false),
          'отправка не удалась',
        );
        rethrow;
      }

      final DateTime now = DateTime.now();
      final List<dynamic> results = response['results'] as List<dynamic>;
      final List<String> done = <String>[];

      for (final dynamic item in results) {
        final Map<String, dynamic> result = item as Map<String, dynamic>;
        final String submissionId = result['submission_id'] as String;
        if (result['accepted'] as bool) {
          done.add(submissionId);
        } else {
          // Сервер отказал по существу (нет такого вопроса, битые данные) —
          // повторять бессмысленно, иначе очередь встанет навсегда.
          await _database.markRejected(
            submissionId,
            result['error'] as String? ?? 'отклонено сервером',
            now,
          );
          rejected++;
        }
      }

      await _database.markSynced(done, now);
      accepted += response['accepted'] as int;
      duplicates += response['duplicates'] as int;

      if (pending.length < uploadBatchSize) {
        return UploadReport(accepted: accepted, duplicates: duplicates, rejected: rejected);
      }
    }
  }

  Map<String, dynamic> _toWire(LocalAnswer answer) => <String, dynamic>{
        'submission_id': answer.submissionId,
        'question_id': answer.questionId,
        'specialization_id': answer.specializationId,
        'selected_options': _decodeOptions(answer.selectedOptionsJson),
        if (answer.freeText != null) 'free_text': answer.freeText,
        if (answer.selfAssessment != null) 'self_assessment': answer.selfAssessment,
        'answered_at': answer.answeredAt.toUtc().toIso8601String(),
      };

  List<String> _decodeOptions(String raw) =>
      (jsonDecode(raw) as List<dynamic>).cast<String>();

  /// Строка ответа для локальной таблицы.
  ///
  /// [syncedAt] заполнен, если ответ уже принят сервером (отвечали онлайн);
  /// null означает, что запись ждёт отправки.
  static LocalAnswersCompanion record({
    required String submissionId,
    required String questionId,
    required String specializationId,
    required String selectedOptionsJson,
    required double score,
    required int quality,
    required DateTime answeredAt,
    DateTime? syncedAt,
    String? freeText,
    int? selfAssessment,
  }) =>
      LocalAnswersCompanion.insert(
        submissionId: submissionId,
        questionId: questionId,
        specializationId: specializationId,
        selectedOptionsJson: Value<String>(selectedOptionsJson),
        freeText: Value<String?>(freeText),
        selfAssessment: Value<int?>(selfAssessment),
        score: score,
        quality: quality,
        answeredAt: answeredAt,
        syncedAt: Value<DateTime?>(syncedAt),
      );
}

@immutable
class UploadReport {
  const UploadReport({
    required this.accepted,
    required this.duplicates,
    required this.rejected,
  });

  final int accepted;
  final int duplicates;
  final int rejected;
}

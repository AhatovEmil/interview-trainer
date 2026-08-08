import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Скачанный банк вопросов.
///
/// Вопрос может относиться к нескольким специализациям, поэтому ключ составной:
/// одна и та же формулировка живёт в пакете каждого стека, к которому привязана.
class CachedQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get specializationId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get topicCode => text()();
  TextColumn get topicTitle => text()();
  TextColumn get subtopicCode => text().nullable()();
  TextColumn get subtopicTitle => text().nullable()();
  IntColumn get minGrade => integer()();
  IntColumn get peakGrade => integer()();
  IntColumn get maxGrade => integer()();
  IntColumn get frequency => integer()();

  /// Варианты вместе с признаком правильности: без него офлайн не проверить ответ.
  TextColumn get optionsJson => text()();
  BoolColumn get isVerified => boolean()();

  TextColumn get answerShort => text()();
  TextColumn get answerDetailed => text()();
  TextColumn get commonMistakesJson => text()();
  TextColumn get followUpsJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id, specializationId};
}

/// Ответы, данные на устройстве.
///
/// Одна таблица работает и очередью на отправку, и памятью о пройденном:
/// `syncedAt IS NULL` — ещё не улетело, иначе уже на сервере. Строки не удаляем
/// после отправки, иначе офлайн начнёт заново выдавать отвеченные вопросы.
class LocalAnswers extends Table {
  /// Ключ идемпотентности, сгенерированный на устройстве. Он же защищает от
  /// дублей на сервере при повторной отправке пачки.
  TextColumn get submissionId => text()();
  TextColumn get questionId => text()();
  TextColumn get specializationId => text()();
  TextColumn get selectedOptionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get freeText => text().nullable()();
  IntColumn get selfAssessment => integer().nullable()();

  /// Результат, посчитанный на устройстве по тем же правилам, что и на сервере.
  RealColumn get score => real()();
  IntColumn get quality => integer()();

  DateTimeColumn get answeredAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{submissionId};
}

/// Отметка последней успешной синхронизации по каждой специализации.
class SyncMetadata extends Table {
  TextColumn get specializationId => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{specializationId};
}

/// Последний известный профиль.
///
/// Без него запуск без сети некуда вести: приложение не знает ни выбранной
/// специализации, ни грейда, а `/me` в самолёте не ответит.
class CachedProfile extends Table {
  /// Строка всегда одна: профиль на устройстве ровно один.
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get payloadJson => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(tables: <Type>[CachedQuestions, LocalAnswers, SyncMetadata, CachedProfile])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'interview_trainer'));

  @override
  int get schemaVersion => 1;

  // --- банк вопросов ----------------------------------------------------------

  Future<void> upsertQuestions(List<CachedQuestionsCompanion> questions) async {
    if (questions.isEmpty) {
      return;
    }
    await batch((Batch batch) {
      batch.insertAllOnConflictUpdate(cachedQuestions, questions);
    });
  }

  Future<int> countQuestions(String specializationId) async {
    final Expression<int> total = cachedQuestions.id.count();
    final JoinedSelectStatement<HasResultSet, Object> query = selectOnly(cachedQuestions)
      ..addColumns(<Expression<Object>>[total])
      ..where(cachedQuestions.specializationId.equals(specializationId));
    return await query.map((TypedResult row) => row.read(total) ?? 0).getSingle();
  }

  /// Вопросы, подходящие грейду и ещё не отвеченные на этом устройстве.
  Future<List<CachedQuestion>> unansweredQuestions({
    required String specializationId,
    required int grade,
  }) async {
    final Set<String> answered = await answeredQuestionIds(specializationId);

    final List<CachedQuestion> rows = await (select(cachedQuestions)
          ..where(
            (CachedQuestions table) =>
                table.specializationId.equals(specializationId) &
                table.minGrade.isSmallerOrEqualValue(grade) &
                table.maxGrade.isBiggerOrEqualValue(grade),
          ))
        .get();

    return rows
        .where((CachedQuestion question) => !answered.contains(question.id))
        .toList(growable: false);
  }

  Future<CachedQuestion?> questionById(String questionId, String specializationId) =>
      (select(cachedQuestions)
            ..where(
              (CachedQuestions table) =>
                  table.id.equals(questionId) &
                  table.specializationId.equals(specializationId),
            ))
          .getSingleOrNull();

  // --- ответы -----------------------------------------------------------------

  Future<void> saveAnswer(LocalAnswersCompanion answer) =>
      into(localAnswers).insertOnConflictUpdate(answer);

  Future<Set<String>> answeredQuestionIds(String specializationId) async {
    final List<LocalAnswer> rows = await (select(localAnswers)
          ..where((LocalAnswers table) => table.specializationId.equals(specializationId)))
        .get();
    return rows.map((LocalAnswer answer) => answer.questionId).toSet();
  }

  /// Очередь на отправку, по возрастанию времени ответа: сервер пересчитывает
  /// Elo последовательно, поэтому порядок должен совпадать с реальным.
  Future<List<LocalAnswer>> pendingAnswers({int limit = 200}) => (select(localAnswers)
        ..where((LocalAnswers table) => table.syncedAt.isNull())
        ..orderBy(<OrderClauseGenerator<LocalAnswers>>[
          (LocalAnswers table) => OrderingTerm.asc(table.answeredAt),
        ])
        ..limit(limit))
      .get();

  Future<int> pendingCount() async {
    final Expression<int> total = localAnswers.submissionId.count();
    final JoinedSelectStatement<HasResultSet, Object> query = selectOnly(localAnswers)
      ..addColumns(<Expression<Object>>[total])
      ..where(localAnswers.syncedAt.isNull());
    return await query.map((TypedResult row) => row.read(total) ?? 0).getSingle();
  }

  Stream<int> watchPendingCount() {
    final Expression<int> total = localAnswers.submissionId.count();
    final JoinedSelectStatement<HasResultSet, Object> query = selectOnly(localAnswers)
      ..addColumns(<Expression<Object>>[total])
      ..where(localAnswers.syncedAt.isNull());
    return query.map((TypedResult row) => row.read(total) ?? 0).watchSingle();
  }

  Future<void> markSynced(List<String> submissionIds, DateTime syncedAt) async {
    if (submissionIds.isEmpty) {
      return;
    }
    await (update(localAnswers)
          ..where((LocalAnswers table) => table.submissionId.isIn(submissionIds)))
        .write(LocalAnswersCompanion(syncedAt: Value<DateTime>(syncedAt)));
  }

  /// Отклонённый сервером ответ помечаем как обработанный: повторять его
  /// бессмысленно, но и держать очередь заблокированной нельзя.
  Future<void> markRejected(String submissionId, String error, DateTime at) =>
      (update(localAnswers)..where((LocalAnswers table) => table.submissionId.equals(submissionId)))
          .write(
        LocalAnswersCompanion(
          syncedAt: Value<DateTime>(at),
          lastError: Value<String>(error),
        ),
      );

  /// Отправка не удалась целиком (сеть отвалилась). Ответы остаются в очереди,
  /// растёт лишь счётчик попыток — он нужен, чтобы отличить временный сбой от
  /// вечно висящей записи. Инкремент колонки Companion выразить не умеет.
  Future<void> recordFailure(List<String> submissionIds, String error) async {
    if (submissionIds.isEmpty) {
      return;
    }
    final String placeholders = List<String>.filled(submissionIds.length, '?').join(', ');
    await customUpdate(
      'UPDATE local_answers SET attempts = attempts + 1, last_error = ? '
      'WHERE submission_id IN ($placeholders)',
      variables: <Variable<Object>>[
        Variable<String>(error),
        ...submissionIds.map(Variable<String>.new),
      ],
      updates: <TableInfo<Table, Object?>>{localAnswers},
    );
  }

  // --- метаданные синхронизации -----------------------------------------------

  Future<DateTime?> lastSyncedAt(String specializationId) async {
    final SyncMetadataData? row = await (select(syncMetadata)
          ..where((SyncMetadata table) => table.specializationId.equals(specializationId)))
        .getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<void> setLastSyncedAt(String specializationId, DateTime value) =>
      into(syncMetadata).insertOnConflictUpdate(
        SyncMetadataCompanion(
          specializationId: Value<String>(specializationId),
          lastSyncedAt: Value<DateTime>(value),
        ),
      );

  // --- профиль ----------------------------------------------------------------

  Future<void> saveProfile(String payloadJson) =>
      into(cachedProfile).insertOnConflictUpdate(
        CachedProfileCompanion.insert(
          payloadJson: payloadJson,
          savedAt: DateTime.now(),
        ),
      );

  Future<String?> loadProfile() async {
    final CachedProfileData? row = await select(cachedProfile).getSingleOrNull();
    return row?.payloadJson;
  }

  /// Полная очистка — используется при выходе из аккаунта: чужие ответы и
  /// прогресс не должны достаться следующему пользователю устройства.
  Future<void> wipe() async {
    await batch((Batch batch) {
      batch.deleteAll(localAnswers);
      batch.deleteAll(cachedQuestions);
      batch.deleteAll(syncMetadata);
      batch.deleteAll(cachedProfile);
    });
  }
}

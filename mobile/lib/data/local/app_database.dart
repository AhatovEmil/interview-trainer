import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Локальное состояние пользователя.
///
/// Вопросы здесь не хранятся: банк едет в ресурсах приложения и живёт в памяти.
/// В базе только то, что накопил человек, — профиль, ответы, рейтинги по темам
/// и очередь повторений. Разделение простое: контент неизменяем и одинаков у
/// всех, состояние уникально и должно пережить обновление приложения.

/// Выбранная специализация с уровнями.
///
/// Строк несколько: прогресс хранится по каждой специализации отдельно, а
/// основная ровно одна (CLAUDE.md §3.1).
class Profiles extends Table {
  TextColumn get specializationId => text()();

  /// Где человек сейчас — стартовая точка для оценки.
  IntColumn get selfAssessedGrade => integer()();

  /// К какому уровню готовится — именно он определяет выдачу.
  IntColumn get targetGrade => integer()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  IntColumn get answersCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{specializationId};
}

/// Факт ответа.
///
/// Хранятся все попытки, а не последняя: список вопросов показывает, чем
/// закончилась именно последняя, но история нужна для счётчиков и для того,
/// чтобы отвеченный вопрос не выдавался как новый.
class Answers extends Table {
  /// Идентификатор попытки. Защищает от двойной записи при повторном нажатии.
  TextColumn get submissionId => text()();
  TextColumn get questionId => text()();
  TextColumn get specializationId => text()();

  /// Раздел дублируется сюда, чтобы статистика не искала вопрос в банке.
  TextColumn get topicCode => text()();

  TextColumn get selectedOptionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get freeText => text().nullable()();
  IntColumn get selfAssessment => integer().nullable()();

  RealColumn get score => real()();
  IntColumn get quality => integer()();

  DateTimeColumn get answeredAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{submissionId};
}

/// Elo-рейтинг по паре (специализация, раздел).
class TopicRatings extends Table {
  TextColumn get specializationId => text()();
  TextColumn get topicCode => text()();
  RealColumn get rating => real()();
  IntColumn get answersCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{specializationId, topicCode};
}

/// Состояние интервального повторения по вопросу.
///
/// Ключ без специализации: вопрос может относиться к нескольким стекам, но
/// помнит его человек один раз.
class ReviewStates extends Table {
  TextColumn get questionId => text()();
  RealColumn get easinessFactor => real()();
  IntColumn get repetitions => integer()();
  IntColumn get intervalDays => integer()();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{questionId};
}

@DriftDatabase(tables: <Type>[Profiles, Answers, TopicRatings, ReviewStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'interview_trainer'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Версия 1 обслуживала синхронизацию с сервером: кеш вопросов,
            // очередь отправки и профиль одним JSON. Сервера у приложения
            // больше нет, схема стала другой. Приложение не публиковалось,
            // переносить оттуда нечего — старые таблицы просто убираем.
            for (final String table in <String>[
              'cached_questions',
              'local_answers',
              'sync_metadata',
              'cached_profile',
            ]) {
              await m.database.customStatement('DROP TABLE IF EXISTS $table');
            }
            await m.createAll();
          }
        },
      );

  // --- профиль ----------------------------------------------------------------

  Future<List<Profile>> allProfiles() => select(profiles).get();

  Future<Profile?> primaryProfile() => (select(profiles)
        ..where((Profiles table) => table.isPrimary.equals(true))
        ..limit(1))
      .getSingleOrNull();

  Future<Profile?> profileFor(String specializationId) => (select(profiles)
        ..where((Profiles table) => table.specializationId.equals(specializationId)))
      .getSingleOrNull();

  Stream<Profile?> watchPrimaryProfile() => (select(profiles)
        ..where((Profiles table) => table.isPrimary.equals(true))
        ..limit(1))
      .watchSingleOrNull();

  /// Сохраняет специализацию и делает её основной.
  ///
  /// Основная ровно одна, поэтому с остальных отметка снимается в той же
  /// транзакции: два «основных» профиля означали бы, что главный экран
  /// показывает один стек, а тренировка выдаёт вопросы другого.
  Future<void> saveProfile({
    required String specializationId,
    required int selfAssessedGrade,
    required int targetGrade,
  }) =>
      transaction(() async {
        await (update(profiles)..where((Profiles table) => table.isPrimary.equals(true)))
            .write(const ProfilesCompanion(isPrimary: Value<bool>(false)));

        final Profile? existing = await profileFor(specializationId);
        await into(profiles).insertOnConflictUpdate(
          ProfilesCompanion(
            specializationId: Value<String>(specializationId),
            selfAssessedGrade: Value<int>(selfAssessedGrade),
            targetGrade: Value<int>(targetGrade),
            isPrimary: const Value<bool>(true),
            // Счётчик ответов принадлежит прогрессу, а не выбору уровня:
            // смена цели не должна его обнулять.
            answersCount: Value<int>(existing?.answersCount ?? 0),
            updatedAt: Value<DateTime>(DateTime.now()),
          ),
        );
      });

  // --- ответы -----------------------------------------------------------------

  Future<void> saveAnswer(AnswersCompanion answer) =>
      into(answers).insertOnConflictUpdate(answer);

  Future<List<Answer>> answersFor(String specializationId) => (select(answers)
        ..where((Answers table) => table.specializationId.equals(specializationId))
        ..orderBy(<OrderClauseGenerator<Answers>>[
          (Answers table) => OrderingTerm.asc(table.answeredAt),
        ]))
      .get();

  Future<Set<String>> answeredQuestionIds(String specializationId) async {
    final List<Answer> rows = await answersFor(specializationId);
    return rows.map((Answer answer) => answer.questionId).toSet();
  }

  Future<int> countAnswers(String specializationId) async {
    final Expression<int> total = answers.submissionId.count();
    final JoinedSelectStatement<HasResultSet, Object> query = selectOnly(answers)
      ..addColumns(<Expression<Object>>[total])
      ..where(answers.specializationId.equals(specializationId));
    return await query.map((TypedResult row) => row.read(total) ?? 0).getSingle();
  }

  /// Сколько ответов дано в этот день — норма плана считается по календарю.
  Future<int> countAnswersSince(String specializationId, DateTime since) async {
    final Expression<int> total = answers.submissionId.count();
    final JoinedSelectStatement<HasResultSet, Object> query = selectOnly(answers)
      ..addColumns(<Expression<Object>>[total])
      ..where(
        answers.specializationId.equals(specializationId) &
            answers.answeredAt.isBiggerOrEqualValue(since),
      );
    return await query.map((TypedResult row) => row.read(total) ?? 0).getSingle();
  }

  Future<void> bumpAnswersCount(String specializationId) => customUpdate(
        'UPDATE profiles SET answers_count = answers_count + 1 WHERE specialization_id = ?',
        variables: <Variable<Object>>[Variable<String>(specializationId)],
        updates: <TableInfo<Table, Object?>>{profiles},
      );

  // --- рейтинги ---------------------------------------------------------------

  Future<Map<String, TopicRating>> ratingsFor(String specializationId) async {
    final List<TopicRating> rows = await (select(topicRatings)
          ..where((TopicRatings table) => table.specializationId.equals(specializationId)))
        .get();
    return <String, TopicRating>{
      for (final TopicRating row in rows) row.topicCode: row,
    };
  }

  Future<void> saveTopicRating({
    required String specializationId,
    required String topicCode,
    required double rating,
    required int answersCount,
  }) =>
      into(topicRatings).insertOnConflictUpdate(
        TopicRatingsCompanion(
          specializationId: Value<String>(specializationId),
          topicCode: Value<String>(topicCode),
          rating: Value<double>(rating),
          answersCount: Value<int>(answersCount),
        ),
      );

  // --- повторения -------------------------------------------------------------

  Future<ReviewState?> reviewStateFor(String questionId) => (select(reviewStates)
        ..where((ReviewStates table) => table.questionId.equals(questionId)))
      .getSingleOrNull();

  Future<Map<String, ReviewState>> allReviewStates() async {
    final List<ReviewState> rows = await select(reviewStates).get();
    return <String, ReviewState>{
      for (final ReviewState row in rows) row.questionId: row,
    };
  }

  /// Просроченные повторения, самые давние первыми.
  Future<List<ReviewState>> dueReviews(DateTime now) => (select(reviewStates)
        ..where((ReviewStates table) => table.dueAt.isSmallerOrEqualValue(now))
        ..orderBy(<OrderClauseGenerator<ReviewStates>>[
          (ReviewStates table) => OrderingTerm.asc(table.dueAt),
        ]))
      .get();

  Future<void> saveReviewState(ReviewStatesCompanion state) =>
      into(reviewStates).insertOnConflictUpdate(state);

  // --- очистка ----------------------------------------------------------------

  /// Полная очистка прогресса. Банк вопросов не трогает — он в ресурсах.
  Future<void> wipe() => transaction(() async {
        await delete(answers).go();
        await delete(topicRatings).go();
        await delete(reviewStates).go();
        await delete(profiles).go();
      });
}

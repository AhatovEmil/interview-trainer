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

  /// К какому уровню готовится — именно он определяет выдачу.
  ///
  /// Уровень здесь один. Самооценка была вторым полем и не окупала себя: её
  /// спрашивали на старте, а использовали только для подписи под целевым
  /// уровнем. Сам уровень приложение всё равно измеряет по ответам.
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

/// План подготовки к собеседованию (CLAUDE.md §3.7).
///
/// Активный план ровно один на специализацию: новый заменяет старый, а прежние
/// остаются в базе — по ним видно, к чему человек уже готовился.
class StudyPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get specializationId => text()();
  DateTimeColumn get interviewDate => dateTime()();
  IntColumn get targetGrade => integer()();
  IntColumn get dailyCapacity => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

/// День плана.
///
/// Дни сохраняются, а не пересчитываются на лету: приоритет тем зависит от
/// рейтингов, и через три дня тот же расчёт дал бы другой план. Человек должен
/// видеть тот, который ему обещали.
class StudyPlanDays extends Table {
  IntColumn get planId => integer()();
  IntColumn get dayIndex => integer()();
  DateTimeColumn get day => dateTime()();

  /// Коды разделов на день, через запятую. Отдельная таблица ради трёх
  /// значений на строку не окупается.
  TextColumn get topicCodes => text()();

  IntColumn get newQuestions => integer()();
  BoolColumn get reviewOnly => boolean()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{planId, dayIndex};
}

@DriftDatabase(
  tables: <Type>[Profiles, Answers, TopicRatings, ReviewStates, StudyPlans, StudyPlanDays],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'interview_trainer'));

  @override
  int get schemaVersion => 4;

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
          if (from < 3) {
            // Уходит колонка самооценки: приложение больше не спрашивает
            // текущий уровень. Таблица пересоздаётся, остальные колонки
            // переносятся как есть — выбранный стек и прогресс сохраняются.
            await m.alterTable(TableMigration(profiles));
          }
          if (from < 4) {
            // Появился план подготовки. Ничего переносить не нужно — таблицы
            // новые, прежние данные они не трогают.
            await m.createTable(studyPlans);
            await m.createTable(studyPlanDays);
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
    required int targetGrade,
  }) =>
      transaction(() async {
        await (update(profiles)..where((Profiles table) => table.isPrimary.equals(true)))
            .write(const ProfilesCompanion(isPrimary: Value<bool>(false)));

        final Profile? existing = await profileFor(specializationId);
        await into(profiles).insertOnConflictUpdate(
          ProfilesCompanion(
            specializationId: Value<String>(specializationId),
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

  // --- план подготовки --------------------------------------------------------

  Future<StudyPlan?> activePlan(String specializationId) => (select(studyPlans)
        ..where(
          (StudyPlans table) =>
              table.specializationId.equals(specializationId) & table.isActive.equals(true),
        )
        ..orderBy(<OrderClauseGenerator<StudyPlans>>[
          (StudyPlans table) => OrderingTerm.desc(table.createdAt),
        ])
        ..limit(1))
      .getSingleOrNull();

  Future<List<StudyPlanDay>> planDaysOf(int planId) => (select(studyPlanDays)
        ..where((StudyPlanDays table) => table.planId.equals(planId))
        ..orderBy(<OrderClauseGenerator<StudyPlanDays>>[
          (StudyPlanDays table) => OrderingTerm.asc(table.dayIndex),
        ]))
      .get();

  /// Сохраняет новый план и снимает отметку активности с прежних.
  ///
  /// Активный план ровно один: два одновременно означали бы, что экран
  /// «сегодня» показывает нагрузку из одного, а прогресс считается по другому.
  Future<int> savePlan({
    required String specializationId,
    required DateTime interviewDate,
    required int targetGrade,
    required int dailyCapacity,
    required List<StudyPlanDaysCompanion> Function(int planId) days,
  }) =>
      transaction(() async {
        await (update(studyPlans)
              ..where(
                (StudyPlans table) =>
                    table.specializationId.equals(specializationId) &
                    table.isActive.equals(true),
              ))
            .write(const StudyPlansCompanion(isActive: Value<bool>(false)));

        final int planId = await into(studyPlans).insert(
          StudyPlansCompanion.insert(
            specializationId: specializationId,
            interviewDate: interviewDate,
            targetGrade: targetGrade,
            dailyCapacity: dailyCapacity,
            createdAt: DateTime.now(),
          ),
        );

        await batch(
          (Batch batch) => batch.insertAll(studyPlanDays, days(planId)),
        );
        return planId;
      });

  /// Отменяет активный план, не удаляя историю.
  Future<void> cancelPlan(String specializationId) => (update(studyPlans)
        ..where(
          (StudyPlans table) =>
              table.specializationId.equals(specializationId) & table.isActive.equals(true),
        ))
      .write(const StudyPlansCompanion(isActive: Value<bool>(false)));

  // --- очистка ----------------------------------------------------------------

  /// Полная очистка прогресса. Банк вопросов не трогает — он в ресурсах.
  Future<void> wipe() => transaction(() async {
        await delete(answers).go();
        await delete(topicRatings).go();
        await delete(reviewStates).go();
        await delete(studyPlanDays).go();
        await delete(studyPlans).go();
        await delete(profiles).go();
      });
}

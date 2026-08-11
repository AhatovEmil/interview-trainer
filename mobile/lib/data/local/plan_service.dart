import '../../domain/planner.dart' as planner;
import '../../domain/rating.dart' as elo;
import '../content/question_bank.dart';
import 'app_database.dart';

/// План подготовки к собеседованию (CLAUDE.md §3.7).
///
/// Порт серверного `PlanService` под локальную архитектуру: приоритет тем
/// считается из весов таксономии и рейтингов пользователя, раскладка по дням —
/// общим с бэкендом алгоритмом из `domain/planner.dart`.
class PlanService {
  PlanService({required AppDatabase database, required QuestionBank bank})
      : _db = database,
        _bank = bank;

  final AppDatabase _db;
  final QuestionBank _bank;

  /// Построить и сохранить план. Прежний активный план деактивируется.
  Future<void> create({
    required String specializationId,
    required DateTime interviewDate,
    int dailyCapacity = planner.kDefaultDailyCapacity,
    DateTime? today,
  }) async {
    final Profile? profile = await _db.profileFor(specializationId);
    if (profile == null) {
      throw const planner.PlanError('сначала выберите специализацию');
    }

    final List<DateTime> days = planner.planDays(
      today ?? DateTime.now(),
      interviewDate,
    );
    final List<planner.TopicPriority> priorities =
        await _priorities(specializationId, profile.targetGrade);
    final List<planner.DayPlan> schedule = planner.buildPlan(
      priorities,
      days,
      dailyCapacity: dailyCapacity,
    );

    await _db.savePlan(
      specializationId: specializationId,
      interviewDate: planner.dateOnly(interviewDate),
      targetGrade: profile.targetGrade,
      dailyCapacity: dailyCapacity,
      days: (int planId) => <StudyPlanDaysCompanion>[
        for (final planner.DayPlan day in schedule)
          StudyPlanDaysCompanion.insert(
            planId: planId,
            dayIndex: day.dayIndex,
            day: day.day,
            topicCodes: day.topics.join(','),
            newQuestions: day.newQuestions,
            reviewOnly: day.reviewOnly,
          ),
      ],
    );
  }

  Future<void> cancel(String specializationId) => _db.cancelPlan(specializationId);

  /// Что делать сегодня. `null` — активного плана нет.
  Future<TodayPlan?> today(String specializationId, {DateTime? now}) async {
    final StudyPlan? plan = await _db.activePlan(specializationId);
    if (plan == null) {
      return null;
    }

    final DateTime current = planner.dateOnly(now ?? DateTime.now());
    final List<StudyPlanDay> days = await _db.planDaysOf(plan.id);

    // День собеседования и всё, что после, — плана уже нет.
    if (!plan.interviewDate.isAfter(current)) {
      return TodayPlan.finished(plan: plan, today: current);
    }

    final StudyPlanDay? day = days
        .where((StudyPlanDay item) => planner.dateOnly(item.day) == current)
        .firstOrNull;

    // Плана на сегодня может не быть: человек создал план на будущее и зашёл
    // раньше первого дня. Показываем ближайший день, а не пустоту.
    final StudyPlanDay? upcoming = day ??
        days.where((StudyPlanDay item) => planner.dateOnly(item.day).isAfter(current)).firstOrNull;

    if (upcoming == null) {
      return TodayPlan.finished(plan: plan, today: current);
    }

    final List<String> topicCodes =
        upcoming.topicCodes.isEmpty ? const <String>[] : upcoming.topicCodes.split(',');
    final Map<String, String> titles = _bank.topicTitles(specializationId);

    final int dueReviews = await _dueCount(specializationId, current);
    final int doneToday = await _db.countAnswersSince(
      specializationId,
      DateTime(current.year, current.month, current.day),
    );

    return TodayPlan(
      plan: plan,
      day: upcoming,
      isForToday: day != null,
      topicCodes: topicCodes,
      topicTitles: <String, String>{
        for (final String code in topicCodes) code: titles[code] ?? code,
      },
      dueReviews: dueReviews,
      doneToday: doneToday,
      daysLeft: plan.interviewDate.difference(current).inDays,
    );
  }

  Future<int> _dueCount(String specializationId, DateTime now) async {
    final List<ReviewState> due = await _db.dueReviews(now);
    return due
        .where((ReviewState state) {
          final BankQuestion? question = _bank.byId(state.questionId);
          return question != null && question.specializations.contains(specializationId);
        })
        .length;
  }

  Future<List<planner.TopicPriority>> _priorities(
    String specializationId,
    int targetGrade,
  ) async {
    final Map<String, double> weights = _bank.topicWeights(specializationId, targetGrade);
    final Map<String, TopicRating> ratings = await _db.ratingsFor(specializationId);

    return <planner.TopicPriority>[
      for (final MapEntry<String, double> entry in weights.entries)
        planner.TopicPriority(
          topicCode: entry.key,
          weight: entry.value,
          // Темы, по которым человек ещё не отвечал, идут со стартовым
          // рейтингом: незнакомая тема не должна выглядеть освоенной.
          rating: ratings[entry.key]?.rating ?? elo.kStartRating.toDouble(),
        ),
    ];
  }
}

/// Что делать сегодня по плану.
class TodayPlan {
  const TodayPlan({
    required this.plan,
    required this.day,
    required this.isForToday,
    required this.topicCodes,
    required this.topicTitles,
    required this.dueReviews,
    required this.doneToday,
    required this.daysLeft,
  });

  /// План есть, но собеседование уже наступило или прошло.
  factory TodayPlan.finished({required StudyPlan plan, required DateTime today}) => TodayPlan(
        plan: plan,
        day: null,
        isForToday: false,
        topicCodes: const <String>[],
        topicTitles: const <String, String>{},
        dueReviews: 0,
        doneToday: 0,
        daysLeft: plan.interviewDate.difference(today).inDays,
      );

  final StudyPlan plan;
  final StudyPlanDay? day;

  /// Совпадает ли показанный день с сегодняшним. Иначе это ближайший будущий.
  final bool isForToday;

  final List<String> topicCodes;
  final Map<String, String> topicTitles;
  final int dueReviews;
  final int doneToday;
  final int daysLeft;

  bool get isFinished => day == null;

  bool get isReviewOnly => day?.reviewOnly ?? true;

  /// Сколько вопросов нужно закрыть сегодня: повторения плюс новые.
  int get target => isFinished ? 0 : dueReviews + (day?.newQuestions ?? 0);

  double get progress {
    if (target == 0) {
      return doneToday > 0 ? 1 : 0;
    }
    final double value = doneToday / target;
    return value > 1 ? 1 : value;
  }

  bool get isDone => target > 0 && doneToday >= target;
}

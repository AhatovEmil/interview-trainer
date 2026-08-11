/// Построение плана подготовки к собеседованию (CLAUDE.md §3.7).
///
/// Порт `app/services/planner.py`: чистая логика без базы. На вход — темы с
/// весами и рейтингами, на выход — расписание по дням. Тесты повторяют
/// `backend/tests/test_planner.py` дословно, чтобы две реализации не разошлись.
library;

import 'rating.dart';

/// Сколько тем даём в один день: больше — распыление внимания.
const int kTopicsPerDay = 3;
const int kDefaultDailyCapacity = 10;
const int kMaxPlanDays = 30;

/// План построить нельзя: некорректные даты или пустая таксономия.
class PlanError implements Exception {
  const PlanError(this.message);

  final String message;

  @override
  String toString() => message;
}

class TopicPriority {
  const TopicPriority({
    required this.topicCode,
    required this.weight,
    required this.rating,
  });

  final String topicCode;
  final double weight;
  final double rating;

  /// Вес темы для целевого грейда × пробел пользователя по ней.
  double get priority => weight * (1.0 - normalizedRating(rating));
}

class DayPlan {
  const DayPlan({
    required this.dayIndex,
    required this.day,
    required this.topics,
    required this.newQuestions,
    required this.reviewOnly,
  });

  final int dayIndex;
  final DateTime day;
  final List<String> topics;
  final int newQuestions;
  final bool reviewOnly;
}

/// Дата без времени: план оперирует календарными днями, и часы здесь только
/// мешают сравнению.
DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

/// Дни подготовки: с сегодня по день перед собеседованием включительно.
List<DateTime> planDays(DateTime today, DateTime interviewDate) {
  final DateTime from = dateOnly(today);
  final DateTime to = dateOnly(interviewDate);

  if (!to.isAfter(from)) {
    throw const PlanError('дата собеседования должна быть в будущем');
  }

  final int total = to.difference(from).inDays;
  if (total > kMaxPlanDays) {
    throw const PlanError('план строится максимум на $kMaxPlanDays дней');
  }

  return <DateTime>[
    for (int offset = 0; offset < total; offset++)
      DateTime(from.year, from.month, from.day + offset),
  ];
}

/// Разложить темы по дням.
///
/// Нагрузка распределяется равномерно, приоритетные темы встречаются чаще,
/// последний день перед собеседованием — только повторение пройденного.
List<DayPlan> buildPlan(
  List<TopicPriority> topics,
  List<DateTime> days, {
  int dailyCapacity = kDefaultDailyCapacity,
}) {
  if (days.isEmpty) {
    throw const PlanError('нет ни одного дня для подготовки');
  }
  if (dailyCapacity < 1) {
    throw const PlanError('дневная нагрузка должна быть положительной');
  }

  final List<TopicPriority> ranked = topics
      .where((TopicPriority topic) => topic.weight > 0.0)
      .toList()
    ..sort((TopicPriority a, TopicPriority b) {
      final int byPriority = b.priority.compareTo(a.priority);
      return byPriority != 0 ? byPriority : a.topicCode.compareTo(b.topicCode);
    });

  if (ranked.isEmpty) {
    throw const PlanError('для этой специализации нет тем с весами');
  }

  // Последний день всегда закрепление: новых тем в него не кладём.
  final List<DateTime> studyDays = days.sublist(0, days.length - 1);

  if (studyDays.isEmpty) {
    return <DayPlan>[
      DayPlan(
        dayIndex: 0,
        day: days.first,
        topics: const <String>[],
        newQuestions: 0,
        reviewOnly: true,
      ),
    ];
  }

  final List<List<String>> schedule = _distribute(ranked, studyDays.length);

  return <DayPlan>[
    for (int index = 0; index < studyDays.length; index++)
      DayPlan(
        dayIndex: index,
        day: studyDays[index],
        topics: schedule[index],
        newQuestions: dailyCapacity,
        reviewOnly: false,
      ),
    DayPlan(
      dayIndex: studyDays.length,
      day: days.last,
      topics: const <String>[],
      newQuestions: 0,
      reviewOnly: true,
    ),
  ];
}

/// Разложить темы по дням так, чтобы ни одна не осталась без слота.
///
/// Сначала каждая тема получает по слоту в порядке приоритета — это гарантирует
/// покрытие всех слабых мест. Оставшиеся слоты добираются по кругу с начала
/// списка, то есть достаются самым приоритетным.
List<List<String>> _distribute(List<TopicPriority> ranked, int dayCount) {
  final int perDay = kTopicsPerDay < ranked.length ? kTopicsPerDay : ranked.length;
  final int totalSlots = dayCount * perDay;

  final List<String> codes =
      ranked.map((TopicPriority topic) => topic.topicCode).toList(growable: false);

  final List<String> sequence = <String>[];
  while (sequence.length < totalSlots) {
    final int remaining = totalSlots - sequence.length;
    sequence.addAll(codes.take(remaining));
  }

  final List<List<String>> schedule =
      List<List<String>>.generate(dayCount, (_) => <String>[]);

  // Раскладываем по кругу: тема с высоким приоритетом попадает в разные дни,
  // а не забивает один.
  for (int position = 0; position < sequence.length; position++) {
    final List<String> day = schedule[position % dayCount];
    final String code = sequence[position];
    if (!day.contains(code)) {
      day.add(code);
    }
  }

  // Дни, где из-за дедупликации осталось меньше тем, добираем по приоритету.
  for (final List<String> dayTopics in schedule) {
    for (final String code in codes) {
      if (dayTopics.length >= perDay) {
        break;
      }
      if (!dayTopics.contains(code)) {
        dayTopics.add(code);
      }
    }
  }

  return schedule;
}

Set<String> coveredTopics(List<DayPlan> plan) => <String>{
      for (final DayPlan day in plan) ...day.topics,
    };

import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/planner.dart';

/// Планировщик подготовки. Проверки повторяют backend/tests/test_planner.py:
/// приложение работает без сервера, и две реализации обязаны совпадать.
final DateTime today = DateTime(2026, 8, 8);

/// Девять разделов backend_python с весами для middle и разными рейтингами.
const List<TopicPriority> topics = <TopicPriority>[
  TopicPriority(topicCode: 'language', weight: 0.85, rating: 1500),
  TopicPriority(topicCode: 'async', weight: 0.85, rating: 1200),
  TopicPriority(topicCode: 'db', weight: 1.0, rating: 1050),
  TopicPriority(topicCode: 'web', weight: 0.95, rating: 1300),
  TopicPriority(topicCode: 'architecture', weight: 0.8, rating: 1100),
  TopicPriority(topicCode: 'system_design', weight: 0.6, rating: 1000),
  TopicPriority(topicCode: 'infra', weight: 0.6, rating: 1400),
  TopicPriority(topicCode: 'algorithms', weight: 0.6, rating: 1600),
  TopicPriority(topicCode: 'soft', weight: 0.7, rating: 1200),
];

List<DateTime> week() => planDays(today, today.add(const Duration(days: 7)));

void main() {
  group('Дни плана', () {
    test('покрывают всё до дня перед собеседованием', () {
      final List<DateTime> days = planDays(today, today.add(const Duration(days: 7)));

      expect(days.length, 7);
      expect(days.first, today);
      expect(days.last, DateTime(2026, 8, 14));
    });

    test('собеседование в прошлом или сегодня отвергается', () {
      expect(
        () => planDays(today, today.subtract(const Duration(days: 1))),
        throwsA(isA<PlanError>()),
      );
      expect(() => planDays(today, today), throwsA(isA<PlanError>()));
    });

    test('слишком длинный горизонт отвергается', () {
      expect(
        () => planDays(today, today.add(const Duration(days: kMaxPlanDays + 1))),
        throwsA(isA<PlanError>()),
      );
    });

    test('время суток не влияет на число дней', () {
      final List<DateTime> days = planDays(
        DateTime(2026, 8, 8, 23, 59),
        DateTime(2026, 8, 15, 0, 1),
      );

      expect(days.length, 7);
    });
  });

  group('Приоритет темы', () {
    test('растёт при низком рейтинге', () {
      const TopicPriority strong = TopicPriority(topicCode: 'db', weight: 1, rating: 1800);
      const TopicPriority weak = TopicPriority(topicCode: 'db', weight: 1, rating: 1000);

      expect(weak.priority, greaterThan(strong.priority));
      expect(strong.priority, closeTo(0.0, 1e-9));
    });

    test('растёт с весом темы', () {
      const TopicPriority heavy =
          TopicPriority(topicCode: 'system_design', weight: 1, rating: 1200);
      const TopicPriority light =
          TopicPriority(topicCode: 'language', weight: 0.5, rating: 1200);

      expect(heavy.priority, greaterThan(light.priority));
    });
  });

  group('Раскладка по дням', () {
    test('одна запись на каждый день', () {
      final List<DateTime> days = week();

      final List<DayPlan> plan = buildPlan(topics, days);

      expect(plan.length, days.length);
      expect(plan.map((DayPlan item) => item.day).toList(), days);
      expect(
        plan.map((DayPlan item) => item.dayIndex).toList(),
        List<int>.generate(days.length, (int index) => index),
      );
    });

    test('последний день — только повторение', () {
      final List<DayPlan> plan = buildPlan(topics, week());

      final DayPlan last = plan.last;
      expect(last.reviewOnly, isTrue);
      expect(last.topics, isEmpty);
      expect(last.newQuestions, 0);
    });

    test('только последний день — повторение', () {
      final List<DayPlan> plan = buildPlan(topics, week());

      expect(
        plan.sublist(0, plan.length - 1).every((DayPlan item) => !item.reviewOnly),
        isTrue,
      );
    });

    test('план на неделю покрывает все слабые темы', () {
      final List<DayPlan> plan = buildPlan(topics, week());

      final Set<String> covered = coveredTopics(plan);
      final Set<String> weak = topics
          .where((TopicPriority topic) => topic.priority > 0)
          .map((TopicPriority topic) => topic.topicCode)
          .toSet();

      expect(weak.difference(covered), isEmpty);
    });

    test('дневная нагрузка ровная', () {
      final List<DayPlan> plan = buildPlan(topics, week(), dailyCapacity: 12);

      final List<DayPlan> studyDays =
          plan.where((DayPlan item) => !item.reviewOnly).toList();

      expect(studyDays.map((DayPlan item) => item.newQuestions).toSet(), <int>{12});
      expect(
        studyDays.map((DayPlan item) => item.topics.length).toSet(),
        <int>{kTopicsPerDay},
      );
    });

    test('самая приоритетная тема встречается чаще всех', () {
      final List<DayPlan> plan = buildPlan(topics, week());
      final Map<String, int> counts = <String, int>{};
      for (final DayPlan day in plan) {
        for (final String topic in day.topics) {
          counts[topic] = (counts[topic] ?? 0) + 1;
        }
      }

      final TopicPriority top = topics.reduce(
        (TopicPriority a, TopicPriority b) => a.priority >= b.priority ? a : b,
      );

      expect(counts[top.topicCode], counts.values.reduce((int a, int b) => a > b ? a : b));
    });

    test('темы внутри дня не повторяются', () {
      final List<DayPlan> plan = buildPlan(topics, week());

      for (final DayPlan day in plan) {
        expect(day.topics.toSet().length, day.topics.length);
      }
    });

    test('темы с нулевым весом пропускаются', () {
      const List<TopicPriority> withZero = <TopicPriority>[
        TopicPriority(topicCode: 'language', weight: 1, rating: 1200),
        TopicPriority(topicCode: 'system_design', weight: 0, rating: 1000),
      ];

      final List<DayPlan> plan = buildPlan(withZero, week());

      expect(coveredTopics(plan).contains('system_design'), isFalse);
    });

    test('собеседование завтра — только повторение', () {
      final List<DateTime> days = planDays(today, today.add(const Duration(days: 1)));

      final List<DayPlan> plan = buildPlan(topics, days);

      expect(plan.length, 1);
      expect(plan.first.reviewOnly, isTrue);
    });

    test('план на два дня: один учебный, один на повторение', () {
      final List<DateTime> days = planDays(today, today.add(const Duration(days: 2)));

      final List<DayPlan> plan = buildPlan(topics, days);

      expect(plan.map((DayPlan item) => item.reviewOnly).toList(), <bool>[false, true]);
      expect(plan.first.topics.length, kTopicsPerDay);
    });

    test('длинный план по-прежнему покрывает всё', () {
      final List<DateTime> days = planDays(today, today.add(const Duration(days: 14)));

      final List<DayPlan> plan = buildPlan(topics, days);

      expect(
        coveredTopics(plan),
        topics.map((TopicPriority topic) => topic.topicCode).toSet(),
      );
    });

    test('тем меньше, чем слотов в дне', () {
      const List<TopicPriority> few = <TopicPriority>[
        TopicPriority(topicCode: 'db', weight: 1, rating: 1100),
        TopicPriority(topicCode: 'web', weight: 0.9, rating: 1200),
      ];

      final List<DayPlan> plan = buildPlan(few, week());

      for (final DayPlan day in plan.sublist(0, plan.length - 1)) {
        expect(day.topics.length, 2);
      }
    });

    test('пустой список тем отвергается', () {
      expect(() => buildPlan(<TopicPriority>[], week()), throwsA(isA<PlanError>()));
    });

    test('план без дней отвергается', () {
      expect(() => buildPlan(topics, <DateTime>[]), throwsA(isA<PlanError>()));
    });

    test('неположительная нагрузка отвергается', () {
      expect(
        () => buildPlan(topics, week(), dailyCapacity: 0),
        throwsA(isA<PlanError>()),
      );
    });

    test('нагрузка по умолчанию', () {
      final List<DayPlan> plan = buildPlan(topics, week());

      expect(plan.first.newQuestions, kDefaultDailyCapacity);
    });
  });
}

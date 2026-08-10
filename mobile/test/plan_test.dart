import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/models/plan.dart';

Map<String, dynamic> _today({
  int completed = 0,
  int target = 10,
  bool reviewOnly = false,
  List<dynamic> newQuestions = const <dynamic>[],
}) =>
    <String, dynamic>{
      'plan_id': 'p1',
      'specialization_id': 'backend_python',
      'day': '2026-08-10',
      'day_index': 2,
      'days_left': 5,
      'review_only': reviewOnly,
      'topic_codes': <String>['db', 'async'],
      'topic_titles': <String>['Базы данных', 'Асинхронность'],
      'due_reviews': 3,
      'completed_today': completed,
      'total_target': target,
      'new_questions': newQuestions,
    };

void main() {
  group('TodayPlan', () {
    test('разбирает ответ сервера', () {
      final TodayPlan today = TodayPlan.fromJson(_today());

      expect(today.planId, 'p1');
      expect(today.dayIndex, 2);
      expect(today.daysLeft, 5);
      expect(today.dueReviews, 3);
      expect(today.topicCodes, <String>['db', 'async']);
      expect(today.topicTitles, <String>['Базы данных', 'Асинхронность']);
      expect(today.newQuestions, isEmpty);
    });

    test('без названий с сервера показываем коды, а не пустоту', () {
      final Map<String, dynamic> payload = _today()..remove('topic_titles');

      expect(TodayPlan.fromJson(payload).topicTitles, <String>['db', 'async']);
    });

    test('прогресс — доля закрытой нормы', () {
      expect(TodayPlan.fromJson(_today(completed: 5)).progress, 0.5);
      expect(TodayPlan.fromJson(_today(completed: 0)).progress, 0);
    });

    test('перевыполненная норма не даёт больше единицы', () {
      final TodayPlan today = TodayPlan.fromJson(_today(completed: 25));

      expect(today.progress, 1);
      expect(today.isDone, isTrue);
    });

    test('пустая норма считается закрытой, а не делится на ноль', () {
      final TodayPlan today = TodayPlan.fromJson(_today(completed: 0, target: 0));

      expect(today.progress, 1);
      expect(today.isDone, isTrue);
    });

    test('день закрепления помечен и без новых вопросов', () {
      final TodayPlan today = TodayPlan.fromJson(_today(reviewOnly: true));

      expect(today.reviewOnly, isTrue);
      expect(today.newQuestions, isEmpty);
    });
  });

  group('StudyPlan', () {
    test('последний день плана — только повторение', () {
      final StudyPlan plan = StudyPlan.fromJson(<String, dynamic>{
        'id': 'p1',
        'specialization_id': 'backend_python',
        'interview_date': '2026-08-17',
        'target_grade': 3,
        'target_grade_code': 'middle',
        'daily_capacity': 10,
        'days': <dynamic>[
          <String, dynamic>{
            'day_index': 0,
            'day': '2026-08-15',
            'topic_codes': <String>['db'],
            'new_questions': 10,
            'review_only': false,
          },
          <String, dynamic>{
            'day_index': 1,
            'day': '2026-08-16',
            'topic_codes': <String>[],
            'new_questions': 0,
            'review_only': true,
          },
        ],
      });

      expect(plan.days, hasLength(2));
      expect(plan.days.last.reviewOnly, isTrue);
      expect(plan.days.last.newQuestions, 0);
      expect(plan.interviewDate, DateTime(2026, 8, 17));
    });
  });
}

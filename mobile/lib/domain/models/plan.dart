import 'question.dart';

/// День плана подготовки.
class PlanDay {
  const PlanDay({
    required this.dayIndex,
    required this.day,
    required this.topicCodes,
    required this.newQuestions,
    required this.reviewOnly,
  });

  final int dayIndex;
  final DateTime day;
  final List<String> topicCodes;
  final int newQuestions;

  /// День закрепления: только повторение пройденного, новых тем нет.
  final bool reviewOnly;

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
        dayIndex: json['day_index'] as int,
        day: DateTime.parse(json['day'] as String),
        topicCodes: (json['topic_codes'] as List<dynamic>).cast<String>(),
        newQuestions: json['new_questions'] as int,
        reviewOnly: json['review_only'] as bool,
      );
}

class StudyPlan {
  const StudyPlan({
    required this.id,
    required this.specializationId,
    required this.interviewDate,
    required this.targetGrade,
    required this.dailyCapacity,
    required this.days,
  });

  final String id;
  final String specializationId;
  final DateTime interviewDate;
  final int targetGrade;
  final int dailyCapacity;
  final List<PlanDay> days;

  factory StudyPlan.fromJson(Map<String, dynamic> json) => StudyPlan(
        id: json['id'] as String,
        specializationId: json['specialization_id'] as String,
        interviewDate: DateTime.parse(json['interview_date'] as String),
        targetGrade: json['target_grade'] as int,
        dailyCapacity: json['daily_capacity'] as int,
        days: (json['days'] as List<dynamic>)
            .map((dynamic item) => PlanDay.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );
}

/// Что делать сегодня. Повторения идут первыми: пропущенное повторение
/// обесценивает уже пройденное сильнее, чем недобранная новая тема.
class TodayPlan {
  const TodayPlan({
    required this.planId,
    required this.specializationId,
    required this.day,
    required this.dayIndex,
    required this.daysLeft,
    required this.reviewOnly,
    required this.topicCodes,
    required this.topicTitles,
    required this.dueReviews,
    required this.completedToday,
    required this.totalTarget,
    required this.newQuestions,
  });

  final String planId;
  final String specializationId;
  final DateTime day;
  final int dayIndex;
  final int daysLeft;
  final bool reviewOnly;
  final List<String> topicCodes;

  /// Названия тех же разделов по порядку. Интерфейс показывает их, а не коды.
  final List<String> topicTitles;

  final int dueReviews;
  final int completedToday;
  final int totalTarget;
  final List<Question> newQuestions;

  double get progress =>
      totalTarget == 0 ? 1 : (completedToday / totalTarget).clamp(0.0, 1.0).toDouble();

  bool get isDone => completedToday >= totalTarget;

  factory TodayPlan.fromJson(Map<String, dynamic> json) => TodayPlan(
        planId: json['plan_id'] as String,
        specializationId: json['specialization_id'] as String,
        day: DateTime.parse(json['day'] as String),
        dayIndex: json['day_index'] as int,
        daysLeft: json['days_left'] as int,
        reviewOnly: json['review_only'] as bool,
        topicCodes: (json['topic_codes'] as List<dynamic>).cast<String>(),
        // Старый сервер названий не отдаёт — тогда показываем коды, а не пустоту.
        topicTitles: (json['topic_titles'] as List<dynamic>? ??
                json['topic_codes'] as List<dynamic>)
            .cast<String>(),
        dueReviews: json['due_reviews'] as int,
        completedToday: json['completed_today'] as int,
        totalTarget: json['total_target'] as int,
        newQuestions: (json['new_questions'] as List<dynamic>)
            .map((dynamic item) => Question.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );
}

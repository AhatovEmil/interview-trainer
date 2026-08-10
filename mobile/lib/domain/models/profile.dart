/// Выбранная специализация и уровень, к которому по ней готовятся.
///
/// Самооценки здесь нет намеренно. Приложение не спрашивает, кем человек себя
/// считает: на входе достаточно стека, а уровень он либо выставляет сам, либо
/// приложение измеряет его по ответам. Спрашивать то, что всё равно потом
/// измеряешь, — лишний экран на старте.
class UserSpecialization {
  const UserSpecialization({
    required this.specializationId,
    required this.targetGrade,
    required this.isPrimary,
    required this.answersCount,
  });

  final String specializationId;

  /// Уровень, к которому человек готовится. Именно он определяет выдачу.
  final int targetGrade;

  final bool isPrimary;
  final int answersCount;
}

class TopicStats {
  const TopicStats({
    required this.topicCode,
    required this.title,
    required this.rating,
    required this.grade,
    required this.gradeCode,
    required this.answersCount,
    required this.weight,
  });

  final String topicCode;
  final String title;
  final double rating;
  final int grade;
  final String gradeCode;
  final int answersCount;
  final double weight;

  factory TopicStats.fromJson(Map<String, dynamic> json) => TopicStats(
        topicCode: json['topic_code'] as String,
        title: json['title'] as String,
        rating: (json['rating'] as num).toDouble(),
        grade: json['grade'] as int,
        gradeCode: json['grade_code'] as String,
        answersCount: json['answers_count'] as int,
        weight: (json['weight'] as num).toDouble(),
      );
}

/// Причины, по которым оценка уровня недоступна. Совпадают с бэкендом.
enum StatsLock {
  notEnoughData('not_enough_data'),
  premiumRequired('premium_required');

  const StatsLock(this.wire);

  final String wire;

  static StatsLock? fromWire(String? value) {
    if (value == null) {
      return null;
    }
    for (final StatsLock lock in StatsLock.values) {
      if (lock.wire == value) {
        return lock;
      }
    }
    return null;
  }
}

class PracticeStats {
  const PracticeStats({
    required this.specializationId,
    required this.answersCount,
    required this.topics,
    required this.overallRating,
    required this.overallGrade,
    required this.overallGradeCode,
    required this.lock,
  });

  final String specializationId;
  final int answersCount;
  final List<TopicStats> topics;
  final double? overallRating;
  final int? overallGrade;
  final String? overallGradeCode;
  final StatsLock? lock;

  factory PracticeStats.fromJson(Map<String, dynamic> json) => PracticeStats(
        specializationId: json['specialization_id'] as String,
        answersCount: json['answers_count'] as int,
        topics: (json['topics'] as List<dynamic>)
            .map((dynamic item) => TopicStats.fromJson(item as Map<String, dynamic>))
            .toList(),
        overallRating: (json['overall_rating'] as num?)?.toDouble(),
        overallGrade: json['overall_grade'] as int?,
        overallGradeCode: json['overall_grade_code'] as String?,
        lock: StatsLock.fromWire(json['locked_reason'] as String?),
      );

  /// Слабые темы — то, ради чего продукт и нужен.
  List<TopicStats> get weakest {
    final List<TopicStats> sorted = List<TopicStats>.of(topics)
      ..sort((TopicStats a, TopicStats b) => a.rating.compareTo(b.rating));
    return sorted.take(3).toList();
  }
}

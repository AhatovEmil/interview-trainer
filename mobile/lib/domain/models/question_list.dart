/// Как пользователь закрыл вопрос в последний раз.
///
/// Именно последний, а не лучший результат: список показывает текущее положение
/// дел, иначе забытый вопрос выглядел бы освоенным.
enum QuestionStatus {
  unanswered('unanswered'),
  correct('correct'),
  partial('partial'),
  wrong('wrong');

  const QuestionStatus(this.wire);

  final String wire;

  static QuestionStatus fromWire(String value) => QuestionStatus.values.firstWhere(
        (QuestionStatus status) => status.wire == value,
        orElse: () => QuestionStatus.unanswered,
      );

  bool get isAnswered => this != QuestionStatus.unanswered;
}

/// Строка списка вопросов. Разбора и вариантов ответа здесь нет —
/// список не должен работать шпаргалкой.
class QuestionListItem {
  const QuestionListItem({
    required this.id,
    required this.title,
    required this.topicCode,
    required this.topicTitle,
    required this.minGrade,
    required this.peakGrade,
    required this.maxGrade,
    required this.frequency,
    required this.status,
    required this.answersCount,
    required this.inGradeRange,
    this.lastAnsweredAt,
    this.dueAt,
  });

  final String id;
  final String title;
  final String topicCode;
  final String topicTitle;

  /// Границы уровней, на которых вопрос уместен. Нужны для фильтра по грейду:
  /// один пиковый грейд не отвечает на вопрос «спросят ли это на middle».
  final int minGrade;
  final int maxGrade;

  final int peakGrade;
  final int frequency;
  final QuestionStatus status;
  final int answersCount;

  /// Попадает ли вопрос в адаптивную выдачу при текущем грейде.
  final bool inGradeRange;

  final DateTime? lastAnsweredAt;
  final DateTime? dueAt;

  /// Повторение просрочено — вопрос ждёт возврата.
  bool get isDue => dueAt != null && dueAt!.isBefore(DateTime.now());

  /// Спрашивают ли этот вопрос на таком уровне.
  bool suitsGrade(int grade) => minGrade <= grade && grade <= maxGrade;

  factory QuestionListItem.fromJson(Map<String, dynamic> json) => QuestionListItem(
        id: json['id'] as String,
        title: json['title'] as String,
        topicCode: json['topic_code'] as String,
        topicTitle: json['topic_title'] as String,
        minGrade: json['min_grade'] as int,
        maxGrade: json['max_grade'] as int,
        peakGrade: json['peak_grade'] as int,
        frequency: json['frequency'] as int,
        status: QuestionStatus.fromWire(json['status'] as String),
        answersCount: json['answers_count'] as int,
        inGradeRange: json['in_grade_range'] as bool,
        lastAnsweredAt: json['last_answered_at'] == null
            ? null
            : DateTime.parse(json['last_answered_at'] as String),
        dueAt: json['due_at'] == null ? null : DateTime.parse(json['due_at'] as String),
      );
}

class QuestionListSummary {
  const QuestionListSummary({
    required this.specializationId,
    required this.total,
    required this.answered,
    required this.correct,
    required this.partial,
    required this.wrong,
    required this.items,
  });

  final String specializationId;
  final int total;
  final int answered;
  final int correct;
  final int partial;
  final int wrong;
  final List<QuestionListItem> items;

  double get progress => total == 0 ? 0 : answered / total;

  /// Вопросы, сгруппированные по разделу, в порядке появления.
  Map<String, List<QuestionListItem>> get byTopic {
    final Map<String, List<QuestionListItem>> grouped = <String, List<QuestionListItem>>{};
    for (final QuestionListItem item in items) {
      grouped.putIfAbsent(item.topicTitle, () => <QuestionListItem>[]).add(item);
    }
    return grouped;
  }

  factory QuestionListSummary.fromJson(Map<String, dynamic> json) => QuestionListSummary(
        specializationId: json['specialization_id'] as String,
        total: json['total'] as int,
        answered: json['answered'] as int,
        correct: json['correct'] as int,
        partial: json['partial'] as int,
        wrong: json['wrong'] as int,
        items: (json['items'] as List<dynamic>)
            .map((dynamic item) => QuestionListItem.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );
}

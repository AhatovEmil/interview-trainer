/// Типы вопросов повторяют QuestionType на бэкенде.
enum QuestionType {
  singleChoice('single_choice'),
  multiChoice('multi_choice'),
  shortAnswer('short_answer'),
  openAnswer('open_answer');

  const QuestionType(this.wire);

  final String wire;

  static QuestionType fromWire(String value) => QuestionType.values.firstWhere(
        (QuestionType type) => type.wire == value,
        orElse: () => QuestionType.openAnswer,
      );

  bool get hasOptions => this == singleChoice || this == multiChoice;

  bool get allowsMultiple => this == multiChoice;
}

class QuestionOption {
  const QuestionOption({required this.code, required this.text});

  final String code;
  final String text;

  factory QuestionOption.fromJson(Map<String, dynamic> json) => QuestionOption(
        code: json['code'] as String,
        text: json['text'] as String,
      );
}

/// Вопрос без ответа: разбор приходит только после отправки.
class Question {
  const Question({
    required this.id,
    required this.type,
    required this.title,
    required this.topicCode,
    required this.subtopicCode,
    required this.minGrade,
    required this.peakGrade,
    required this.maxGrade,
    required this.frequency,
    required this.options,
    required this.isVerified,
  });

  final String id;
  final QuestionType type;
  final String title;
  final String topicCode;
  final String? subtopicCode;
  final int minGrade;
  final int peakGrade;
  final int maxGrade;
  final int frequency;
  final List<QuestionOption> options;
  final bool isVerified;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        type: QuestionType.fromWire(json['type'] as String),
        title: json['title'] as String,
        topicCode: json['topic_code'] as String,
        subtopicCode: json['subtopic_code'] as String?,
        minGrade: json['min_grade'] as int,
        peakGrade: json['peak_grade'] as int,
        maxGrade: json['max_grade'] as int,
        frequency: json['frequency'] as int,
        options: (json['options'] as List<dynamic>)
            .map((dynamic item) => QuestionOption.fromJson(item as Map<String, dynamic>))
            .toList(),
        isVerified: json['is_verified'] as bool,
      );
}

class NextQuestion {
  const NextQuestion({
    required this.question,
    required this.isReview,
    required this.dueAt,
  });

  final Question question;
  final bool isReview;
  final DateTime? dueAt;

  factory NextQuestion.fromJson(Map<String, dynamic> json) => NextQuestion(
        question: Question.fromJson(json['question'] as Map<String, dynamic>),
        isReview: json['is_review'] as bool,
        dueAt: json['due_at'] == null ? null : DateTime.parse(json['due_at'] as String),
      );
}

class QuestionExplanation {
  const QuestionExplanation({
    required this.answerShort,
    required this.answerDetailed,
    required this.commonMistakes,
    required this.followUps,
  });

  final String answerShort;
  final String answerDetailed;
  final List<String> commonMistakes;
  final List<String> followUps;

  factory QuestionExplanation.fromJson(Map<String, dynamic> json) => QuestionExplanation(
        answerShort: json['answer_short'] as String,
        answerDetailed: json['answer_detailed'] as String,
        commonMistakes:
            (json['common_mistakes'] as List<dynamic>).map((dynamic e) => e as String).toList(),
        followUps: (json['follow_ups'] as List<dynamic>).map((dynamic e) => e as String).toList(),
      );
}

class AnswerResult {
  const AnswerResult({
    required this.score,
    required this.quality,
    required this.ratingBefore,
    required this.ratingAfter,
    required this.ratingDelta,
    required this.grade,
    required this.gradeCode,
    required this.nextReviewAt,
    required this.isDuplicate,
    required this.explanation,
  });

  final double score;
  final int quality;
  final double ratingBefore;
  final double ratingAfter;
  final double ratingDelta;
  final int grade;
  final String gradeCode;
  final DateTime nextReviewAt;
  final bool isDuplicate;
  final QuestionExplanation explanation;

  bool get isCorrect => score >= 1.0;

  bool get isPartial => score > 0.0 && score < 1.0;

  factory AnswerResult.fromJson(Map<String, dynamic> json) => AnswerResult(
        score: (json['score'] as num).toDouble(),
        quality: json['quality'] as int,
        ratingBefore: (json['rating_before'] as num).toDouble(),
        ratingAfter: (json['rating_after'] as num).toDouble(),
        ratingDelta: (json['rating_delta'] as num).toDouble(),
        grade: json['grade'] as int,
        gradeCode: json['grade_code'] as String,
        nextReviewAt: DateTime.parse(json['next_review_at'] as String),
        isDuplicate: json['is_duplicate'] as bool,
        explanation: QuestionExplanation.fromJson(json['explanation'] as Map<String, dynamic>),
      );
}

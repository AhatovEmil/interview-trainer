import '../../domain/models/question.dart';

/// Оценка ответа на устройстве.
///
/// Повторяет правила сервера (`PracticeService._evaluate` и `services/rating`).
/// Расхождение здесь означало бы, что в самолёте пользователю показали «верно»,
/// а после синхронизации рейтинг поехал в другую сторону.
class OfflineGrader {
  const OfflineGrader();

  static const double scoreCorrect = 1;
  static const double scorePartial = 0.5;
  static const double scoreWrong = 0;

  /// Очки и качество 0–5 для планировщика повторений.
  GradedAnswer grade({
    required Question question,
    required List<String> selectedOptions,
    int? selfAssessment,
  }) {
    if (question.type.hasOptions) {
      return _gradeChoice(question, selectedOptions);
    }

    if (selfAssessment == null) {
      throw ArgumentError('для развёрнутого вопроса нужна самооценка от 0 до 5');
    }
    return GradedAnswer(score: scoreFromQuality(selfAssessment), quality: selfAssessment);
  }

  GradedAnswer _gradeChoice(Question question, List<String> selectedOptions) {
    if (selectedOptions.isEmpty) {
      throw ArgumentError('для этого вопроса нужно выбрать вариант ответа');
    }

    final Set<String> known =
        question.options.map((QuestionOption option) => option.code).toSet();
    final Set<String> selected = selectedOptions.toSet();
    if (selected.difference(known).isNotEmpty) {
      throw ArgumentError('неизвестные варианты ответа');
    }

    final Set<String> correct = question.options
        .where((QuestionOption option) => option.isCorrect ?? false)
        .map((QuestionOption option) => option.code)
        .toSet();

    final double score;
    if (_sameSet(selected, correct)) {
      score = scoreCorrect;
    } else if (selected.intersection(correct).isNotEmpty &&
        selected.difference(correct).isEmpty) {
      // Часть верных и ничего лишнего — частичный ответ, как на сервере.
      score = scorePartial;
    } else {
      score = scoreWrong;
    }
    return GradedAnswer(score: score, quality: qualityFromScore(score));
  }

  static bool _sameSet(Set<String> left, Set<String> right) =>
      left.length == right.length && left.containsAll(right);

  /// Самооценка 0–5 в очки: 4–5 верно, 3 частично, ниже — неверно.
  static double scoreFromQuality(int quality) {
    if (quality >= 4) {
      return scoreCorrect;
    }
    if (quality == 3) {
      return scorePartial;
    }
    return scoreWrong;
  }

  /// Обратное преобразование для выборочных вопросов, где самооценки нет.
  static int qualityFromScore(double score) {
    if (score >= scoreCorrect) {
      return 5;
    }
    if (score >= scorePartial) {
      return 3;
    }
    return 1;
  }
}

class GradedAnswer {
  const GradedAnswer({required this.score, required this.quality});

  final double score;
  final int quality;

  bool get isCorrect => score >= OfflineGrader.scoreCorrect;
  bool get isPartial => score > OfflineGrader.scoreWrong && score < OfflineGrader.scoreCorrect;
}

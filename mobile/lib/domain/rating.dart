/// Elo-оценка уровня (CLAUDE.md §3.5).
///
/// Порт серверной `app/services/rating.py`. Приложение считает рейтинги само,
/// на устройстве: сервера у релиза нет, и оценка не может зависеть от сети.
///
/// Константы и формулы обязаны совпадать с серверными — бэкенд остаётся в
/// репозитории и вернётся, когда понадобится синхронизация между устройствами.
/// Расхождение тогда означало бы, что после включения синхронизации у человека
/// поедут все накопленные оценки.
library;

import 'dart:math' as math;

const double kStartRating = 1200;

const int kFactorInitial = 32;
const int kFactorExperienced = 16;
const int kFactorQuestion = 4;
const int kExperienceThreshold = 30;

/// Пока ответов меньше, оценку по специализации не показываем.
const int kMinAnswersForEstimate = 20;

const double kScoreCorrect = 1;
const double kScorePartial = 0.5;
const double kScoreWrong = 0;

/// Диапазон нормализации рейтинга в 0..1 для приоритета тем в плане.
const double kNormalizeMin = 1000;
const double kNormalizeMax = 1800;

/// Нижние границы рейтинга для каждого грейда, по убыванию.
const List<(double, int)> _gradeThresholds = <(double, int)>[
  (1800, 6),
  (1600, 5),
  (1450, 4),
  (1300, 3),
  (1150, 2),
  (1000, 1),
];

/// Результат пересчёта после одного ответа.
class EloUpdate {
  const EloUpdate({
    required this.userRatingBefore,
    required this.userRatingAfter,
    required this.questionRatingBefore,
    required this.questionRatingAfter,
  });

  final double userRatingBefore;
  final double userRatingAfter;
  final int questionRatingBefore;
  final int questionRatingAfter;

  double get userDelta => userRatingAfter - userRatingBefore;
  int get questionDelta => questionRatingAfter - questionRatingBefore;
}

/// Вероятность верного ответа по формуле Elo.
double expectedScore(double userRating, double questionRating) =>
    1.0 / (1.0 + math.pow(10, (questionRating - userRating) / 400.0));

/// Новичок по теме двигается быстрее: рейтинг должен быстро найти уровень.
int userKFactor(int answersOnTopic) =>
    answersOnTopic < kExperienceThreshold ? kFactorInitial : kFactorExperienced;

EloUpdate applyElo({
  required double userRating,
  required int questionRating,
  required double score,
  required int answersOnTopic,
}) {
  final double expected = expectedScore(userRating, questionRating.toDouble());
  final int k = userKFactor(answersOnTopic);

  return EloUpdate(
    userRatingBefore: userRating,
    userRatingAfter: userRating + k * (score - expected),
    questionRatingBefore: questionRating,
    // Рейтинг вопроса двигается медленно: он общий для всех, и один ответ не
    // должен заметно менять сложность для остальных.
    questionRatingAfter: (questionRating - kFactorQuestion * (score - expected)).round(),
  );
}

int gradeFromRating(double rating) {
  for (final (double threshold, int grade) in _gradeThresholds) {
    if (rating >= threshold) {
      return grade;
    }
  }
  return 0;
}

/// Рейтинг в шкале 0..1 — множитель приоритета темы в плане подготовки.
double normalizedRating(double rating) =>
    ((rating - kNormalizeMin) / (kNormalizeMax - kNormalizeMin)).clamp(0.0, 1.0);

/// Взвешенное среднее по темам; вес темы берётся для целевого грейда.
///
/// Темы без веса игнорируются, темы без рейтинга не учитываются вовсе: иначе
/// нетронутый раздел тянул бы оценку к стартовым 1200.
double? overallRating(Map<String, double> ratings, Map<String, double> weights) {
  double numerator = 0;
  double denominator = 0;

  ratings.forEach((String topic, double rating) {
    final double weight = weights[topic] ?? 0;
    if (weight <= 0) {
      return;
    }
    numerator += rating * weight;
    denominator += weight;
  });

  return denominator == 0 ? null : numerator / denominator;
}

/// Самооценка 0–5 в Elo-очки: 4–5 верно, 3 частично, ниже — неверно.
double scoreFromQuality(int quality) {
  if (quality >= 4) {
    return kScoreCorrect;
  }
  return quality == 3 ? kScorePartial : kScoreWrong;
}

/// Обратное преобразование для выборочных вопросов, где самооценки нет.
int qualityFromScore(double score) {
  if (score >= kScoreCorrect) {
    return 5;
  }
  return score >= kScorePartial ? 3 : 1;
}

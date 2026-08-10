import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/rating.dart';

/// Проверки перенесены с сервера (backend/tests/test_rating.py) намеренно.
///
/// Формулы и константы должны совпадать: бэкенд остаётся в репозитории и
/// вернётся, когда появится синхронизация между устройствами. Разъехавшаяся
/// математика тогда означала бы, что у человека поедут все накопленные оценки.
void main() {
  group('Ожидаемый результат', () {
    test('при равных рейтингах — половина', () {
      expect(expectedScore(1200, 1200), closeTo(0.5, 1e-9));
    });

    test('растёт, когда вопрос легче пользователя', () {
      expect(expectedScore(1600, 1200), greaterThan(0.9));
      expect(expectedScore(1200, 1600), lessThan(0.1));
    });

    test('разница в 400 очков даёт классическое соотношение 10 к 1', () {
      expect(expectedScore(1600, 1200), closeTo(10 / 11, 1e-6));
    });
  });

  group('Коэффициент K', () {
    test('падает после порога опыта', () {
      expect(userKFactor(0), kFactorInitial);
      expect(userKFactor(kExperienceThreshold - 1), kFactorInitial);
      expect(userKFactor(kExperienceThreshold), kFactorExperienced);
    });
  });

  group('Пересчёт рейтинга', () {
    EloUpdate apply(int questionRating, double score, {int answers = 0}) => applyElo(
          userRating: kStartRating,
          questionRating: questionRating,
          score: score,
          answersOnTopic: answers,
        );

    test('верный ответ на сложный вопрос заметно поднимает рейтинг', () {
      final EloUpdate update = apply(1700, kScoreCorrect);

      expect(update.userDelta, greaterThan(25));
    });

    test('провал на лёгком вопросе заметно роняет рейтинг', () {
      final EloUpdate update = apply(900, kScoreWrong);

      expect(update.userDelta, lessThan(-25));
    });

    test('верный ответ на лёгкий вопрос двигает рейтинг едва', () {
      final EloUpdate update = apply(900, kScoreCorrect);

      expect(update.userDelta, greaterThan(0));
      expect(update.userDelta, lessThan(6));
    });

    test('провал на сложном вопросе двигает рейтинг едва', () {
      final EloUpdate update = apply(1700, kScoreWrong);

      expect(update.userDelta, lessThan(0));
      expect(update.userDelta, greaterThan(-6));
    });

    test('частичный ответ на равный вопрос оставляет рейтинг на месте', () {
      final EloUpdate update = apply(kStartRating.toInt(), kScorePartial);

      expect(update.userDelta, closeTo(0, 1e-9));
    });

    test('опытный по теме двигается медленнее новичка', () {
      final EloUpdate novice = apply(1700, kScoreCorrect);
      final EloUpdate veteran = apply(1700, kScoreCorrect, answers: kExperienceThreshold);

      expect(veteran.userDelta.abs(), lessThan(novice.userDelta.abs()));
    });

    test('рейтинг вопроса движется в обратную сторону и медленно', () {
      final EloUpdate update = apply(1700, kScoreCorrect);

      // Пользователь справился со сложным — вопрос оказался легче, чем считался.
      expect(update.questionDelta, lessThan(0));
      expect(update.questionDelta.abs(), lessThan(update.userDelta.abs()));
    });
  });

  group('Грейд по рейтингу', () {
    test('границы совпадают с таблицей из спецификации', () {
      expect(gradeFromRating(999), 0);
      expect(gradeFromRating(1000), 1);
      expect(gradeFromRating(1149), 1);
      expect(gradeFromRating(1150), 2);
      expect(gradeFromRating(1300), 3);
      expect(gradeFromRating(1450), 4);
      expect(gradeFromRating(1600), 5);
      expect(gradeFromRating(1800), 6);
      expect(gradeFromRating(2500), 6);
    });
  });

  group('Нормализация', () {
    test('обрезается по краям диапазона', () {
      expect(normalizedRating(500), 0);
      expect(normalizedRating(kNormalizeMin), 0);
      expect(normalizedRating(kNormalizeMax), 1);
      expect(normalizedRating(3000), 1);
    });

    test('середина диапазона даёт половину', () {
      expect(normalizedRating(1400), closeTo(0.5, 1e-9));
    });
  });

  group('Общий рейтинг по темам', () {
    test('темы без веса не учитываются', () {
      final double? result = overallRating(
        <String, double>{'db': 1500, 'soft': 1000},
        <String, double>{'db': 1.0, 'soft': 0.0},
      );

      expect(result, 1500);
    });

    test('нетронутая тема не тянет оценку к стартовым 1200', () {
      // В ratings её просто нет — веса без рейтинга в расчёт не идут.
      final double? result = overallRating(
        <String, double>{'db': 1600},
        <String, double>{'db': 1.0, 'async': 1.0},
      );

      expect(result, 1600);
    });

    test('без единого рейтинга оценки нет', () {
      expect(overallRating(<String, double>{}, <String, double>{'db': 1.0}), isNull);
    });

    test('вес темы влияет на результат', () {
      final double? result = overallRating(
        <String, double>{'db': 1600, 'soft': 1000},
        <String, double>{'db': 3.0, 'soft': 1.0},
      );

      expect(result, closeTo((1600 * 3 + 1000) / 4, 1e-9));
    });
  });

  group('Самооценка и очки', () {
    test('4 и 5 — верно, 3 — частично, ниже — неверно', () {
      expect(scoreFromQuality(5), kScoreCorrect);
      expect(scoreFromQuality(4), kScoreCorrect);
      expect(scoreFromQuality(3), kScorePartial);
      expect(scoreFromQuality(2), kScoreWrong);
      expect(scoreFromQuality(0), kScoreWrong);
    });

    test('обратное преобразование сохраняет смысл', () {
      expect(qualityFromScore(kScoreCorrect), 5);
      expect(qualityFromScore(kScorePartial), 3);
      expect(qualityFromScore(kScoreWrong), 1);
    });
  });
}

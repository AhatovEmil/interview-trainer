import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/data/local/offline_grader.dart';
import 'package:interview_trainer/domain/models/question.dart';

Question _question(QuestionType type, {List<QuestionOption> options = const <QuestionOption>[]}) =>
    Question(
      id: 'q1',
      type: type,
      title: 'Вопрос',
      topicCode: 'db',
      topicTitle: 'Базы данных',
      subtopicCode: null,
      subtopicTitle: null,
      minGrade: 1,
      peakGrade: 3,
      maxGrade: 6,
      frequency: 5,
      options: options,
      isVerified: false,
    );

const List<QuestionOption> _threeOfFour = <QuestionOption>[
  QuestionOption(code: 'a', text: 'SRP', isCorrect: true),
  QuestionOption(code: 'b', text: 'OCP', isCorrect: true),
  QuestionOption(code: 'c', text: 'LSP', isCorrect: true),
  QuestionOption(code: 'd', text: 'ISP наоборот', isCorrect: false),
];

void main() {
  const OfflineGrader grader = OfflineGrader();

  group('Выборочные вопросы', () {
    test('полное совпадение — верно', () {
      final GradedAnswer graded = grader.grade(
        question: _question(QuestionType.multiChoice, options: _threeOfFour),
        selectedOptions: <String>['a', 'b', 'c'],
      );

      expect(graded.score, OfflineGrader.scoreCorrect);
      expect(graded.quality, 5);
      expect(graded.isCorrect, isTrue);
    });

    test('часть верных без лишнего — частично', () {
      final GradedAnswer graded = grader.grade(
        question: _question(QuestionType.multiChoice, options: _threeOfFour),
        selectedOptions: <String>['a', 'b'],
      );

      expect(graded.score, OfflineGrader.scorePartial);
      expect(graded.quality, 3);
      expect(graded.isPartial, isTrue);
    });

    test('верные вместе с ошибочным — неверно', () {
      final GradedAnswer graded = grader.grade(
        question: _question(QuestionType.multiChoice, options: _threeOfFour),
        selectedOptions: <String>['a', 'b', 'c', 'd'],
      );

      expect(graded.score, OfflineGrader.scoreWrong);
      expect(graded.quality, 1);
    });

    test('только ошибочный — неверно', () {
      final GradedAnswer graded = grader.grade(
        question: _question(QuestionType.multiChoice, options: _threeOfFour),
        selectedOptions: <String>['d'],
      );

      expect(graded.score, OfflineGrader.scoreWrong);
    });

    test('порядок вариантов не влияет', () {
      final GradedAnswer straight = grader.grade(
        question: _question(QuestionType.multiChoice, options: _threeOfFour),
        selectedOptions: <String>['a', 'b', 'c'],
      );
      final GradedAnswer reversed = grader.grade(
        question: _question(QuestionType.multiChoice, options: _threeOfFour),
        selectedOptions: <String>['c', 'b', 'a'],
      );

      expect(straight.score, reversed.score);
    });

    test('пустой выбор — ошибка, а не молчаливый ноль', () {
      expect(
        () => grader.grade(
          question: _question(QuestionType.multiChoice, options: _threeOfFour),
          selectedOptions: const <String>[],
        ),
        throwsArgumentError,
      );
    });

    test('несуществующий вариант — ошибка', () {
      expect(
        () => grader.grade(
          question: _question(QuestionType.multiChoice, options: _threeOfFour),
          selectedOptions: <String>['z'],
        ),
        throwsArgumentError,
      );
    });
  });

  group('Развёрнутые вопросы', () {
    test('самооценка 4 и 5 — верно', () {
      for (final int quality in <int>[4, 5]) {
        final GradedAnswer graded = grader.grade(
          question: _question(QuestionType.openAnswer),
          selectedOptions: const <String>[],
          selfAssessment: quality,
        );
        expect(graded.score, OfflineGrader.scoreCorrect, reason: 'quality = $quality');
        expect(graded.quality, quality);
      }
    });

    test('самооценка 3 — частично', () {
      final GradedAnswer graded = grader.grade(
        question: _question(QuestionType.openAnswer),
        selectedOptions: const <String>[],
        selfAssessment: 3,
      );

      expect(graded.score, OfflineGrader.scorePartial);
    });

    test('самооценка 0–2 — неверно', () {
      for (final int quality in <int>[0, 1, 2]) {
        final GradedAnswer graded = grader.grade(
          question: _question(QuestionType.openAnswer),
          selectedOptions: const <String>[],
          selfAssessment: quality,
        );
        expect(graded.score, OfflineGrader.scoreWrong, reason: 'quality = $quality');
      }
    });

    test('без самооценки — ошибка', () {
      expect(
        () => grader.grade(
          question: _question(QuestionType.openAnswer),
          selectedOptions: const <String>[],
        ),
        throwsArgumentError,
      );
    });
  });

  group('Совпадение с сервером', () {
    // Таблицы ниже повторяют app/services/rating.py. Если сервер поменяет
    // правила, а клиент нет, пользователь увидит офлайн одно, а после
    // синхронизации — другое.
    test('score_from_quality', () {
      expect(OfflineGrader.scoreFromQuality(5), 1.0);
      expect(OfflineGrader.scoreFromQuality(4), 1.0);
      expect(OfflineGrader.scoreFromQuality(3), 0.5);
      expect(OfflineGrader.scoreFromQuality(2), 0.0);
      expect(OfflineGrader.scoreFromQuality(0), 0.0);
    });

    test('quality_from_score', () {
      expect(OfflineGrader.qualityFromScore(1.0), 5);
      expect(OfflineGrader.qualityFromScore(0.5), 3);
      expect(OfflineGrader.qualityFromScore(0.0), 1);
    });
  });
}

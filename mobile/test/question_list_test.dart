import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/models/question_list.dart';

/// Поиск по банку и счётчик повторений.
///
/// Обе вещи видны на экране, но проверить их глазами трудно: поиск зависит от
/// разбора запроса, а счётчик — от времени. Здесь они закреплены явно.
QuestionListItem item({
  String id = 'q1',
  String title = 'Что такое GIL и на что он влияет?',
  String topicTitle = 'Язык',
  DateTime? dueAt,
}) =>
    QuestionListItem(
      id: id,
      title: title,
      topicCode: 'language',
      topicTitle: topicTitle,
      minGrade: 1,
      peakGrade: 3,
      maxGrade: 5,
      frequency: 5,
      status: QuestionStatus.unanswered,
      answersCount: 0,
      inGradeRange: true,
      dueAt: dueAt,
    );

QuestionListSummary summary(List<QuestionListItem> items) => QuestionListSummary(
      specializationId: 'backend_python',
      total: items.length,
      answered: 0,
      correct: 0,
      partial: 0,
      wrong: 0,
      items: items,
    );

void main() {
  group('Поиск', () {
    test('находит по слову из формулировки без учёта регистра', () {
      expect(item().matchesQuery('gil'), isTrue);
      expect(item().matchesQuery('GIL'), isTrue);
    });

    test('находит по названию раздела', () {
      expect(item(topicTitle: 'Базы данных').matchesQuery('базы'), isTrue);
    });

    test('все слова запроса должны найтись, а не любое из них', () {
      expect(item().matchesQuery('gil влияет'), isTrue);
      expect(item().matchesQuery('gil транзакции'), isFalse);
    });

    test('лишние пробелы не ломают запрос', () {
      expect(item().matchesQuery('  gil   '), isTrue);
    });

    test('несовпадение возвращает false, а не всё подряд', () {
      expect(item().matchesQuery('kubernetes'), isFalse);
    });
  });

  group('Повторения', () {
    test('считаются только просроченные', () {
      final DateTime now = DateTime.now();
      final QuestionListSummary result = summary(<QuestionListItem>[
        item(id: 'a', dueAt: now.subtract(const Duration(days: 1))),
        item(id: 'b', dueAt: now.add(const Duration(days: 1))),
        item(id: 'c'),
      ]);

      expect(result.dueCount, 1);
    });

    test('без единого повторения счётчик нулевой', () {
      expect(summary(<QuestionListItem>[item()]).dueCount, 0);
    });
  });
}

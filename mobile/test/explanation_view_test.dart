import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/models/question.dart';
import 'package:interview_trainer/presentation/practice/explanation_view.dart';

AnswerResult _result(String detailed) => AnswerResult.fromJson(<String, dynamic>{
      'score': 1.0,
      'quality': 5,
      'rating_before': 1200.0,
      'rating_after': 1224.0,
      'rating_delta': 24.0,
      'grade': 2,
      'grade_code': 'junior_plus',
      'difficulty_before': 1390,
      'difficulty_after': 1387,
      'next_review_at': '2026-08-09T12:00:00Z',
      'is_duplicate': false,
      'explanation': <String, dynamic>{
        'answer_short': 'Коротко',
        'answer_detailed': detailed,
        'common_mistakes': <dynamic>[],
        'follow_ups': <dynamic>[],
      },
    });

Future<void> _pump(WidgetTester tester, String detailed) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ExplanationView(result: _result(detailed), onNext: () {}),
      ),
    ),
  );
}

void main() {
  group('Разметка разбора', () {
    testWidgets('одиночный перенос не разрывает абзац', (WidgetTester tester) async {
      // Именно так лежит текст в YAML: строки переносят по ширине файла.
      await _pump(tester, 'ORM делает один запрос\nза заказами и ещё сто за пользователями.');

      expect(
        find.text('ORM делает один запрос за заказами и ещё сто за пользователями.'),
        findsOneWidget,
      );
    });

    testWidgets('пустая строка разделяет абзацы', (WidgetTester tester) async {
      await _pump(tester, 'Первый абзац.\n\nВторой абзац.');

      expect(find.text('Первый абзац.'), findsOneWidget);
      expect(find.text('Второй абзац.'), findsOneWidget);
    });

    testWidgets('заголовок уровня прерывает абзац', (WidgetTester tester) async {
      await _pump(tester, 'Хвост абзаца\n### Middle\nЖдут конкретики.');

      expect(find.text('Хвост абзаца'), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
      expect(find.text('Ждут конкретики.'), findsOneWidget);
    });

    testWidgets('список не склеивается с абзацем', (WidgetTester tester) async {
      await _pump(tester, 'Причины:\n- индекс не покрывает условие\n- статистика устарела');

      expect(find.text('Причины:'), findsOneWidget);
      expect(find.text('индекс не покрывает условие'), findsOneWidget);
      expect(find.text('статистика устарела'), findsOneWidget);
    });
  });
}

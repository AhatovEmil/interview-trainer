import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/domain/models/grade.dart';
import 'package:interview_trainer/domain/models/profile.dart';
import 'package:interview_trainer/domain/models/question.dart';
import 'package:interview_trainer/domain/models/taxonomy.dart';

void main() {
  group('Grade', () {
    test('шкала покрывает 0–6 без пропусков', () {
      expect(Grade.all, <int>[0, 1, 2, 3, 4, 5, 6]);
      for (final int grade in Grade.all) {
        expect(Grade.title(grade), isNotEmpty);
        expect(Grade.hint(grade), isNotEmpty);
      }
    });
  });

  group('QuestionType', () {
    test('варианты ответа есть только у выборочных типов', () {
      expect(QuestionType.singleChoice.hasOptions, isTrue);
      expect(QuestionType.multiChoice.hasOptions, isTrue);
      expect(QuestionType.openAnswer.hasOptions, isFalse);
      expect(QuestionType.shortAnswer.hasOptions, isFalse);
    });

    test('несколько ответов допускает только multi_choice', () {
      expect(QuestionType.multiChoice.allowsMultiple, isTrue);
      expect(QuestionType.singleChoice.allowsMultiple, isFalse);
    });

    test('неизвестный тип с сервера не роняет разбор', () {
      expect(QuestionType.fromWire('что-то новое'), QuestionType.openAnswer);
    });
  });

  group('Разбор ответа сервера', () {
    test('вопрос', () {
      final Question question = Question.fromJson(<String, dynamic>{
        'id': '1a2b',
        'type': 'single_choice',
        'title': 'Что выведет код?',
        'topic_code': 'language',
        'topic_title': 'Язык',
        'subtopic_code': 'gil',
        'subtopic_title': 'GIL',
        'min_grade': 1,
        'peak_grade': 3,
        'max_grade': 6,
        'frequency': 5,
        'options': <dynamic>[
          <String, dynamic>{'code': 'a', 'text': 'Первый'},
          <String, dynamic>{'code': 'b', 'text': 'Второй'},
        ],
        'is_verified': false,
      });

      expect(question.type, QuestionType.singleChoice);
      expect(question.options, hasLength(2));
      expect(question.isVerified, isFalse);
      expect(question.topicTitle, 'Язык');
      expect(question.subtopicTitle, 'GIL');
    });

    test('без названия темы откатываемся на код', () {
      final Question question = Question.fromJson(<String, dynamic>{
        'id': '1a2b',
        'type': 'open_answer',
        'title': 'Что такое GIL?',
        'topic_code': 'language',
        'subtopic_code': null,
        'min_grade': 1,
        'peak_grade': 3,
        'max_grade': 6,
        'frequency': 5,
        'options': <dynamic>[],
        'is_verified': false,
      });

      expect(question.topicTitle, 'language');
      expect(question.subtopicTitle, isNull);
    });

    test('результат ответа', () {
      final AnswerResult result = AnswerResult.fromJson(<String, dynamic>{
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
          'answer_detailed': '### Junior\nТекст',
          'common_mistakes': <dynamic>['Ошибка'],
          'follow_ups': <dynamic>['Вопрос'],
        },
      });

      expect(result.isCorrect, isTrue);
      expect(result.isPartial, isFalse);
      expect(result.explanation.commonMistakes, <String>['Ошибка']);
    });

    test('частичный ответ отличается от верного и неверного', () {
      AnswerResult build(double score) => AnswerResult.fromJson(<String, dynamic>{
            'score': score,
            'quality': 3,
            'rating_before': 1200.0,
            'rating_after': 1200.0,
            'rating_delta': 0.0,
            'grade': 2,
            'grade_code': 'junior_plus',
            'difficulty_before': 1390,
            'difficulty_after': 1390,
            'next_review_at': '2026-08-09T12:00:00Z',
            'is_duplicate': false,
            'explanation': <String, dynamic>{
              'answer_short': 'a',
              'answer_detailed': 'b',
              'common_mistakes': <dynamic>[],
              'follow_ups': <dynamic>[],
            },
          });

      expect(build(0.5).isPartial, isTrue);
      expect(build(0.0).isPartial, isFalse);
      expect(build(0.0).isCorrect, isFalse);
    });
  });

  group('Таксономия', () {
    final Taxonomy taxonomy = Taxonomy.fromJson(<String, dynamic>{
      'professions': <dynamic>[
        <String, dynamic>{
          'id': 'backend',
          'title': 'Backend-разработчик',
          'specializations': <dynamic>[
            <String, dynamic>{
              'id': 'backend_python',
              'title': 'Python',
              'is_active': true,
              'topics': <dynamic>[
                <String, dynamic>{
                  'code': 'language',
                  'title': 'Язык',
                  'subtopics': <dynamic>[
                    <String, dynamic>{'code': 'gil', 'title': 'GIL'},
                  ],
                },
              ],
            },
            <String, dynamic>{
              'id': 'backend_go',
              'title': 'Go',
              'is_active': false,
              'topics': <dynamic>[],
            },
          ],
        },
      ],
      'grades': <dynamic>[
        <String, dynamic>{'value': 3, 'code': 'middle', 'title': 'Middle'},
      ],
    });

    test('активные специализации отделены от «скоро»', () {
      expect(taxonomy.activeSpecializations.map((Specialization s) => s.id), <String>[
        'backend_python',
      ]);
      expect(taxonomy.professions.first.hasActive, isTrue);
    });

    test('дерево тем разбирается на два уровня', () {
      final Specialization python = taxonomy.professions.first.specializations.first;
      expect(python.topics.first.subtopics.first.title, 'GIL');
    });
  });

  group('Статистика', () {
    PracticeStats build(String? lock) => PracticeStats.fromJson(<String, dynamic>{
          'specialization_id': 'backend_python',
          'answers_count': 5,
          'topics': <dynamic>[
            <String, dynamic>{
              'topic_code': 'db',
              'title': 'Базы данных',
              'rating': 1100.0,
              'grade': 1,
              'grade_code': 'junior',
              'answers_count': 3,
              'weight': 1.0,
            },
            <String, dynamic>{
              'topic_code': 'language',
              'title': 'Язык',
              'rating': 1500.0,
              'grade': 4,
              'grade_code': 'middle_plus',
              'answers_count': 2,
              'weight': 0.85,
            },
          ],
          'overall_rating': null,
          'overall_grade': null,
          'overall_grade_code': null,
          'locked_reason': lock,
        });

    test('причина блокировки разбирается', () {
      expect(build('not_enough_data').lock, StatsLock.notEnoughData);
      expect(build('premium_required').lock, StatsLock.premiumRequired);
      expect(build(null).lock, isNull);
    });

    test('слабые темы идут первыми', () {
      expect(build(null).weakest.first.topicCode, 'db');
    });
  });
}

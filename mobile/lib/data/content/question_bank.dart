import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/models/question.dart';
import '../../domain/models/taxonomy.dart';

/// Банк вопросов и таксономия из ресурсов приложения.
///
/// Сервера у приложения нет: контент едет внутри установочного пакета и
/// собирается из /content командой `python -m app.seed.export_bundle`.
///
/// Файл читается один раз за запуск и остаётся в памяти. Это 2,5 МБ разобранного
/// JSON — заметно меньше, чем стоило бы обращение к базе на каждый вопрос, и
/// не требует ни таблицы, ни миграций для неизменяемых данных.
class QuestionBank {
  QuestionBank._({
    required this.taxonomy,
    required List<BankQuestion> questions,
  })  : _questions = questions,
        _byId = <String, BankQuestion>{
          for (final BankQuestion question in questions) question.question.id: question,
        };

  static const String assetPath = 'assets/content/bank.json';

  final Taxonomy taxonomy;
  final List<BankQuestion> _questions;
  final Map<String, BankQuestion> _byId;

  static QuestionBank? _instance;

  /// Загружает банк один раз за запуск приложения.
  static Future<QuestionBank> load() async {
    final QuestionBank? cached = _instance;
    if (cached != null) {
      return cached;
    }
    final String raw = await rootBundle.loadString(assetPath);
    final QuestionBank bank = parse(raw);
    _instance = bank;
    return bank;
  }

  /// Разбор без обращения к ресурсам — точка входа для тестов.
  static QuestionBank parse(String raw) {
    final Map<String, dynamic> payload = jsonDecode(raw) as Map<String, dynamic>;
    return QuestionBank._(
      taxonomy: Taxonomy.fromJson(payload['taxonomy'] as Map<String, dynamic>),
      questions: (payload['questions'] as List<dynamic>)
          .map((dynamic item) => BankQuestion.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  /// Сбрасывает загруженный экземпляр. Нужен тестам, чтобы один прогон не
  /// подсовывал банк другому.
  static void reset() => _instance = null;

  List<BankQuestion> forSpecialization(String specializationId) => _questions
      .where((BankQuestion item) => item.specializations.contains(specializationId))
      .toList(growable: false);

  BankQuestion? byId(String questionId) => _byId[questionId];

  /// Веса разделов для грейда: по ним считается оценка уровня и приоритет тем.
  Map<String, double> topicWeights(String specializationId, int grade) {
    final Specialization? specialization = _specialization(specializationId);
    if (specialization == null) {
      return const <String, double>{};
    }
    return <String, double>{
      for (final Topic topic in specialization.topics) topic.code: topic.weightFor(grade),
    };
  }

  Map<String, String> topicTitles(String specializationId) {
    final Specialization? specialization = _specialization(specializationId);
    if (specialization == null) {
      return const <String, String>{};
    }
    return <String, String>{
      for (final Topic topic in specialization.topics) topic.code: topic.title,
    };
  }

  Specialization? _specialization(String specializationId) {
    for (final Profession profession in taxonomy.professions) {
      for (final Specialization specialization in profession.specializations) {
        if (specialization.id == specializationId) {
          return specialization;
        }
      }
    }
    return null;
  }
}

/// Вопрос банка вместе с разбором и служебными полями.
///
/// Отдельно от [Question] потому, что разбор не должен попадать на экран до
/// ответа: карточка получает только `question`, а `explanation` открывается
/// после самооценки.
class BankQuestion {
  const BankQuestion({
    required this.question,
    required this.specializations,
    required this.difficultyRating,
    required this.explanation,
  });

  final Question question;
  final List<String> specializations;

  /// Стартовая сложность из пикового грейда. На устройстве она не меняется:
  /// накопленной по всем пользователям статистики здесь нет, и двигать её по
  /// одному человеку значило бы искажать шкалу.
  final int difficultyRating;

  final QuestionExplanation explanation;

  factory BankQuestion.fromJson(Map<String, dynamic> json) => BankQuestion(
        question: Question.fromJson(json),
        specializations: (json['specializations'] as List<dynamic>).cast<String>(),
        difficultyRating: json['difficulty_rating'] as int,
        explanation: QuestionExplanation.fromJson(json),
      );
}

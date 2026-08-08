import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/question.dart';
import 'app_database.dart';

/// Перевод между пакетом с сервера, строкой Drift и доменной моделью.
///
/// Списки хранятся строками JSON: заводить отдельные таблицы под варианты и
/// частые ошибки незачем — они всегда читаются вместе с вопросом.
class QuestionMapper {
  const QuestionMapper();

  CachedQuestionsCompanion fromWire(Map<String, dynamic> json, String specializationId) =>
      CachedQuestionsCompanion.insert(
        id: json['id'] as String,
        specializationId: specializationId,
        type: json['type'] as String,
        title: json['title'] as String,
        topicCode: json['topic_code'] as String,
        topicTitle: json['topic_title'] as String? ?? json['topic_code'] as String,
        subtopicCode: Value<String?>(json['subtopic_code'] as String?),
        subtopicTitle: Value<String?>(json['subtopic_title'] as String?),
        minGrade: json['min_grade'] as int,
        peakGrade: json['peak_grade'] as int,
        maxGrade: json['max_grade'] as int,
        frequency: json['frequency'] as int,
        optionsJson: jsonEncode(json['options'] ?? <dynamic>[]),
        isVerified: json['is_verified'] as bool,
        answerShort: json['answer_short'] as String,
        answerDetailed: json['answer_detailed'] as String,
        commonMistakesJson: jsonEncode(json['common_mistakes'] ?? <dynamic>[]),
        followUpsJson: jsonEncode(json['follow_ups'] ?? <dynamic>[]),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Question toQuestion(CachedQuestion row) => Question(
        id: row.id,
        type: QuestionType.fromWire(row.type),
        title: row.title,
        topicCode: row.topicCode,
        topicTitle: row.topicTitle,
        subtopicCode: row.subtopicCode,
        subtopicTitle: row.subtopicTitle,
        minGrade: row.minGrade,
        peakGrade: row.peakGrade,
        maxGrade: row.maxGrade,
        frequency: row.frequency,
        options: _decodeList(row.optionsJson)
            .map((dynamic item) => QuestionOption.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
        isVerified: row.isVerified,
      );

  QuestionExplanation toExplanation(CachedQuestion row) => QuestionExplanation(
        answerShort: row.answerShort,
        answerDetailed: row.answerDetailed,
        commonMistakes: _decodeStrings(row.commonMistakesJson),
        followUps: _decodeStrings(row.followUpsJson),
      );

  List<dynamic> _decodeList(String raw) => jsonDecode(raw) as List<dynamic>;

  List<String> _decodeStrings(String raw) =>
      _decodeList(raw).map((dynamic item) => item as String).toList(growable: false);
}

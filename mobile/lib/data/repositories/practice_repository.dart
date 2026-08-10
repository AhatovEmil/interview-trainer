import '../../core/network/api_client.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/question.dart';
import '../../domain/models/question_list.dart';
import '../../domain/models/question_report.dart';
import '../../domain/models/taxonomy.dart';

class PracticeRepository {
  const PracticeRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<Taxonomy> taxonomy() async =>
      Taxonomy.fromJson(await _client.get('/taxonomy', skipAuth: true));

  Future<NextQuestion> next(String specialization) async => NextQuestion.fromJson(
        await _client.get(
          '/practice/next',
          query: <String, dynamic>{'specialization': specialization},
        ),
      );

  /// [submissionId] генерирует клиент: повтор при ретрае не двигает рейтинг дважды.
  Future<AnswerResult> answer({
    required String submissionId,
    required String questionId,
    required String specializationId,
    List<String> selectedOptions = const <String>[],
    int? selfAssessment,
    String? freeText,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'submission_id': submissionId,
      'question_id': questionId,
      'specialization_id': specializationId,
      if (selectedOptions.isNotEmpty) 'selected_options': selectedOptions,
      if (selfAssessment != null) 'self_assessment': selfAssessment,
      if (freeText != null && freeText.isNotEmpty) 'free_text': freeText,
    };
    return AnswerResult.fromJson(await _client.post('/practice/answer', body: body));
  }

  /// Все вопросы специализации с отметкой, как они закрыты.
  Future<QuestionListSummary> questions(String specialization) async =>
      QuestionListSummary.fromJson(
        await _client.get(
          '/practice/questions',
          query: <String, dynamic>{'specialization': specialization},
        ),
      );

  /// Конкретный вопрос, открытый из списка вручную.
  Future<NextQuestion> questionById(String specialization, String questionId) async =>
      NextQuestion.fromJson(
        await _client.get(
          '/practice/questions/$questionId',
          query: <String, dynamic>{'specialization': specialization},
        ),
      );

  Future<PracticeStats> stats(String specialization) async => PracticeStats.fromJson(
        await _client.get(
          '/practice/stats',
          query: <String, dynamic>{'specialization': specialization},
        ),
      );

  /// Вопрос с реального собеседования. В банк не попадает: уходит на модерацию.
  Future<QuestionReportResult> reportQuestion({
    required String specializationId,
    required String title,
    String? topicCode,
    String? details,
    String? company,
    int? askedGrade,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'specialization_id': specializationId,
      'title': title,
      if (topicCode != null) 'topic_code': topicCode,
      if (details != null && details.isNotEmpty) 'details': details,
      if (company != null && company.isNotEmpty) 'company': company,
      if (askedGrade != null) 'asked_grade': askedGrade,
    };
    return QuestionReportResult.fromJson(
      await _client.post('/questions/report', body: body),
    );
  }
}

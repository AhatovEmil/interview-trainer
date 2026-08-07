import '../../core/network/api_client.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/question.dart';
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

  Future<PracticeStats> stats(String specialization) async => PracticeStats.fromJson(
        await _client.get(
          '/practice/stats',
          query: <String, dynamic>{'specialization': specialization},
        ),
      );
}

/// Результат отправки вопроса с собеседования.
///
/// В банк присланное не попадает: сервер кладёт его в очередь модерации, и
/// экран обязан говорить об этом прямо — иначе пользователь ждёт свой вопрос
/// в списке и не находит.
class QuestionReportResult {
  const QuestionReportResult({
    required this.id,
    required this.status,
    required this.title,
    required this.isDuplicate,
  });

  final String id;
  final String status;
  final String title;

  /// Такой вопрос от этого пользователя уже был — новой записи не создалось.
  final bool isDuplicate;

  factory QuestionReportResult.fromJson(Map<String, dynamic> json) => QuestionReportResult(
        id: json['id'] as String,
        status: json['status'] as String,
        title: json['title'] as String,
        isDuplicate: json['is_duplicate'] as bool? ?? false,
      );
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/repositories/offline_practice_repository.dart';
import '../../domain/models/question.dart';
import '../providers.dart';

enum PracticePhase { loading, answering, reviewing, exhausted, failed }

@immutable
class PracticeState {
  const PracticeState({
    this.phase = PracticePhase.loading,
    this.current,
    this.result,
    this.error,
    this.answeredInSession = 0,
    this.isSubmitting = false,
  });

  final PracticePhase phase;
  final NextQuestion? current;
  final AnswerResult? result;
  final String? error;
  final int answeredInSession;
  final bool isSubmitting;

  PracticeState copyWith({
    PracticePhase? phase,
    NextQuestion? current,
    AnswerResult? result,
    String? error,
    int? answeredInSession,
    bool? isSubmitting,
    bool clearResult = false,
  }) =>
      PracticeState(
        phase: phase ?? this.phase,
        current: current ?? this.current,
        result: clearResult ? null : (result ?? this.result),
        error: error,
        answeredInSession: answeredInSession ?? this.answeredInSession,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

class PracticeController extends StateNotifier<PracticeState> {
  PracticeController(
    this._repository,
    this._specialization,
    this._grade, {
    String? questionId,
  })  : _fixedQuestionId = questionId,
        super(const PracticeState()) {
    loadNext();
  }

  final OfflinePracticeRepository _repository;
  final String _specialization;

  /// Самооценка грейда: офлайн по ней отбираются вопросы, потому что серверную
  /// оценку без сети не спросить.
  final int _grade;

  /// Задан, когда вопрос открыт из списка вручную. Тогда «следующий вопрос»
  /// не подбирается: экран показывает ровно то, что человек выбрал.
  final String? _fixedQuestionId;

  bool get isSingleQuestion => _fixedQuestionId != null;

  /// Идентификатор попытки живёт, пока пользователь отвечает на этот вопрос:
  /// ретрай отправки не должен посчитаться вторым ответом.
  String? _submissionId;

  Future<void> loadNext() async {
    state = state.copyWith(phase: PracticePhase.loading, clearResult: true);
    try {
      final String? fixed = _fixedQuestionId;
      final NextQuestion next = fixed == null
          ? await _repository.next(_specialization, grade: _grade)
          : await _repository.questionById(_specialization, fixed);
      _submissionId = _repository.newSubmissionId();
      state = state.copyWith(phase: PracticePhase.answering, current: next);
    } on ApiException catch (error) {
      state = state.copyWith(
        phase: error.isNotFound ? PracticePhase.exhausted : PracticePhase.failed,
        error: error.message,
      );
    } on OfflineExhaustedException catch (error) {
      state = state.copyWith(phase: PracticePhase.exhausted, error: error.toString());
    } on Object catch (error) {
      state = state.copyWith(phase: PracticePhase.failed, error: error.toString());
    }
  }

  Future<void> submit({
    List<String> selectedOptions = const <String>[],
    int? selfAssessment,
  }) async {
    final NextQuestion? current = state.current;
    final String? submissionId = _submissionId;
    if (current == null || submissionId == null || state.isSubmitting) {
      return;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final AnswerResult result = await _repository.answer(
        submissionId: submissionId,
        questionId: current.question.id,
        specializationId: _specialization,
        selectedOptions: selectedOptions,
        selfAssessment: selfAssessment,
      );
      state = state.copyWith(
        phase: PracticePhase.reviewing,
        result: result,
        isSubmitting: false,
        answeredInSession: state.answeredInSession + (result.isDuplicate ? 0 : 1),
      );
    } on Object catch (error) {
      state = state.copyWith(isSubmitting: false, error: error.toString());
      rethrow;
    }
  }

}

/// Ключ сессии тренировки.
///
/// `questionId` пуст для обычной адаптивной выдачи и заполнен, когда вопрос
/// открыт из списка. Это разные экземпляры контроллера: возврат из конкретного
/// вопроса не должен сбивать ленту, которую человек проходил до этого.
typedef PracticeKey = ({String specialization, String? questionId});

final StateNotifierProviderFamily<PracticeController, PracticeState, PracticeKey>
    practiceProvider =
    StateNotifierProvider.family<PracticeController, PracticeState, PracticeKey>(
  (Ref ref, PracticeKey key) => PracticeController(
    ref.watch(offlinePracticeRepositoryProvider),
    key.specialization,
    ref.watch(sessionProvider).profile?.primary?.selfAssessedGrade ?? 3,
    questionId: key.questionId,
  ),
);

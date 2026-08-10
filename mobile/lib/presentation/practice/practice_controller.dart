import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/practice_service.dart';
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
    this._service,
    this._specialization, {
    String? questionId,
  })  : _fixedQuestionId = questionId,
        super(const PracticeState()) {
    loadNext();
  }

  final PracticeService _service;
  final String _specialization;

  /// Задан, когда вопрос открыт из списка вручную. Тогда «следующий вопрос»
  /// не подбирается: экран показывает ровно то, что человек выбрал.
  final String? _fixedQuestionId;

  bool get isSingleQuestion => _fixedQuestionId != null;

  /// Идентификатор попытки живёт, пока человек отвечает на этот вопрос:
  /// повторное нажатие не должно посчитаться вторым ответом.
  String _submissionId = '';

  /// Пропустить вопрос, не отвечая.
  ///
  /// Нужен, когда вопрос не про то, к чему человек готовится прямо сейчас.
  /// Ответ не записывается: пропуск — не «не знаю», и в оценку уровня он
  /// попадать не должен. Вопрос вернётся позже, в обычном порядке.
  Future<void> skip() => loadNext(skipCurrent: true);

  Future<void> loadNext({bool skipCurrent = false}) async {
    final String? skipId = skipCurrent ? state.current?.question.id : null;
    state = state.copyWith(phase: PracticePhase.loading, clearResult: true);
    try {
      final String? fixed = _fixedQuestionId;
      final NextQuestion? next = fixed == null
          ? await _service.nextQuestion(_specialization, skipId: skipId)
          : await _service.questionById(_specialization, fixed);

      if (next == null) {
        state = state.copyWith(phase: PracticePhase.exhausted);
        return;
      }

      _submissionId = DateTime.now().microsecondsSinceEpoch.toString();
      state = state.copyWith(phase: PracticePhase.answering, current: next);
    } on Object catch (error) {
      state = state.copyWith(phase: PracticePhase.failed, error: error.toString());
    }
  }

  Future<void> submit({
    List<String> selectedOptions = const <String>[],
    int? selfAssessment,
  }) async {
    final NextQuestion? current = state.current;
    if (current == null || state.isSubmitting) {
      return;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final AnswerResult result = await _service.submitAnswer(
        specializationId: _specialization,
        submissionId: _submissionId,
        questionId: current.question.id,
        selectedOptions: selectedOptions,
        selfAssessment: selfAssessment,
      );
      state = state.copyWith(
        phase: PracticePhase.reviewing,
        result: result,
        isSubmitting: false,
        answeredInSession: state.answeredInSession + 1,
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
    ref.watch(practiceServiceProvider),
    key.specialization,
    questionId: key.questionId,
  ),
);

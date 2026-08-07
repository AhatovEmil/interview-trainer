import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/repositories/practice_repository.dart';
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
  PracticeController(this._repository, this._specialization) : super(const PracticeState()) {
    loadNext();
  }

  final PracticeRepository _repository;
  final String _specialization;
  final Random _random = Random.secure();

  /// Идентификатор попытки живёт, пока пользователь отвечает на этот вопрос:
  /// ретрай отправки не должен посчитаться вторым ответом.
  String? _submissionId;

  Future<void> loadNext() async {
    state = state.copyWith(phase: PracticePhase.loading, clearResult: true);
    try {
      final NextQuestion next = await _repository.next(_specialization);
      _submissionId = _newSubmissionId();
      state = state.copyWith(phase: PracticePhase.answering, current: next);
    } on ApiException catch (error) {
      state = state.copyWith(
        phase: error.isNotFound ? PracticePhase.exhausted : PracticePhase.failed,
        error: error.message,
      );
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

  String _newSubmissionId() {
    // UUID v4 без внешней зависимости: 122 случайных бита плюс версия и вариант.
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final String hex =
        bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}'
        '-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

final StateNotifierProviderFamily<PracticeController, PracticeState, String> practiceProvider =
    StateNotifierProvider.family<PracticeController, PracticeState, String>(
  (Ref ref, String specialization) => PracticeController(
    ref.watch(practiceRepositoryProvider),
    specialization,
  ),
);

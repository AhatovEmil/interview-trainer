import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content/question_bank.dart';
import '../data/local/app_database.dart';
import '../data/local/plan_service.dart';
import '../data/local/practice_service.dart';
import '../domain/models/profile.dart';
import '../domain/models/question_list.dart';
import '../domain/models/taxonomy.dart';

/// Банк вопросов из ресурсов приложения.
///
/// Загружается в main до запуска интерфейса и подставляется сюда переопределением:
/// иначе каждый экран, которому нужен вопрос, ждал бы разбора файла и обрастал
/// состоянием загрузки. Разбор занимает доли секунды один раз за запуск.
final Provider<QuestionBank> questionBankProvider = Provider<QuestionBank>(
  (Ref ref) => throw UnimplementedError('банк подставляется в main через override'),
);

/// Локальная база живёт всё время работы приложения: открывать её на каждый
/// запрос дорого, а держать несколько подключений к одному файлу нельзя.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<PracticeService> practiceServiceProvider = Provider<PracticeService>(
  (Ref ref) => PracticeService(
    database: ref.watch(appDatabaseProvider),
    bank: ref.watch(questionBankProvider),
  ),
);

final Provider<PlanService> planServiceProvider = Provider<PlanService>(
  (Ref ref) => PlanService(
    database: ref.watch(appDatabaseProvider),
    bank: ref.watch(questionBankProvider),
  ),
);

final Provider<Taxonomy> taxonomyProvider =
    Provider<Taxonomy>((Ref ref) => ref.watch(questionBankProvider).taxonomy);

/// Состояние приложения: от него зависит, куда пускает роутер.
///
/// Аккаунтов нет, поэтому состояний три: ещё не знаем, нужен онбординг,
/// готовы работать. Экрана входа больше не существует.
enum SessionStatus { unknown, needsOnboarding, ready }

@immutable
class SessionState {
  const SessionState({this.status = SessionStatus.unknown, this.profile});

  final SessionStatus status;
  final UserSpecialization? profile;

  String? get specializationId => profile?.specializationId;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._ref) : super(const SessionState());

  final Ref _ref;

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  /// Вызывается на старте: решает, показывать онбординг или главный экран.
  Future<void> restore() async {
    final Profile? profile = await _db.primaryProfile();
    state = profile == null
        ? const SessionState(status: SessionStatus.needsOnboarding)
        : SessionState(status: SessionStatus.ready, profile: _toModel(profile));
  }

  Future<void> refreshProfile() => restore();

  /// Выбор специализации и уровня. Используется онбордингом, сменой стека и
  /// сменой уровня — все три случая пишут одну и ту же строку профиля.
  Future<void> completeOnboarding({
    required String specializationId,
    required int targetGrade,
  }) async {
    await _db.saveProfile(specializationId: specializationId, targetGrade: targetGrade);
    await restore();
  }

  /// Полное стирание прогресса.
  ///
  /// Аккаунта нет, стирать нечего кроме локальных данных — но само действие
  /// нужно: устройство может смениться владельцем, и чужие ответы ему
  /// доставаться не должны.
  Future<void> wipeProgress() async {
    await _db.wipe();
    state = const SessionState(status: SessionStatus.needsOnboarding);
  }

  static UserSpecialization _toModel(Profile profile) => UserSpecialization(
        specializationId: profile.specializationId,
        targetGrade: profile.targetGrade,
        isPrimary: profile.isPrimary,
        answersCount: profile.answersCount,
      );
}

final StateNotifierProvider<SessionNotifier, SessionState> sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((Ref ref) => SessionNotifier(ref));

final FutureProviderFamily<PracticeStats, String> statsProvider =
    FutureProvider.family<PracticeStats, String>(
  (Ref ref, String specialization) => ref.watch(practiceServiceProvider).stats(specialization),
);

/// Список вопросов с отметками о прохождении.
final FutureProviderFamily<QuestionListSummary, String> questionListProvider =
    FutureProvider.family<QuestionListSummary, String>(
  (Ref ref, String specialization) =>
      ref.watch(practiceServiceProvider).questionList(specialization),
);

/// Что делать сегодня по плану. `null` — активного плана нет.
final FutureProviderFamily<TodayPlan?, String> todayPlanProvider =
    FutureProvider.family<TodayPlan?, String>(
  (Ref ref, String specialization) => ref.watch(planServiceProvider).today(specialization),
);

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../data/local/app_database.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/offline_practice_repository.dart';
import '../data/repositories/practice_repository.dart';
import '../data/sync/sync_controller.dart';
import '../data/sync/sync_service.dart';
import '../domain/models/profile.dart';
import '../domain/models/taxonomy.dart';

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((Ref ref) => TokenStorage());

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((Ref ref) {
  final ApiClient client = ApiClient(tokens: ref.watch(tokenStorageProvider));
  client.onSessionExpired = () => ref.read(sessionProvider.notifier).forceLogout();
  return client;
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (Ref ref) => AuthRepository(
    client: ref.watch(apiClientProvider),
    tokens: ref.watch(tokenStorageProvider),
  ),
);

final Provider<PracticeRepository> practiceRepositoryProvider = Provider<PracticeRepository>(
  (Ref ref) => PracticeRepository(client: ref.watch(apiClientProvider)),
);

/// Локальная база живёт всё время работы приложения: открывать её на каждый
/// запрос дорого, а держать несколько подключений к одному файлу нельзя.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<SyncService> syncServiceProvider = Provider<SyncService>(
  (Ref ref) => SyncService(
    client: ref.watch(apiClientProvider),
    database: ref.watch(appDatabaseProvider),
  ),
);

final Provider<OfflinePracticeRepository> offlinePracticeRepositoryProvider =
    Provider<OfflinePracticeRepository>(
  (Ref ref) => OfflinePracticeRepository(
    remote: ref.watch(practiceRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
    sync: ref.watch(syncServiceProvider),
  ),
);

/// Сколько ответов ждут отправки. Поток из Drift: индикатор обновляется сам.
final StreamProvider<int> pendingAnswersProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(appDatabaseProvider).watchPendingCount(),
);

/// Следит за сетью и досылает накопленное. Создаётся на специализацию, потому
/// что пакет вопросов скачивается для каждой отдельно.
final ProviderFamily<SyncController, String> syncControllerProvider =
    Provider.family<SyncController, String>((Ref ref, String specialization) {
  final SyncController controller = SyncController(
    service: ref.watch(syncServiceProvider),
    specializationId: specialization,
  );
  ref.onDispose(controller.dispose);
  return controller;
});

/// Состояние сессии: от него зависит, куда пускает роутер.
enum SessionStatus { unknown, signedOut, needsOnboarding, ready }

@immutable
class SessionState {
  const SessionState({this.status = SessionStatus.unknown, this.profile});

  final SessionStatus status;
  final UserProfile? profile;

  String? get specializationId => profile?.primary?.specializationId;

  SessionState copyWith({SessionStatus? status, UserProfile? profile}) => SessionState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
      );
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier(this._ref) : super(const SessionState());

  final Ref _ref;

  AuthRepository get _auth => _ref.read(authRepositoryProvider);

  /// Вызывается на старте: решает, показывать вход, онбординг или тренировку.
  Future<void> restore() async {
    if (!await _auth.hasSession) {
      state = const SessionState(status: SessionStatus.signedOut);
      return;
    }
    await refreshProfile();
  }

  Future<void> refreshProfile() async {
    try {
      final UserProfile profile = await _auth.me();
      await _ref.read(appDatabaseProvider).saveProfile(jsonEncode(profile.toJson()));
      state = SessionState(
        status: profile.isOnboarded ? SessionStatus.ready : SessionStatus.needsOnboarding,
        profile: profile,
      );
    } on ApiException catch (error) {
      // Нет сети — это не «сессия недействительна». Токены на месте, работаем
      // по последнему известному профилю, иначе офлайн-режим недостижим:
      // приложение выкидывало бы на экран входа при каждом запуске в метро.
      if (error.isNetworkIssue) {
        final UserProfile? cached = await _cachedProfile();
        if (cached != null) {
          state = SessionState(
            status: cached.isOnboarded ? SessionStatus.ready : SessionStatus.needsOnboarding,
            profile: cached,
          );
          return;
        }
      }
      state = const SessionState(status: SessionStatus.signedOut);
    } on Object {
      state = const SessionState(status: SessionStatus.signedOut);
    }
  }

  Future<UserProfile?> _cachedProfile() async {
    final String? payload = await _ref.read(appDatabaseProvider).loadProfile();
    if (payload == null) {
      return null;
    }
    try {
      return UserProfile.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> register({required String email, required String password}) async {
    await _auth.register(email: email, password: password);
    await refreshProfile();
  }

  Future<void> login({required String email, required String password}) async {
    await _auth.login(email: email, password: password);
    await refreshProfile();
  }

  Future<void> completeOnboarding({
    required String specializationId,
    required int grade,
  }) async {
    final UserProfile profile = await _auth.setSpecialization(
      specializationId: specializationId,
      selfAssessedGrade: grade,
    );
    state = SessionState(status: SessionStatus.ready, profile: profile);
  }

  Future<void> logout() async {
    // Скачанный банк и локальные ответы — данные конкретного человека.
    // Следующему владельцу устройства они доставаться не должны.
    await _ref.read(appDatabaseProvider).wipe();
    await _auth.logout();
    state = const SessionState(status: SessionStatus.signedOut);
  }

  void forceLogout() {
    state = const SessionState(status: SessionStatus.signedOut);
  }
}

final StateNotifierProvider<SessionNotifier, SessionState> sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((Ref ref) => SessionNotifier(ref));

final FutureProvider<Taxonomy> taxonomyProvider = FutureProvider<Taxonomy>(
  (Ref ref) => ref.watch(practiceRepositoryProvider).taxonomy(),
);

final FutureProviderFamily<PracticeStats, String> statsProvider =
    FutureProvider.family<PracticeStats, String>(
  (Ref ref, String specialization) =>
      ref.watch(practiceRepositoryProvider).stats(specialization),
);

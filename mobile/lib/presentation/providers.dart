import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/practice_repository.dart';
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
      state = SessionState(
        status: profile.isOnboarded ? SessionStatus.ready : SessionStatus.needsOnboarding,
        profile: profile,
      );
    } on Object {
      state = const SessionState(status: SessionStatus.signedOut);
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

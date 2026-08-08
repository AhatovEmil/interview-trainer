import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interview_trainer/core/network/api_client.dart';
import 'package:interview_trainer/core/network/api_exception.dart';
import 'package:interview_trainer/core/storage/token_storage.dart';
import 'package:interview_trainer/data/local/app_database.dart';
import 'package:interview_trainer/data/repositories/auth_repository.dart';
import 'package:interview_trainer/domain/models/profile.dart';
import 'package:interview_trainer/presentation/providers.dart';

/// Профиль, каким его вернул бы сервер.
final Map<String, dynamic> _profileJson = <String, dynamic>{
  'id': 'user-1',
  'email': 'user@example.com',
  'is_premium': false,
  'specializations': <Map<String, dynamic>>[
    <String, dynamic>{
      'specialization_id': 'backend_python',
      'self_assessed_grade': 3,
      'grade_code': 'middle',
      'is_primary': true,
      'answers_count': 12,
    },
  ],
};

class _StubAuth extends AuthRepository {
  _StubAuth({required this.failure, this.profile})
      : super(client: _UnusedClient(), tokens: TokenStorage());

  /// Что случится при обращении к /me.
  final Object? failure;
  final Map<String, dynamic>? profile;

  @override
  Future<bool> get hasSession async => true;

  /// Настоящий TokenStorage лезет в flutter_secure_storage, а в юнит-тестах
  /// платформенных каналов нет.
  @override
  Future<void> logout() async {}

  @override
  Future<UserProfile> me() async {
    if (failure != null) {
      throw failure!;
    }
    return UserProfile.fromJson(profile!);
  }
}

/// Сетевые вызовы в этих тестах не происходят: клиент нужен лишь конструктору.
class _UnusedClient implements ApiClient {
  @override
  void Function()? onSessionExpired;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> post(String path, {Object? body, bool skipAuth = false}) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> patch(String path, {Object? body, bool skipAuth = false}) =>
      throw UnimplementedError();
}

ProviderContainer _container({
  required AppDatabase database,
  required AuthRepository auth,
}) =>
    ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(database),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => database.close());

  test('успешный вход кеширует профиль', () async {
    final ProviderContainer container = _container(
      database: database,
      auth: _StubAuth(failure: null, profile: _profileJson),
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();

    expect(container.read(sessionProvider).status, SessionStatus.ready);
    expect(await database.loadProfile(), isNotNull);
  });

  test(
    'без сети остаёмся в сессии по сохранённому профилю',
    () async {
      // Регрессия: приложение выкидывало на экран входа при каждом запуске
      // без сети, и офлайн-режим был недостижим.
      await database.saveProfile(jsonEncode(_profileJson));

      final ProviderContainer container = _container(
        database: database,
        auth: _StubAuth(
          failure: const ApiException('Не удаётся связаться с сервером. Проверьте подключение.'),
        ),
      );
      addTearDown(container.dispose);

      await container.read(sessionProvider.notifier).restore();

      final SessionState state = container.read(sessionProvider);
      expect(state.status, SessionStatus.ready);
      expect(state.specializationId, 'backend_python');
      expect(state.profile?.primary?.selfAssessedGrade, 3);
    },
  );

  test('без сети и без кеша — на экран входа', () async {
    final ProviderContainer container = _container(
      database: database,
      auth: _StubAuth(failure: const ApiException('нет сети')),
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();

    expect(container.read(sessionProvider).status, SessionStatus.signedOut);
  });

  test('протухшая сессия разлогинивает даже при наличии кеша', () async {
    // 401 — сервер ответил и сказал «не пущу». Кеш тут не оправдание.
    await database.saveProfile(jsonEncode(_profileJson));

    final ProviderContainer container = _container(
      database: database,
      auth: _StubAuth(
        failure: const ApiException('Сессия истекла, войдите заново', statusCode: 401),
      ),
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).restore();

    expect(container.read(sessionProvider).status, SessionStatus.signedOut);
  });

  test('выход стирает кеш профиля', () async {
    await database.saveProfile(jsonEncode(_profileJson));

    final ProviderContainer container = _container(
      database: database,
      auth: _StubAuth(failure: null, profile: _profileJson),
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).logout();

    expect(await database.loadProfile(), isNull);
    expect(container.read(sessionProvider).status, SessionStatus.signedOut);
  });
}

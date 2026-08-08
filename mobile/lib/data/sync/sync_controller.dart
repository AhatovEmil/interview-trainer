import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'sync_service.dart';

@immutable
class SyncStatus {
  const SyncStatus({
    this.isRunning = false,
    this.lastOutcome,
    this.isOnline = true,
  });

  final bool isRunning;
  final SyncOutcome? lastOutcome;
  final bool isOnline;

  SyncStatus copyWith({
    bool? isRunning,
    SyncOutcome? lastOutcome,
    bool? isOnline,
  }) =>
      SyncStatus(
        isRunning: isRunning ?? this.isRunning,
        lastOutcome: lastOutcome ?? this.lastOutcome,
        isOnline: isOnline ?? this.isOnline,
      );
}

/// Досылает накопленное, когда сеть возвращается.
///
/// Сигнал connectivity_plus говорит лишь о наличии интерфейса — Wi-Fi в метро
/// без выхода наружу выглядит как «сеть есть». Поэтому он только повод
/// попробовать; успех определяет сам запрос.
class SyncController extends ValueNotifier<SyncStatus> {
  SyncController({
    required SyncService service,
    required String specializationId,
    Connectivity? connectivity,
  })  : _service = service,
        _specializationId = specializationId,
        _connectivity = connectivity ?? Connectivity(),
        super(const SyncStatus()) {
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  final SyncService _service;
  final String _specializationId;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Синхронизация уже идёт — второй запуск только удвоил бы трафик.
  Future<void>? _inFlight;

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final bool online =
        results.any((ConnectivityResult result) => result != ConnectivityResult.none);
    value = value.copyWith(isOnline: online);
    if (online) {
      await syncNow();
    }
  }

  Future<void> syncNow() {
    return _inFlight ??= _run().whenComplete(() => _inFlight = null);
  }

  Future<void> _run() async {
    value = value.copyWith(isRunning: true);
    final SyncOutcome outcome = await _service.sync(_specializationId);
    value = SyncStatus(
      isRunning: false,
      lastOutcome: outcome,
      isOnline: value.isOnline,
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

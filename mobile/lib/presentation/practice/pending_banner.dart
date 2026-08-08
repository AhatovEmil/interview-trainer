import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plural.dart';
import '../../data/sync/sync_controller.dart';
import '../providers.dart';

/// Полоска о неотправленных ответах.
///
/// Появляется только когда есть что отправлять: в обычной жизни пользователь
/// про синхронизацию знать не должен.
class PendingBanner extends ConsumerWidget {
  const PendingBanner({required this.specialization, super.key});

  final String specialization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pending = ref.watch(pendingAnswersProvider).valueOrNull ?? 0;
    if (pending == 0) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final SyncController controller = ref.watch(syncControllerProvider(specialization));

    return ValueListenableBuilder<SyncStatus>(
      valueListenable: controller,
      builder: (BuildContext context, SyncStatus status, _) => Material(
        color: theme.colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(
                status.isRunning ? Icons.sync : Icons.cloud_off_outlined,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status.isRunning
                      ? 'Отправляем ответы…'
                      : '${withPlural(pending, 'ответ', 'ответа', 'ответов')} '
                          '${pending == 1 ? 'ждёт' : 'ждут'} отправки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              if (!status.isRunning)
                TextButton(
                  onPressed: controller.syncNow,
                  child: const Text('Отправить'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

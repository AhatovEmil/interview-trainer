import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plural.dart';
import '../../core/theme/app_colors.dart';
import '../../data/sync/sync_controller.dart';
import '../providers.dart';

/// Полоска о неотправленных ответах.
///
/// Появляется только когда есть что отправлять: в обычной жизни пользователь
/// про синхронизацию знать не должен. Тон нейтральный — это состояние, а не
/// ошибка, и красный здесь пугал бы без причины.
class PendingBanner extends ConsumerWidget {
  const PendingBanner({required this.specialization, super.key});

  final String specialization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pending = ref.watch(pendingAnswersProvider).valueOrNull ?? 0;
    final AppColors colors = context.colors;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: pending == 0
          ? const SizedBox(width: double.infinity)
          : _Banner(specialization: specialization, pending: pending, colors: colors),
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({
    required this.specialization,
    required this.pending,
    required this.colors,
  });

  final String specialization;
  final int pending;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final SyncController controller = ref.watch(syncControllerProvider(specialization));

    return ValueListenableBuilder<SyncStatus>(
      valueListenable: controller,
      builder: (BuildContext context, SyncStatus status, _) => Container(
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          border: Border(bottom: BorderSide(color: colors.hairline)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 16,
              height: 16,
              child: status.isRunning
                  ? CircularProgressIndicator(strokeWidth: 2, color: colors.inkMuted)
                  : Icon(Icons.cloud_off_rounded, size: 16, color: colors.inkMuted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status.isRunning
                    ? 'Отправляем ответы…'
                    : '${withPlural(pending, 'ответ', 'ответа', 'ответов')} '
                        '${pending == 1 ? 'ждёт' : 'ждут'} отправки',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
              ),
            ),
            if (!status.isRunning)
              TextButton(
                onPressed: controller.syncNow,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: theme.textTheme.labelMedium,
                ),
                child: const Text('Отправить'),
              ),
          ],
        ),
      ),
    );
  }
}

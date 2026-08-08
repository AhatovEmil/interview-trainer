import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../common/async_button.dart';
import '../providers.dart';
import 'explanation_view.dart';
import 'pending_banner.dart';
import 'practice_controller.dart';
import 'question_card.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  bool _syncStarted = false;

  /// Первая синхронизация при входе в тренировку: скачивает банк, чтобы в
  /// метро было чем заниматься, и доносит то, что осталось с прошлого раза.
  void _startSyncOnce(String specialization) {
    if (_syncStarted) {
      return;
    }
    _syncStarted = true;
    // Не блокируем первый кадр: тренировка начинается с сетевого запроса,
    // а пакет догрузится фоном.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncControllerProvider(specialization)).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? specialization = ref.watch(sessionProvider).specializationId;

    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _startSyncOnce(specialization);

    final PracticeState state = ref.watch(practiceProvider(specialization));
    final PracticeController controller = ref.read(practiceProvider(specialization).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировка'),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('${state.answeredInSession}'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Мой уровень',
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            PendingBanner(specialization: specialization),
            Expanded(child: _buildBody(context, ref, state, controller, specialization)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    PracticeState state,
    PracticeController controller,
    String specialization,
  ) {
    switch (state.phase) {
      case PracticePhase.loading:
        return const Center(child: CircularProgressIndicator());

      case PracticePhase.failed:
        return _Message(
          icon: Icons.wifi_off,
          title: 'Не получилось загрузить вопрос',
          body: state.error ?? 'Попробуйте ещё раз',
          actionLabel: 'Повторить',
          onAction: controller.loadNext,
        );

      case PracticePhase.exhausted:
        return _Message(
          icon: Icons.check_circle_outline,
          title: 'На сегодня всё',
          body: state.error ??
              'Новые вопросы для вашего уровня закончились. Повторения появятся по расписанию.',
          actionLabel: 'Посмотреть свой уровень',
          onAction: () => context.push(AppRoutes.profile),
        );

      case PracticePhase.answering:
        return QuestionCard(
          next: state.current!,
          isSubmitting: state.isSubmitting,
          onSubmitChoice: (List<String> codes) =>
              _submit(context, ref, controller, specialization, selectedOptions: codes),
          onSubmitSelfAssessment: (int quality) =>
              _submit(context, ref, controller, specialization, selfAssessment: quality),
        );

      case PracticePhase.reviewing:
        return ExplanationView(
          result: state.result!,
          onNext: controller.loadNext,
        );
    }
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    PracticeController controller,
    String specialization, {
    List<String> selectedOptions = const <String>[],
    int? selfAssessment,
  }) async {
    try {
      await controller.submit(
        selectedOptions: selectedOptions,
        selfAssessment: selfAssessment,
      );
      // Статистика после ответа устарела.
      ref.invalidate(statsProvider(specialization));
    } on Object catch (error) {
      if (context.mounted) {
        showError(context, error);
      }
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            AsyncButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/plural.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/question.dart';
import '../common/async_button.dart';
import '../common/meta_pill.dart';
import '../common/section_label.dart';
import '../common/surface_card.dart';
import '../profile/rating_meter.dart';
import '../providers.dart';

/// Экран «сегодня»: что делать сегодня по плану подготовки (CLAUDE.md §6).
///
/// Три состояния, и все три — нормальные: плана нет (предлагаем создать),
/// план есть (показываем норму на день), тариф не позволяет (говорим прямо).
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? specialization = ref.watch(sessionProvider).specializationId;

    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('План подготовки')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(todayPlanProvider(specialization)),
        child: ref.watch(todayPlanProvider(specialization)).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace _) => _ErrorState(
                error: error,
                specialization: specialization,
              ),
              data: (TodayPlan? today) => today == null
                  ? _NoPlan(specialization: specialization)
                  : _Today(today: today),
            ),
      ),
    );
  }
}

/// Плана нет — это стартовое состояние, а не сбой.
class _NoPlan extends ConsumerStatefulWidget {
  const _NoPlan({required this.specialization});

  final String specialization;

  @override
  ConsumerState<_NoPlan> createState() => _NoPlanState();
}

class _NoPlanState extends ConsumerState<_NoPlan> {
  DateTime? _date;
  int _capacity = 10;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Когда собеседование?', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'План распределит темы по дням: слабое — раньше, за день до '
                'собеседования только повторение пройденного.',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionLabel('Дата'),
        const SizedBox(height: 10),
        SurfaceCard(
          onTap: _pickDate,
          child: Row(
            children: <Widget>[
              Icon(Icons.event_outlined, size: 18, color: colors.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _date == null ? 'Выбрать дату' : _formatDate(_date!),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.inkMuted),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionLabel('Сколько вопросов в день'),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                withPlural(_capacity, 'вопрос', 'вопроса', 'вопросов'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              Slider(
                value: _capacity.toDouble(),
                min: 5,
                max: 40,
                divisions: 7,
                label: '$_capacity',
                onChanged: (double value) => setState(() => _capacity = value.round()),
              ),
              Text(
                'Повторения входят в эту норму и идут первыми.',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AsyncButton(
          label: 'Построить план',
          isLoading: _isCreating,
          onPressed: _date == null ? null : _create,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      // Строго в будущем: план на сегодня смысла не имеет, сервер такое отклонит.
      initialDate: today.add(const Duration(days: 7)),
      firstDate: today.add(const Duration(days: 1)),
      lastDate: today.add(const Duration(days: 60)),
      helpText: 'Дата собеседования',
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _create() async {
    final DateTime? date = _date;
    if (date == null) {
      return;
    }
    setState(() => _isCreating = true);
    try {
      await ref.read(practiceRepositoryProvider).createPlan(
            specializationId: widget.specialization,
            interviewDate: date,
            dailyCapacity: _capacity,
          );
      ref.invalidate(todayPlanProvider(widget.specialization));
    } on ApiException catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

/// Норма на сегодня.
class _Today extends ConsumerWidget {
  const _Today({required this.today});

  final TodayPlan today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MetaPill(
                    label: today.daysLeft == 0
                        ? 'Собеседование сегодня'
                        : 'До собеседования ${withPlural(today.daysLeft, "день", "дня", "дней")}',
                    icon: Icons.event_outlined,
                  ),
                  if (today.reviewOnly) ...<Widget>[
                    const SizedBox(width: 8),
                    MetaPill(
                      label: 'Только повторение',
                      icon: Icons.replay_rounded,
                      tone: colors.warning,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    '${today.completedToday}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'из ${today.totalTarget}',
                    style: theme.textTheme.titleMedium?.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('вопросов за сегодня', style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              RatingMeter(value: today.progress),
              if (today.topicTitles.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final String topic in today.topicTitles) MetaPill(label: topic),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (today.dueReviews > 0) ...<Widget>[
          const SectionLabel('Сначала повторение'),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Row(
              children: <Widget>[
                Icon(Icons.replay_rounded, size: 18, color: colors.inkMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${withPlural(today.dueReviews, "вопрос", "вопроса", "вопросов")} ждут '
                    'возврата. Тренировка выдаст их первыми.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (today.reviewOnly)
          const _ReviewOnlyNote()
        else if (today.newQuestions.isEmpty)
          const _AllDoneNote()
        else ...<Widget>[
          const SectionLabel('Новые вопросы'),
          const SizedBox(height: 10),
          for (final Question question in today.newQuestions) ...<Widget>[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MetaPill(label: question.topicTitle),
                  const SizedBox(height: 10),
                  Text(question.title, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        const SizedBox(height: 18),
        FilledButton(
          // Норма дня считается на сервере по факту ответов, поэтому после
          // возврата из тренировки её нужно перечитать, а не оставлять старую.
          onPressed: () async {
            await context.push(AppRoutes.practice);
            ref.invalidate(todayPlanProvider(today.specializationId));
          },
          child: Text(today.isDone ? 'Позаниматься ещё' : 'Начать'),
        ),
      ],
    );
  }
}

class _ReviewOnlyNote extends StatelessWidget {
  const _ReviewOnlyNote();

  @override
  Widget build(BuildContext context) => SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Новых тем сегодня нет', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Перед собеседованием берут пройденное, а не свежее: новая тема, '
              'выученная накануне, чаще мешает, чем помогает.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.inkMuted,
                  ),
            ),
          ],
        ),
      );
}

class _AllDoneNote extends StatelessWidget {
  const _AllDoneNote();

  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Row(
          children: <Widget>[
            Icon(Icons.check_rounded, size: 18, color: context.colors.good),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Норма на сегодня закрыта.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
}

/// Отказ по тарифу — не ошибка приложения, и выглядеть должен иначе.
class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error, required this.specialization});

  final Object error;
  final String specialization;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isPaywall = error is ApiException && (error as ApiException).isPaymentRequired;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: <Widget>[
        SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                isPaywall ? 'План входит в платный тариф' : 'Не удалось загрузить план',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                isPaywall
                    ? 'Банк вопросов и тренировка остаются бесплатными — план по датам '
                        'и разбор слабых мест доступны по подписке.'
                    : error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(color: context.colors.inkMuted),
              ),
              if (!isPaywall) ...<Widget>[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(todayPlanProvider(specialization)),
                  child: const Text('Повторить'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  const List<String> months = <String>[
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  return '${value.day} ${months[value.month - 1]}';
}

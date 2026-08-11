import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/plural.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/local/plan_service.dart';
import '../../domain/planner.dart' as planner;
import '../common/async_button.dart';
import '../common/section_label.dart';
import '../common/surface_card.dart';
import '../profile/rating_meter.dart';
import '../providers.dart';

/// План подготовки к собеседованию.
///
/// Главная ценность продукта по CLAUDE.md §1: человек называет дату собеса и
/// получает распорядок на оставшиеся дни, а не просто банк вопросов. Слабые
/// темы идут вперёд, последний день — только повторение.
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
      body: ref.watch(todayPlanProvider(specialization)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) => _Message(text: error.toString()),
            data: (TodayPlan? plan) => plan == null
                ? _NoPlan(specialization: specialization)
                : _Plan(plan: plan, specialization: specialization),
          ),
    );
  }
}

/// Плана нет — предлагаем создать.
class _NoPlan extends ConsumerStatefulWidget {
  const _NoPlan({required this.specialization});

  final String specialization;

  @override
  ConsumerState<_NoPlan> createState() => _NoPlanState();
}

class _NoPlanState extends ConsumerState<_NoPlan> {
  DateTime? _date;
  bool _saving = false;

  /// Заранее предложенные сроки: почти всегда собеседование назначают на
  /// ближайшую неделю-две, и выбор из календаря ради этого — лишний шаг.
  static const List<int> _presets = <int>[3, 7, 14];

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 7)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: planner.kMaxPlanDays)),
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
    setState(() => _saving = true);
    try {
      await ref.read(planServiceProvider).create(
            specializationId: widget.specialization,
            interviewDate: date,
          );
      ref.invalidate(todayPlanProvider(widget.specialization));
    } on Object catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final DateTime today = planner.dateOnly(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        Text('Когда собеседование?', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Приложение разложит оставшиеся дни: слабые темы вперёд, повторения в '
          'приоритете, последний день — только закрепление.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final int days in _presets)
              _DateChip(
                label: 'через ${withPlural(days, 'день', 'дня', 'дней')}',
                selected: _date != null &&
                    planner.dateOnly(_date!) == today.add(Duration(days: days)),
                onTap: () => setState(() => _date = today.add(Duration(days: days))),
              ),
            _DateChip(
              label: 'выбрать дату',
              selected: false,
              icon: Icons.calendar_today_rounded,
              onTap: _pickDate,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_date != null)
          SurfaceCard(
            child: Row(
              children: <Widget>[
                Icon(Icons.event_rounded, size: 20, color: colors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_formatDate(_date!)} — '
                    '${withPlural(planner.dateOnly(_date!).difference(today).inDays, 'день', 'дня', 'дней')} на подготовку',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        AsyncButton(
          label: 'Построить план',
          isLoading: _saving,
          onPressed: _date == null ? null : _create,
        ),
      ],
    );
  }
}

/// Активный план: что сегодня и сколько осталось.
class _Plan extends ConsumerWidget {
  const _Plan({required this.plan, required this.specialization});

  final TodayPlan plan;
  final String specialization;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Отменить план?'),
        content: const Text('Прогресс и ответы останутся, исчезнет только распорядок по дням.'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Оставить')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Отменить план')),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(planServiceProvider).cancel(specialization);
      ref.invalidate(todayPlanProvider(specialization));
    }
  }

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
              const SectionLabel('Собеседование'),
              const SizedBox(height: 10),
              Text(_formatDate(plan.plan.interviewDate), style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                plan.isFinished
                    ? 'День настал — плана больше нет'
                    : 'осталось ${withPlural(plan.daysLeft, 'день', 'дня', 'дней')}',
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.inkSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (plan.isFinished)
          _Message(
            text: 'Собеседование уже наступило. Удачи — а план можно построить заново, '
                'когда появится следующая дата.',
          )
        else ...<Widget>[
          const SectionLabel('Сегодня'),
          const SizedBox(height: 12),
          _TodayCard(plan: plan),
          const SizedBox(height: 20),
        ],
        TextButton(
          onPressed: () => _cancel(context, ref),
          child: const Text('Отменить план'),
        ),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.plan});

  final TodayPlan plan;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!plan.isForToday) ...<Widget>[
            Text(
              'План начинается ${_formatDate(plan.day!.day)}',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '${plan.doneToday}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'из ${plan.target}',
                style: theme.textTheme.titleMedium?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('вопросов за сегодня', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          RatingMeter(value: plan.progress),
          const SizedBox(height: 16),
          if (plan.isReviewOnly)
            _Line(
              icon: Icons.history_rounded,
              tone: colors.accent,
              text: 'Последний день: только повторение пройденного, новых тем нет',
            )
          else ...<Widget>[
            if (plan.dueReviews > 0)
              _Line(
                icon: Icons.history_rounded,
                tone: colors.accent,
                text: 'Повторить: ${questionsLabel(plan.dueReviews)}',
              ),
            if (plan.dueReviews > 0) const SizedBox(height: 8),
            _Line(
              icon: Icons.auto_awesome_rounded,
              tone: colors.inkSecondary,
              text: 'Новых: ${questionsLabel(plan.day!.newQuestions)}',
            ),
            if (plan.topicCodes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              const SectionLabel('Темы дня'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String code in plan.topicCodes)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(AppTypography.radiusPill),
                      ),
                      child: Text(
                        plan.topicTitles[code] ?? code,
                        style: theme.textTheme.labelMedium?.copyWith(color: colors.inkSecondary),
                      ),
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 20),
          AsyncButton(
            label: plan.isDone ? 'Норма закрыта, продолжить' : 'Заниматься',
            onPressed: () => context.push(AppRoutes.practice),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.tone, required this.text});

  final IconData icon;
  final Color tone;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Icon(icon, size: 17, color: tone),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      );
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTypography.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.inkPrimary : colors.surface,
            borderRadius: BorderRadius.circular(AppTypography.radiusPill),
            border: Border.all(color: selected ? colors.inkPrimary : colors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 15, color: selected ? colors.surface : colors.inkSecondary),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? colors.surface : colors.inkSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );
}

const List<String> _months = <String>[
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

String _formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/plural.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/question_list.dart';
import '../common/section_label.dart';
import '../common/surface_card.dart';
import '../profile/rating_meter.dart';
import '../providers.dart';
import 'specialization_sheet.dart';
import 'target_grade_sheet.dart';

/// Главный экран: что сейчас изучаем, сколько пройдено и куда пойти дальше.
///
/// Появился потому, что из тренировки некуда было выйти: приложение открывалось
/// сразу вопросом и не давало ни обзора, ни смены специализации.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionState session = ref.watch(sessionProvider);
    final String? specialization = session.specializationId;

    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подготовка'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Мой уровень',
            onPressed: () => context.push(AppRoutes.profile),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(questionListProvider(specialization));
          await ref.read(sessionProvider.notifier).refreshProfile();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            _SpecializationCard(current: session.profile, specializationId: specialization),
            const SizedBox(height: 24),
            ref.watch(questionListProvider(specialization)).when(
                  loading: () => const _ProgressPlaceholder(),
                  error: (Object error, StackTrace _) => _OfflineNote(message: error.toString()),
                  data: (QuestionListSummary summary) => Column(
                    children: <Widget>[
                      if (summary.dueCount > 0) ...<Widget>[
                        _DueCard(
                          count: summary.dueCount,
                          onTap: () => context.push(AppRoutes.practice),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _Progress(summary: summary),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            const SectionLabel('Куда дальше'),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.play_arrow_rounded,
              title: 'Продолжить тренировку',
              subtitle: 'Приложение само выберет вопрос по вашему уровню',
              primary: true,
              onTap: () => context.push(AppRoutes.practice),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.checklist_rounded,
              title: 'Все вопросы',
              subtitle: 'Список банка: что решено, что осталось',
              onTap: () => context.push(AppRoutes.questions),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.insights_outlined,
              title: 'Мой уровень',
              subtitle: 'Рейтинги по темам и оценка грейда',
              onTap: () => context.push(AppRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }
}

/// Текущая специализация с переключателем.
class _SpecializationCard extends ConsumerWidget {
  const _SpecializationCard({required this.current, required this.specializationId});

  final UserSpecialization? current;
  final String specializationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final String title = ref.watch(taxonomyProvider).titleFor(specializationId);
    // Локальная копия: поле виджета Dart не сужает по типу, и обращение к
    // полям внутри `if (current != null)` иначе не компилируется.
    final UserSpecialization? profile = current;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionLabel('Специализация'),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: Text(title, style: theme.textTheme.headlineMedium)),
              TextButton(
                onPressed: () => showSpecializationSheet(context, ref),
                child: const Text('Сменить'),
              ),
            ],
          ),
          if (profile != null) ...<Widget>[
            const SizedBox(height: 16),
            Divider(color: colors.hairline, height: 1),
            const SizedBox(height: 14),
            const SectionLabel('Готовлюсь на'),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Grade.title(profile.targetGrade),
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _targetHint(profile, ref.watch(statsProvider(specializationId)).valueOrNull),
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => showTargetGradeSheet(context, ref),
                  child: const Text('Изменить'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Напоминание о повторениях.
///
/// Интервальные повторения — половина ценности продукта, но раньше о них
/// нигде не говорилось: вопрос возвращался в выдачу молча, и человек не знал,
/// что к нему что-то накопилось. Карточка появляется, только когда есть что
/// повторять, — постоянный ноль превратился бы в фон.
class _DueCard extends StatelessWidget {
  const _DueCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.accentWash,
            borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
            border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.history_rounded, size: 22, color: colors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'К повторению ${questionsLabel(count)}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Сроки подошли — тренировка начнёт с них',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.summary});

  final QuestionListSummary summary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '${summary.answered}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'из ${summary.total}',
                style: theme.textTheme.titleMedium?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('вопросов пройдено', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          RatingMeter(value: summary.progress),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _Tally(count: summary.correct, label: 'верно', tone: colors.good),
              const SizedBox(width: 18),
              _Tally(count: summary.partial, label: 'частично', tone: colors.warning),
              const SizedBox(width: 18),
              _Tally(count: summary.wrong, label: 'мимо', tone: colors.critical),
            ],
          ),
        ],
      ),
    );
  }
}

/// Подпись под целевым уровнем.
///
/// Сравнивать есть с чем только тогда, когда приложение измерило уровень само.
/// Раньше сравнение шло с самооценкой, которую спрашивали на старте, — и
/// подпись уверенно заявляла «сейчас Middle» человеку, который просто пролистал
/// экран. Пока измерения нет, подпись объясняет, на что влияет выбор.
String _targetHint(UserSpecialization profile, PracticeStats? stats) {
  final int? measured = stats?.overallGrade;
  if (measured == null) {
    return 'Вопросы подбираются под этот уровень';
  }
  if (profile.targetGrade > measured) {
    return 'По ответам сейчас ${Grade.title(measured)} — вопросы идут выше';
  }
  if (profile.targetGrade < measured) {
    return 'По ответам сейчас ${Grade.title(measured)} — повторяю основы';
  }
  return 'Совпадает с оценкой по вашим ответам';
}

/// Счётчик исходов. Цвет дублируется точкой и подписью, а не несёт смысл один.
class _Tally extends StatelessWidget {
  const _Tally({required this.count, required this.label, required this.tone});

  final int count;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          '$count',
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: context.colors.inkMuted),
        ),
      ],
    );
  }
}

class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder();

  @override
  Widget build(BuildContext context) => const SurfaceCard(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          height: 96,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

/// Без сети список вопросов не приходит — это не ошибка, а состояние.
class _OfflineNote extends StatelessWidget {
  const _OfflineNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return SurfaceCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off_rounded, size: 18, color: colors.inkMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Прогресс появится, когда будет сеть. Тренироваться можно и без неё.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    // Главное действие окрашено чернилами: на экране должен быть ровно один
    // очевидный следующий шаг.
    final Color background = primary ? colors.inkPrimary : colors.surface;
    final Color foreground = primary ? colors.surface : colors.inkPrimary;
    final Color muted = primary ? colors.surface.withValues(alpha: 0.7) : colors.inkMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
            border: Border.all(color: primary ? colors.inkPrimary : colors.hairline),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: foreground),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(color: foreground)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plural.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/profile.dart';
import '../common/section_label.dart';
import '../common/surface_card.dart';
import '../providers.dart';
import 'rating_meter.dart';

/// Шкала рейтинга совпадает с нормализацией на бэкенде.
const double _ratingFloor = 1000;
const double _ratingCeiling = 1800;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionState session = ref.watch(sessionProvider);
    final String? specialization = session.specializationId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой уровень'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Выйти',
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: specialization == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(statsProvider(specialization));
                await ref.read(sessionProvider.notifier).refreshProfile();
              },
              child: ref.watch(statsProvider(specialization)).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (Object error, StackTrace _) => _ErrorView(message: error.toString()),
                    data: (PracticeStats stats) => _StatsView(stats: stats),
                  ),
            ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const SizedBox(height: 100),
          Icon(Icons.cloud_off_rounded, size: 40, color: context.colors.inkMuted),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats});

  final PracticeStats stats;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          _Headline(stats: stats),
          const SizedBox(height: 32),
          Row(
            children: <Widget>[
              const SectionLabel('По темам'),
              const Spacer(),
              if (stats.topics.isNotEmpty)
                Text(
                  'рейтинг ${_ratingFloor.toInt()}–${_ratingCeiling.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.inkMuted,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (stats.topics.isEmpty)
            _EmptyTopics()
          else
            ...stats.topics.map((TopicStats topic) => _TopicRow(topic: topic)),
        ],
      );
}

/// Главный блок: оценка уровня крупным планом.
///
/// Это одно число, а не ряд значений, поэтому здесь не график — график из
/// единственной величины только прячет её за оформлением.
class _Headline extends StatelessWidget {
  const _Headline({required this.stats});

  final PracticeStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return SurfaceCard(
      padding: const EdgeInsets.all(22),
      child: switch (stats.lock) {
        StatsLock.notEnoughData => _Collecting(answered: stats.answersCount),
        StatsLock.premiumRequired => _LockedByPlan(),
        null => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionLabel('Оценка уровня'),
              const SizedBox(height: 10),
              Text(
                Grade.title(stats.overallGrade ?? Grade.middle),
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    stats.overallRating?.toStringAsFixed(0) ?? '—',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    withPlural(stats.answersCount, 'ответ', 'ответа', 'ответов'),
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                  ),
                ],
              ),
              if (stats.weakest.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Divider(color: colors.hairline),
                const SizedBox(height: 16),
                const SectionLabel('Слабее всего'),
                const SizedBox(height: 8),
                Text(
                  stats.weakest.map((TopicStats topic) => topic.title).join(' · '),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ],
          ),
      },
    );
  }
}

/// До двадцати ответов оценка не показывается — так требует спецификация.
/// Вместо пустоты показываем прогресс: видно, сколько осталось.
class _Collecting extends StatelessWidget {
  const _Collecting({required this.answered});

  final int answered;

  static const int _required = 20;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final int left = (_required - answered).clamp(0, _required);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionLabel('Оценка уровня'),
        const SizedBox(height: 10),
        Text('Собираем данные', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Ещё ${withPlural(left, 'ответ', 'ответа', 'ответов')} — и появится оценка '
          'по всей специализации. Рейтинги по темам ниже работают уже сейчас.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        RatingMeter(value: answered / _required),
        const SizedBox(height: 8),
        Text(
          '$answered из $_required',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.inkMuted,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
      ],
    );
  }
}

class _LockedByPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.lock_outline_rounded, size: 16, color: colors.inkMuted),
            const SizedBox(width: 8),
            const SectionLabel('Оценка уровня'),
          ],
        ),
        const SizedBox(height: 10),
        Text('Доступна в подписке', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Рейтинги по темам ниже доступны всегда. Подписка добавляет общую оценку '
          'грейда, план подготовки и аналитику пробелов.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _EmptyTopics extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Text(
          'Ответьте на несколько вопросов — здесь появятся рейтинги по темам.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
}

/// Строка темы: название, грейд, шкала и число.
///
/// Подписи стоят прямо у данных, поэтому легенда не нужна — серия здесь одна.
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final TopicStats topic;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final double progress =
        ((topic.rating - _ratingFloor) / (_ratingCeiling - _ratingFloor)).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(topic.title, style: theme.textTheme.titleSmall),
              ),
              const SizedBox(width: 12),
              Text(
                Grade.title(topic.grade),
                style: theme.textTheme.labelMedium?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RatingMeter(value: progress),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                topic.rating.toStringAsFixed(0),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.inkSecondary,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              Text(
                '  ·  ${withPlural(topic.answersCount, 'ответ', 'ответа', 'ответов')}',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

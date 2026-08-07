import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/grade.dart';
import '../../domain/models/profile.dart';
import '../providers.dart';

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
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
          ),
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
                    error: (Object error, StackTrace _) => ListView(
                      children: <Widget>[
                        const SizedBox(height: 120),
                        Center(child: Text(error.toString(), textAlign: TextAlign.center)),
                      ],
                    ),
                    data: (PracticeStats stats) =>
                        _StatsView(stats: stats, profile: session.profile),
                  ),
            ),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView({required this.stats, required this.profile});

  final PracticeStats stats;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _OverallCard(stats: stats),
        const SizedBox(height: 24),
        Text('По темам', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (stats.topics.isEmpty)
          const Text('Ответьте на несколько вопросов — здесь появятся рейтинги по темам.')
        else
          ...stats.topics.map((TopicStats topic) => _TopicRow(topic: topic)),
      ],
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.stats});

  final PracticeStats stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Ответов: ${stats.answersCount}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            switch (stats.lock) {
              StatsLock.notEnoughData => _Locked(
                  title: 'Собираем данные',
                  body: 'Оценка появится после 20 ответов. Осталось '
                      '${(20 - stats.answersCount).clamp(0, 20)}.',
                  progress: stats.answersCount / 20,
                ),
              StatsLock.premiumRequired => const _Locked(
                  title: 'Оценка уровня — в подписке',
                  body: 'Рейтинги по темам ниже доступны всегда. '
                      'Подписка добавляет общую оценку грейда, план и аналитику пробелов.',
                ),
              null => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Grade.title(stats.overallGrade ?? Grade.middle),
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Рейтинг ${stats.overallRating?.toStringAsFixed(0) ?? '—'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (stats.weakest.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      Text('Слабее всего', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        stats.weakest.map((TopicStats t) => t.title).join(', '),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _Locked extends StatelessWidget {
  const _Locked({required this.title, required this.body, this.progress});

  final String title;
  final String body;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (progress != null) ...<Widget>[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress!.clamp(0.0, 1.0), minHeight: 8),
          ),
        ],
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final TopicStats topic;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Шкала совпадает с нормализацией рейтинга на бэкенде: 1000–1800.
    final double progress = ((topic.rating - 1000) / 800).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(topic.title, style: theme.textTheme.titleSmall)),
              Text(
                Grade.title(topic.grade),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, minHeight: 6),
          ),
          const SizedBox(height: 4),
          Text(
            '${topic.rating.toStringAsFixed(0)} · ответов ${topic.answersCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

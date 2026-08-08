import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/inline_markup.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/question_list.dart';
import '../common/section_label.dart';
import '../providers.dart';

/// Список всех вопросов специализации с отметкой, как каждый закрыт.
///
/// Отсюда видно, что осталось, и можно вернуться к конкретному вопросу —
/// адаптивная выдача сама к нему может и не привести.
class QuestionListScreen extends ConsumerStatefulWidget {
  const QuestionListScreen({super.key});

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final String? specialization = ref.watch(sessionProvider).specializationId;
    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Все вопросы')),
      body: ref.watch(questionListProvider(specialization)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) => _Error(
              message: error.toString(),
              onRetry: () => ref.invalidate(questionListProvider(specialization)),
            ),
            data: (QuestionListSummary summary) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(questionListProvider(specialization)),
              child: _Body(
                summary: summary,
                filter: _filter,
                onFilter: (_Filter value) => setState(() => _filter = value),
                onOpen: (QuestionListItem item) => context.push(
                  '${AppRoutes.questions}/${item.id}',
                ),
              ),
            ),
          ),
    );
  }
}

enum _Filter {
  all('Все'),
  unanswered('Не решённые'),
  wrong('Ошибки'),
  due('К повторению');

  const _Filter(this.label);

  final String label;

  bool matches(QuestionListItem item) => switch (this) {
        _Filter.all => true,
        _Filter.unanswered => !item.status.isAnswered,
        _Filter.wrong =>
          item.status == QuestionStatus.wrong || item.status == QuestionStatus.partial,
        _Filter.due => item.isDue,
      };
}

class _Body extends StatelessWidget {
  const _Body({
    required this.summary,
    required this.filter,
    required this.onFilter,
    required this.onOpen,
  });

  final QuestionListSummary summary;
  final _Filter filter;
  final ValueChanged<_Filter> onFilter;
  final ValueChanged<QuestionListItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final List<QuestionListItem> visible =
        summary.items.where(filter.matches).toList(growable: false);

    final Map<String, List<QuestionListItem>> grouped = <String, List<QuestionListItem>>{};
    for (final QuestionListItem item in visible) {
      grouped.putIfAbsent(item.topicTitle, () => <QuestionListItem>[]).add(item);
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _Filters(current: filter, onChanged: onFilter, summary: summary),
        ),
        if (visible.isEmpty)
          SliverToBoxAdapter(child: _Empty(filter: filter))
        else
          for (final MapEntry<String, List<QuestionListItem>> entry in grouped.entries) ...<Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: <Widget>[
                    SectionLabel(entry.key),
                    const Spacer(),
                    Text(
                      '${entry.value.length}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.colors.inkMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.separated(
              itemCount: entry.value.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _QuestionRow(
                  item: entry.value[index],
                  onTap: () => onOpen(entry.value[index]),
                ),
              ),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.current,
    required this.onChanged,
    required this.summary,
  });

  final _Filter current;
  final ValueChanged<_Filter> onChanged;
  final QuestionListSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: <Widget>[
          for (final _Filter value in _Filter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: value.label,
                count: summary.items.where(value.matches).length,
                selected: value == current,
                colors: colors,
                onTap: () => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTypography.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? colors.inkPrimary : colors.surface,
            borderRadius: BorderRadius.circular(AppTypography.radiusPill),
            border: Border.all(color: selected ? colors.inkPrimary : colors.hairline),
          ),
          child: Text(
            '$label · $count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? colors.surface : colors.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка вопроса. Статус несут и метка, и цвет, и подпись — не один цвет.
class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.item, required this.onTap});

  final QuestionListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final _StatusLook look = _StatusLook.of(item.status, colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
            border: Border.all(color: colors.hairline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: look.wash,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.status.isAnswered ? Colors.transparent : colors.hairline,
                  ),
                ),
                child: look.icon == null
                    ? null
                    : Icon(look.icon, size: 15, color: look.tone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      stripInlineMarkup(item.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.inkPrimary,
                        fontWeight: item.status.isAnswered ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          look.label,
                          style: theme.textTheme.labelMedium?.copyWith(color: look.tone),
                        ),
                        Text(
                          Grade.title(item.peakGrade),
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                        ),
                        if (item.isDue)
                          Text(
                            'пора повторить',
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.accent),
                          ),
                        if (!item.inGradeRange)
                          Text(
                            'вне вашего грейда',
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLook {
  const _StatusLook({
    required this.label,
    required this.tone,
    required this.wash,
    this.icon,
  });

  final String label;
  final Color tone;
  final Color wash;
  final IconData? icon;

  static _StatusLook of(QuestionStatus status, AppColors colors) => switch (status) {
        QuestionStatus.correct => _StatusLook(
            label: 'Верно',
            tone: colors.good,
            wash: colors.goodWash,
            icon: Icons.check_rounded,
          ),
        QuestionStatus.partial => _StatusLook(
            label: 'Частично',
            tone: colors.warning,
            wash: colors.warningWash,
            icon: Icons.remove_rounded,
          ),
        QuestionStatus.wrong => _StatusLook(
            label: 'Мимо',
            tone: colors.critical,
            wash: colors.criticalWash,
            icon: Icons.close_rounded,
          ),
        QuestionStatus.unanswered => _StatusLook(
            label: 'Не отвечен',
            tone: colors.inkMuted,
            wash: Colors.transparent,
          ),
      };
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filter});

  final _Filter filter;

  @override
  Widget build(BuildContext context) {
    final String message = switch (filter) {
      _Filter.unanswered => 'Все вопросы пройдены.',
      _Filter.wrong => 'Ошибок нет — всё отвечено верно.',
      _Filter.due => 'Ничего не ждёт повторения.',
      _Filter.all => 'Банк вопросов пуст.',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Center(
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.cloud_off_rounded, size: 40, color: context.colors.inkMuted),
              const SizedBox(height: 16),
              Text(
                'Список доступен только с сетью — он собирается на сервере.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
            ],
          ),
        ),
      );
}

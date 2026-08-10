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

  /// Уровень, по которому отфильтрован список. `null` — показывать все.
  ///
  /// По умолчанию берётся целевой уровень из профиля: человек его уже выбрал,
  /// и показывать ему вперемешку вопросы всех грейдов значит игнорировать этот
  /// выбор. Снять фильтр можно кнопкой.
  int? _grade;
  bool _gradeInitialized = false;

  @override
  Widget build(BuildContext context) {
    final String? specialization = ref.watch(sessionProvider).specializationId;
    if (specialization == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_gradeInitialized) {
      _gradeInitialized = true;
      _grade = ref.read(sessionProvider).profile?.targetGrade;
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
                grade: _grade,
                onFilter: (_Filter value) => setState(() => _filter = value),
                onGrade: () => _pickGrade(summary),
                onOpen: (QuestionListItem item) => context.push(
                  '${AppRoutes.questions}/${item.id}',
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _pickGrade(QuestionListSummary summary) async {
    final int? picked = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTypography.radiusLarge)),
      ),
      builder: (BuildContext context) => _GradeSheet(summary: summary, current: _grade),
    );

    // null означает закрытие свайпом — выбор не менялся. «Любой уровень»
    // возвращает -1: иначе его было бы не отличить от закрытия.
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _grade = picked == _anyGrade ? null : picked);
  }
}

/// Значение пункта «Любой уровень» в листе выбора.
const int _anyGrade = -1;

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
    required this.grade,
    required this.onFilter,
    required this.onGrade,
    required this.onOpen,
  });

  final QuestionListSummary summary;
  final _Filter filter;
  final int? grade;
  final ValueChanged<_Filter> onFilter;
  final VoidCallback onGrade;
  final ValueChanged<QuestionListItem> onOpen;

  @override
  Widget build(BuildContext context) {
    // Уровень отсекает первым: счётчики у остальных фильтров должны считаться
    // от того, что человек реально видит, а не от всего банка.
    final List<QuestionListItem> byGrade = grade == null
        ? summary.items
        : summary.items
            .where((QuestionListItem item) => item.suitsGrade(grade!))
            .toList(growable: false);

    final List<QuestionListItem> visible = byGrade.where(filter.matches).toList(growable: false);

    final Map<String, List<QuestionListItem>> grouped = <String, List<QuestionListItem>>{};
    for (final QuestionListItem item in visible) {
      grouped.putIfAbsent(item.topicTitle, () => <QuestionListItem>[]).add(item);
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _GradeButton(grade: grade, total: byGrade.length, onTap: onGrade),
        ),
        SliverToBoxAdapter(
          child: _Filters(current: filter, onChanged: onFilter, items: byGrade),
        ),
        if (visible.isEmpty)
          SliverToBoxAdapter(
            child: _Empty(filter: filter, grade: grade, onGrade: onGrade),
          )
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
                  showOutOfRange: grade == null && !entry.value[index].inGradeRange,
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

/// Кнопка выбора уровня.
///
/// Вынесена отдельной строкой над остальными фильтрами: уровень определяет,
/// какие вопросы вообще имеет смысл смотреть, и это решение крупнее, чем
/// «показать только ошибки».
class _GradeButton extends StatelessWidget {
  const _GradeButton({required this.grade, required this.total, required this.onTap});

  final int? grade;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final bool filtered = grade != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
              border: Border.all(color: filtered ? colors.inkPrimary : colors.hairline),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.tune_rounded, size: 18, color: colors.inkSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        filtered ? Grade.title(grade!) : 'Любой уровень',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        filtered
                            ? 'спрашивают на этом уровне · $total'
                            : 'весь банк · $total',
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.expand_more_rounded, size: 20, color: colors.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Лист выбора уровня со счётчиками.
///
/// Счётчик у каждого уровня показывает, сколько вопросов там окажется, — иначе
/// выбор вслепую приводит на пустой экран.
class _GradeSheet extends StatelessWidget {
  const _GradeSheet({required this.summary, required this.current});

  final QuestionListSummary summary;
  final int? current;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Уровень вопросов', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Останутся только те вопросы, которые спрашивают на выбранном '
                    'уровне.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: <Widget>[
                  _GradeRow(
                    title: 'Любой уровень',
                    subtitle: 'весь банк целиком',
                    count: summary.items.length,
                    selected: current == null,
                    onTap: () => Navigator.of(context).pop(_anyGrade),
                  ),
                  const SizedBox(height: 8),
                  for (final int value in Grade.all) ...<Widget>[
                    _GradeRow(
                      title: Grade.title(value),
                      subtitle: Grade.hint(value),
                      count: summary.items
                          .where((QuestionListItem item) => item.suitsGrade(value))
                          .length,
                      selected: current == value,
                      onTap: () => Navigator.of(context).pop(value),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    // Уровень без единого вопроса выбирать незачем — он неактивен, и по счётчику
    // сразу видно почему.
    final bool empty = count == 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: empty ? null : onTap,
        borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? colors.accentWash : colors.surface,
            borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
            border: Border.all(color: selected ? colors.accent : colors.hairline),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: empty ? colors.inkMuted : colors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      empty ? 'вопросов нет' : subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '$count',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: empty ? colors.inkMuted : colors.inkSecondary,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              if (selected) ...<Widget>[
                const SizedBox(width: 10),
                Icon(Icons.check_circle_rounded, size: 20, color: colors.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.current,
    required this.onChanged,
    required this.items,
  });

  final _Filter current;
  final ValueChanged<_Filter> onChanged;
  final List<QuestionListItem> items;

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
                count: items.where(value.matches).length,
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
  const _QuestionRow({
    required this.item,
    required this.showOutOfRange,
    required this.onTap,
  });

  final QuestionListItem item;

  /// Отметка «вне вашего грейда» показывается только когда список не отфильтрован
  /// по уровню. При активном фильтре она противоречит сама себе: человек видит
  /// вопросы выбранного уровня и подпись, что они ему не подходят.
  final bool showOutOfRange;

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
                        if (showOutOfRange)
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
  const _Empty({required this.filter, required this.grade, required this.onGrade});

  final _Filter filter;
  final int? grade;
  final VoidCallback onGrade;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;

    // Пусто из-за уровня и пусто из-за состояния — разные вещи. Раньше здесь
    // писалось «банк вопросов пуст», хотя вопросы есть, просто не для этого
    // уровня: человек оставался с ощущением, что приложение сломано.
    final bool emptyByGrade = grade != null && filter == _Filter.all;

    final String message = emptyByGrade
        ? 'По этой специализации на уровне «${Grade.title(grade!)}» вопросов пока нет.'
        : switch (filter) {
            _Filter.unanswered => 'Все вопросы этого уровня пройдены.',
            _Filter.wrong => 'Ошибок нет — всё отвечено верно.',
            _Filter.due => 'Ничего не ждёт повторения.',
            _Filter.all => 'Банк вопросов пуст.',
          };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (emptyByGrade) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Банк наполняется: не для каждого стека готовы вопросы всех уровней.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onGrade, child: const Text('Выбрать другой уровень')),
          ],
        ],
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

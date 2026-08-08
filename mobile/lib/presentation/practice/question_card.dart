import 'package:flutter/material.dart';

import '../../core/inline_markup.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/question.dart';
import '../common/meta_pill.dart';

/// Карточка вопроса: варианты для выборочных, самооценка для развёрнутых.
class QuestionCard extends StatefulWidget {
  const QuestionCard({
    required this.next,
    required this.isSubmitting,
    required this.onSubmitChoice,
    required this.onSubmitSelfAssessment,
    super.key,
  });

  final NextQuestion next;
  final bool isSubmitting;
  final void Function(List<String> selectedOptions) onSubmitChoice;
  final void Function(int quality) onSubmitSelfAssessment;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final Set<String> _selected = <String>{};
  bool _revealed = false;

  Question get _question => widget.next.question;

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.next.question.id != _question.id) {
      _selected.clear();
      _revealed = false;
    }
  }

  void _toggle(String code) {
    setState(() {
      if (_question.type.allowsMultiple) {
        _selected.contains(code) ? _selected.remove(code) : _selected.add(code);
      } else {
        _selected
          ..clear()
          ..add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: <Widget>[
              _MetaRow(next: widget.next),
              const SizedBox(height: 18),
              Text(
                stripInlineMarkup(_question.title),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              if (_question.type.hasOptions) ..._buildOptions() else ..._buildOpenAnswer(theme),
            ],
          ),
        ),
        if (_question.type.hasOptions) _submitBar(),
      ],
    );
  }

  List<Widget> _buildOptions() => <Widget>[
        for (final QuestionOption option in _question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              text: option.text,
              selected: _selected.contains(option.code),
              multiple: _question.type.allowsMultiple,
              onTap: widget.isSubmitting ? null : () => _toggle(option.code),
            ),
          ),
        if (_question.type.allowsMultiple)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Можно выбрать несколько',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.inkMuted,
                  ),
            ),
          ),
      ];

  Widget _submitBar() {
    final AppColors colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.page,
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: _selected.isEmpty || widget.isSubmitting
              ? null
              : () => widget.onSubmitChoice(_selected.toList()),
          child: widget.isSubmitting
              ? const _ButtonSpinner()
              : const Text('Ответить'),
        ),
      ),
    );
  }

  List<Widget> _buildOpenAnswer(ThemeData theme) {
    final AppColors colors = context.colors;

    if (!_revealed) {
      return <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.record_voice_over_outlined, size: 20, color: colors.inkMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Проговорите ответ вслух, как на собеседовании. Потом оцените себя — '
                  'разбор откроется сразу после оценки, чтобы она осталась честной.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Кнопка ведёт на самооценку, а не на разбор: увидев эталон заранее,
        // почти все ставят «знал», и планировщик повторений слепнет.
        FilledButton(
          onPressed: () => setState(() => _revealed = true),
          child: const Text('Я ответил, оценить себя'),
        ),
      ];
    }

    return <Widget>[
      Text('Насколько близко вы ответили?', style: theme.textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        'Оценка идёт в планировщик повторений: занизите — вопрос вернётся завтра.',
        style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
      ),
      const SizedBox(height: 16),
      for (final _SelfAssessment option in _SelfAssessment.all)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AssessmentTile(
            label: option.label,
            tone: option.tone(colors),
            onTap: widget.isSubmitting
                ? null
                : () => widget.onSubmitSelfAssessment(option.quality),
          ),
        ),
    ];
  }
}

/// Вариант ответа. Состояние выбора несут и рамка, и заливка, и значок —
/// не один только цвет.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.multiple,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool multiple;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final BorderRadius radius = BorderRadius.circular(AppTypography.radiusMedium);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? colors.accentWash : colors.surface,
            borderRadius: radius,
            border: Border.all(
              color: selected ? colors.accent : colors.hairline,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Marker(selected: selected, multiple: multiple),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  stripInlineMarkup(text),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.inkPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.selected, required this.multiple});

  final bool selected;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: selected ? colors.accent : Colors.transparent,
        // Квадрат со скруглением для множественного выбора, круг для
        // единственного — форма подсказывает, сколько вариантов можно взять.
        shape: multiple ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: multiple ? BorderRadius.circular(7) : null,
        border: Border.all(
          color: selected ? colors.accent : colors.inkMuted,
          width: 1.6,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 15, color: colors.surface)
          : null,
    );
  }
}

/// Вариант самооценки. Точка слева окрашена по «качеству» ответа: от зелёного
/// к красному, что делает шкалу читаемой без чтения подписей.
class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final Color tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final BorderRadius radius = BorderRadius.circular(AppTypography.radiusMedium);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            border: Border.all(color: colors.hairline),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: theme.textTheme.bodyLarge),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: colors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: context.colors.surface,
        ),
      );
}

class _SelfAssessment {
  const _SelfAssessment(this.quality, this.label);

  final int quality;
  final String label;

  Color tone(AppColors colors) {
    if (quality >= 4) {
      return colors.good;
    }
    if (quality == 3) {
      return colors.warning;
    }
    return colors.critical;
  }

  static const List<_SelfAssessment> all = <_SelfAssessment>[
    _SelfAssessment(5, 'Ответил уверенно и полно'),
    _SelfAssessment(4, 'Ответил, но не всё вспомнил'),
    _SelfAssessment(3, 'Ответил частично'),
    _SelfAssessment(2, 'Знаю тему, но сформулировать не смог'),
    _SelfAssessment(0, 'Не знаю ответа'),
  ];
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.next});

  final NextQuestion next;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Question question = next.question;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (next.isReview)
          MetaPill(
            label: 'Повторение',
            icon: Icons.replay_rounded,
            tone: colors.accent,
            wash: colors.accentWash,
          ),
        MetaPill(label: question.topicTitle),
        MetaPill(label: 'Пик: ${Grade.title(question.peakGrade)}'),
        if (!question.isVerified)
          MetaPill(label: 'не проверен', icon: Icons.help_outline_rounded),
      ],
    );
  }
}

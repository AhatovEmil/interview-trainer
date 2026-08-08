import 'package:flutter/material.dart';

import '../../core/inline_markup.dart';
import '../../domain/models/grade.dart';
import '../../domain/models/question.dart';
import '../common/async_button.dart';

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
  final ValueChanged<List<String>> onSubmitChoice;
  final ValueChanged<int> onSubmitSelfAssessment;

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
    if (oldWidget.next.question.id != widget.next.question.id) {
      setState(() {
        _selected.clear();
        _revealed = false;
      });
    }
  }

  void _toggle(String code) {
    setState(() {
      if (_question.type.allowsMultiple) {
        if (!_selected.remove(code)) {
          _selected.add(code);
        }
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _MetaRow(next: widget.next),
        const SizedBox(height: 16),
        Text(stripInlineMarkup(_question.title), style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        if (_question.type.hasOptions) ..._buildOptions(theme) else ..._buildOpenAnswer(theme),
      ],
    );
  }

  List<Widget> _buildOptions(ThemeData theme) {
    return <Widget>[
      if (_question.type.allowsMultiple)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Выберите все подходящие варианты',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      for (final QuestionOption option in _question.options)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: _selected.contains(option.code)
                ? theme.colorScheme.primaryContainer
                : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.isSubmitting ? null : () => _toggle(option.code),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      _selected.contains(option.code)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.text)),
                  ],
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 16),
      AsyncButton(
        label: 'Ответить',
        isLoading: widget.isSubmitting,
        onPressed: _selected.isEmpty ? null : () => widget.onSubmitChoice(_selected.toList()),
      ),
    ];
  }

  List<Widget> _buildOpenAnswer(ThemeData theme) {
    if (!_revealed) {
      return <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Проговорите ответ вслух, как на собеседовании. Потом оцените себя — '
              'разбор откроется сразу после оценки, чтобы она осталась честной.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 16),
      for (final _SelfAssessment option in _SelfAssessment.all)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            onPressed: widget.isSubmitting
                ? null
                : () => widget.onSubmitSelfAssessment(option.quality),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(option.label),
            ),
          ),
        ),
    ];
  }
}

class _SelfAssessment {
  const _SelfAssessment(this.quality, this.label);

  final int quality;
  final String label;

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
    final ThemeData theme = Theme.of(context);
    final Question question = next.question;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (next.isReview)
          Chip(
            avatar: const Icon(Icons.replay, size: 16),
            label: const Text('Повторение'),
            backgroundColor: theme.colorScheme.tertiaryContainer,
          ),
        Chip(label: Text(question.topicTitle)),
        Chip(label: Text('Пик: ${Grade.title(question.peakGrade)}')),
        if (!question.isVerified)
          Chip(
            avatar: const Icon(Icons.help_outline, size: 16),
            label: const Text('не проверен'),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/question.dart';

/// Разбор после ответа: дельта рейтинга, эталонный ответ, ошибки и follow-up.
class ExplanationView extends StatelessWidget {
  const ExplanationView({
    required this.result,
    required this.onNext,
    super.key,
  });

  final AnswerResult result;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QuestionExplanation explanation = result.explanation;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _ScoreHeader(result: result),
              const SizedBox(height: 20),
              Text('Коротко', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(explanation.answerShort),
                ),
              ),
              const SizedBox(height: 20),
              Text('Разбор', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _Markdown(text: explanation.answerDetailed),
              if (explanation.commonMistakes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Text('Частые ошибки', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...explanation.commonMistakes.map(
                  (String item) => _Bullet(text: item, icon: Icons.close, color: theme.colorScheme.error),
                ),
              ],
              if (explanation.followUps.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Text('Спросят следующим', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...explanation.followUps.map(
                  (String item) => _Bullet(
                    text: item,
                    icon: Icons.arrow_forward,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(onPressed: onNext, child: const Text('Следующий вопрос')),
        ),
      ],
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.result});

  final AnswerResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = AppTheme.scoreColor(theme.colorScheme, result.score);
    final String verdict = switch (result.score) {
      >= 1.0 => 'Верно',
      > 0.0 => 'Частично',
      _ => 'Мимо',
    };
    final double delta = result.ratingDelta;
    final String deltaText = '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}';

    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(
              result.isCorrect
                  ? Icons.check_circle
                  : (result.isPartial ? Icons.adjust : Icons.cancel),
              color: color,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(verdict, style: theme.textTheme.titleMedium?.copyWith(color: color)),
                  Text(
                    'Рейтинг ${result.ratingAfter.toStringAsFixed(0)} ($deltaText) · '
                    'повтор ${_formatDue(result.nextReviewAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (result.isDuplicate)
                    Text(
                      'Ответ уже был засчитан ранее',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDue(DateTime due) {
    final int days = due.difference(DateTime.now()).inDays;
    if (days <= 0) {
      return 'завтра';
    }
    if (days == 1) {
      return 'через день';
    }
    return 'через $days дн.';
  }
}

/// Минимальный рендер markdown: заголовки, списки, код и абзацы.
/// Полноценный парсер тянуть ради разбора не стоит.
class _Markdown extends StatelessWidget {
  const _Markdown({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> blocks = <Widget>[];
    final List<String> lines = text.split('\n');

    bool inCode = false;
    final List<String> codeBuffer = <String>[];

    for (final String raw in lines) {
      final String line = raw.trimRight();

      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          blocks.add(_CodeBlock(code: codeBuffer.join('\n')));
          codeBuffer.clear();
        }
        inCode = !inCode;
        continue;
      }

      if (inCode) {
        codeBuffer.add(raw);
        continue;
      }

      if (line.isEmpty) {
        blocks.add(const SizedBox(height: 12));
        continue;
      }

      final String trimmed = line.trimLeft();
      if (trimmed.startsWith('#')) {
        final String heading = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              heading,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        blocks.add(_Bullet(text: trimmed.substring(2), icon: Icons.circle, size: 6));
        continue;
      }

      blocks.add(Text(_stripInline(trimmed), style: theme.textTheme.bodyMedium));
    }

    if (codeBuffer.isNotEmpty) {
      blocks.add(_CodeBlock(code: codeBuffer.join('\n')));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }

  /// Убираем маркеры жирного и inline-кода: рендерить их отдельно избыточно.
  static String _stripInline(String value) =>
      value.replaceAll('**', '').replaceAll('`', '');
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.text,
    required this.icon,
    this.color,
    this.size = 16,
  });

  final String text;
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 10),
            child: Icon(icon, size: size, color: color ?? theme.colorScheme.onSurfaceVariant),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

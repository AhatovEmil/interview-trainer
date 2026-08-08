import 'package:flutter/material.dart';

import '../../core/inline_markup.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/question.dart';
import '../common/section_label.dart';
import '../common/surface_card.dart';

/// Разбор после ответа: вердикт, эталонный ответ, разбор по уровням,
/// частые ошибки и follow-up.
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
    final AppColors colors = context.colors;
    final QuestionExplanation explanation = result.explanation;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: <Widget>[
              _Verdict(result: result),
              const SizedBox(height: 28),
              const SectionLabel('Коротко'),
              const SizedBox(height: 10),
              SurfaceCard(
                child: Text(
                  explanation.answerShort,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel('Разбор'),
              const SizedBox(height: 10),
              _Markdown(text: explanation.answerDetailed),
              if (explanation.commonMistakes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 28),
                const SectionLabel('Частые ошибки'),
                const SizedBox(height: 10),
                ...explanation.commonMistakes.map(
                  (String item) => _Bullet(
                    text: item,
                    icon: Icons.close_rounded,
                    color: colors.critical,
                  ),
                ),
              ],
              if (explanation.followUps.isNotEmpty) ...<Widget>[
                const SizedBox(height: 28),
                const SectionLabel('Спросят следующим'),
                const SizedBox(height: 10),
                ...explanation.followUps.map(
                  (String item) => _Bullet(
                    text: item,
                    icon: Icons.arrow_forward_rounded,
                    color: colors.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
        _BottomBar(
          child: FilledButton(
            onPressed: onNext,
            child: const Text('Следующий вопрос'),
          ),
        ),
      ],
    );
  }
}

/// Панель с главной кнопкой. Отделена от списка волосяной линией, чтобы при
/// прокрутке текст не «подтекал» под кнопку без границы.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.page,
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// Вердикт: крупно и однозначно. Цвет дублируется иконкой и словом —
/// на одном цвете смысл держаться не должен.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.result});

  final AnswerResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final Color tone = colors.verdict(result.score);

    final String title = switch (result.score) {
      >= 1.0 => 'Верно',
      > 0.0 => 'Частично',
      _ => 'Мимо',
    };
    final IconData icon = switch (result.score) {
      >= 1.0 => Icons.check_rounded,
      > 0.0 => Icons.remove_rounded,
      _ => Icons.close_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.verdictWash(result.score),
        borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: colors.surface),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleLarge?.copyWith(color: tone)),
                const SizedBox(height: 2),
                _RatingLine(result: result),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.result});

  final AnswerResult result;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final TextStyle? base = theme.textTheme.bodySmall?.copyWith(color: colors.inkSecondary);

    if (result.isDuplicate) {
      return Text('Ответ уже был засчитан ранее', style: base);
    }

    // Офлайн рейтинг неизвестен: он зависит от серверного состояния.
    if (!result.hasRating) {
      return Text('Сохранено · рейтинг обновится после синхронизации', style: base);
    }

    final double delta = result.ratingDelta ?? 0;
    final String sign = delta >= 0 ? '+' : '−';
    final String due = result.nextReviewAt == null
        ? ''
        : ' · повтор ${_formatDue(result.nextReviewAt!)}';

    return Row(
      children: <Widget>[
        Text(
          result.ratingAfter!.toStringAsFixed(0),
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$sign${delta.abs().toStringAsFixed(0)}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: delta >= 0 ? colors.good : colors.critical,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        Expanded(child: Text(due, style: base, overflow: TextOverflow.ellipsis)),
      ],
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
    final AppColors colors = context.colors;
    final List<Widget> blocks = <Widget>[];
    final List<String> lines = text.split('\n');

    bool inCode = false;
    final List<String> codeBuffer = <String>[];

    // Абзац продолжается, пока не встретится пустая строка: одиночный перенос
    // внутри абзаца — это перенос в исходнике, а не разрыв строки на экране.
    final List<String> paragraph = <String>[];
    void flushParagraph() {
      if (paragraph.isEmpty) {
        return;
      }
      blocks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            stripInlineMarkup(paragraph.join(' ')),
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.inkSecondary),
          ),
        ),
      );
      paragraph.clear();
    }

    for (final String raw in lines) {
      final String line = raw.trimRight();

      if (line.trimLeft().startsWith('```')) {
        flushParagraph();
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
        flushParagraph();
        continue;
      }

      final String trimmed = line.trimLeft();
      if (trimmed.startsWith('#')) {
        flushParagraph();
        blocks.add(_LevelHeading(text: trimmed.replaceFirst(RegExp(r'^#+\s*'), '')));
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        flushParagraph();
        blocks.add(
          _Bullet(
            text: trimmed.substring(2),
            icon: Icons.circle,
            color: colors.inkMuted,
            size: 5,
          ),
        );
        continue;
      }

      paragraph.add(trimmed);
    }

    flushParagraph();

    if (codeBuffer.isNotEmpty) {
      blocks.add(_CodeBlock(code: codeBuffer.join('\n')));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }
}

/// Заголовок уровня внутри разбора: «Junior», «Middle», «Senior».
/// Это опора для чтения — по ней находят свой уровень, не читая всё.
class _LevelHeading extends StatelessWidget {
  const _LevelHeading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.accentWash,
              borderRadius: BorderRadius.circular(AppTypography.radiusPill),
            ),
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: colors.hairline)),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
        border: Border.all(color: colors.hairline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.5,
            color: colors.inkPrimary,
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.text,
    required this.icon,
    required this.color,
    this.size = 16,
  });

  final String text;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Иконку опускаем на пару пикселей: так она встаёт на оптическую
          // середину первой строки, а не на её верх.
          Padding(
            padding: EdgeInsets.only(top: size < 8 ? 9 : 3),
            child: Icon(icon, size: size, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stripInlineMarkup(text),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

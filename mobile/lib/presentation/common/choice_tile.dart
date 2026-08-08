import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Строка выбора в онбординге: профессия, стек, грейд.
///
/// Недоступный пункт не прячется и не сереет до нечитаемости — он остаётся
/// виден с пометкой «скоро», чтобы было понятно, что появится дальше.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.title,
    this.subtitle,
    this.selected = false,
    this.enabled = true,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppColors colors = context.colors;
    final BorderRadius radius = BorderRadius.circular(AppTypography.radiusMedium);
    final Color titleColor = enabled ? colors.inkPrimary : colors.inkMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: selected ? colors.accentWash : colors.surface,
            borderRadius: radius,
            border: Border.all(
              color: selected ? colors.accent : colors.hairline,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(color: titleColor),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (trailing != null)
                trailing!
              else if (selected)
                Icon(Icons.check_circle_rounded, size: 22, color: colors.accent)
              else if (enabled)
                Icon(Icons.chevron_right_rounded, size: 22, color: colors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Пометка «скоро» для неактивных специализаций.
class SoonBadge extends StatelessWidget {
  const SoonBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppTypography.radiusPill),
      ),
      child: Text(
        'СКОРО',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.inkMuted),
      ),
    );
  }
}

/// Индикатор шагов онбординга. Точки вместо полосы: их три, и видно,
/// сколько осталось, без чтения процентов.
class StepDots extends StatelessWidget {
  const StepDots({required this.total, required this.current, super.key});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Row(
      children: List<Widget>.generate(total, (int index) {
        final bool done = index <= current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 3,
              decoration: BoxDecoration(
                color: done ? colors.inkPrimary : colors.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

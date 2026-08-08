import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Метка-пилюля для мелких признаков: тема, пиковый грейд, статус проверки.
///
/// По умолчанию нейтральная. Цвет появляется только там, где несёт смысл, —
/// иначе строка метаданных начинает спорить с формулировкой вопроса.
class MetaPill extends StatelessWidget {
  const MetaPill({
    required this.label,
    this.icon,
    this.tone,
    this.wash,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color? tone;
  final Color? wash;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Color foreground = tone ?? colors.inkSecondary;

    return Container(
      padding: EdgeInsets.only(
        left: icon == null ? 10 : 8,
        right: 10,
        top: 5,
        bottom: 5,
      ),
      decoration: BoxDecoration(
        color: wash ?? colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppTypography.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

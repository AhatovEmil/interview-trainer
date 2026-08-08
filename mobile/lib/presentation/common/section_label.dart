import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Заголовок раздела: капслок, разрядка, приглушённый тон.
///
/// Не конкурирует с содержимым за внимание — его задача разметить страницу,
/// а не быть прочитанным.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.inkMuted,
            ),
      );
}

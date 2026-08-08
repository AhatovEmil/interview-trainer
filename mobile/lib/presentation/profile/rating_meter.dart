import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Шкала рейтинга по теме.
///
/// Это одна метрика, измеренная по многим темам, поэтому тон один: разные
/// цвета намекали бы, что темы принадлежат разным категориям. Заливка держится
/// базовой линии и скруглена по торцу, трек остаётся видимым — по нему читается,
/// сколько ещё не пройдено.
class RatingMeter extends StatelessWidget {
  const RatingMeter({
    required this.value,
    this.height = 8,
    this.animate = true,
    super.key,
  });

  /// Доля от 0 до 1.
  final double value;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final double clamped = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double full = constraints.maxWidth;
        // Минимальная видимая ширина: нулевая заливка иначе исчезает совсем,
        // и строка выглядит сломанной, а не пустой.
        final double target = clamped == 0 ? 0 : (full * clamped).clamp(height, full);

        return Stack(
          children: <Widget>[
            Container(
              height: height,
              decoration: BoxDecoration(
                color: colors.dataTrack,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            if (target > 0)
              AnimatedContainer(
                duration: Duration(milliseconds: animate ? 520 : 0),
                curve: Curves.easeOutCubic,
                height: height,
                width: target,
                decoration: BoxDecoration(
                  color: colors.dataFill,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
          ],
        );
      },
    );
  }
}

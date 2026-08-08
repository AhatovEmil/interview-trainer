import 'package:flutter/material.dart';

/// Типографика.
///
/// Шрифт системный: приложение обязано работать без сети, а подгрузка гарнитуры
/// в рантайме этому противоречит. Характер даёт не гарнитура, а дисциплина —
/// плотный трекинг на крупном, просторный интерлиньяж на тексте для чтения.
class AppTypography {
  const AppTypography._();

  /// Шаг сетки. Все отступы кратны четырём, поэтому блоки выравниваются
  /// сами собой, без подгонки на глаз.
  static const double gridUnit = 4;

  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 18;
  static const double radiusPill = 999;

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
        // Крупные заголовки: чем больше кегль, тем плотнее должен быть трекинг,
        // иначе буквы расползаются.
        displaySmall: TextStyle(
          fontSize: 34,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: primary,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: primary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.45,
          color: primary,
        ),
        // Формулировка вопроса — главный текст в приложении.
        headlineSmall: TextStyle(
          fontSize: 21,
          height: 1.32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: primary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.35,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: primary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        // Текст для чтения: интерлиньяж 1.55 — разборы длинные.
        bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: primary),
        bodyMedium: TextStyle(fontSize: 15, height: 1.55, color: secondary),
        bodySmall: TextStyle(fontSize: 13, height: 1.45, color: secondary),
        labelLarge: TextStyle(
          fontSize: 15,
          height: 1.2,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: primary,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: secondary,
        ),
        // Надписи капслоком: без разрядки они слипаются.
        labelSmall: TextStyle(
          fontSize: 11,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: secondary,
        ),
      );

  /// Моноширинные цифры для колонок и рейтингов: пропорциональные прыгают
  /// по ширине при каждом изменении числа.
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];
}

import 'package:flutter/material.dart';

/// Палитра приложения.
///
/// Задана явно, а не через `ColorScheme.fromSeed`: генератор Material 3 выдаёт
/// characteristic сиреневатые поверхности, из-за которых любой продукт выглядит
/// одинаково. Здесь нейтрали холодные и почти бесцветные, а насыщенный цвет
/// появляется только там, где несёт смысл.
///
/// Контраст каждого цвета для текста проверен по WCAG 2.1 на своей поверхности:
/// текстовые — не ниже 4.5:1, метки данных и иконки — не ниже 3:1. Тёмные
/// значения подобраны отдельно, а не получены инверсией светлых.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.page,
    required this.surface,
    required this.surfaceRaised,
    required this.hairline,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.inkMuted,
    required this.accent,
    required this.accentWash,
    required this.dataFill,
    required this.dataTrack,
    required this.good,
    required this.goodWash,
    required this.warning,
    required this.warningWash,
    required this.critical,
    required this.criticalWash,
  });

  /// Фон страницы: чуть темнее карточек, чтобы те читались без теней.
  final Color page;
  final Color surface;

  /// Поверхность для вложенных блоков — цитат, кода, подсказок.
  final Color surfaceRaised;

  /// Волосяная линия границ. Заменяет тени: тени на плотном интерфейсе мылят.
  final Color hairline;

  final Color inkPrimary;
  final Color inkSecondary;
  final Color inkMuted;

  /// Интерактивный цвет: ссылки, фокус, выбранное состояние.
  final Color accent;
  final Color accentWash;

  /// Заливка шкал рейтинга. Одна метрика по многим темам — значит один тон,
  /// а не набор разных цветов.
  final Color dataFill;
  final Color dataTrack;

  final Color good;
  final Color goodWash;
  final Color warning;
  final Color warningWash;
  final Color critical;
  final Color criticalWash;

  static const AppColors light = AppColors(
    page: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF2F4F7),
    hairline: Color(0xFFE4E7EC),
    inkPrimary: Color(0xFF0C1017),
    inkSecondary: Color(0xFF4A5260),
    inkMuted: Color(0xFF6B7280),
    accent: Color(0xFF2F5BEA),
    accentWash: Color(0xFFEEF2FE),
    dataFill: Color(0xFF2A78D6),
    dataTrack: Color(0xFFE8ECF2),
    good: Color(0xFF0F7B3A),
    goodWash: Color(0xFFE9F6EE),
    warning: Color(0xFF8A5200),
    warningWash: Color(0xFFFCF3E5),
    critical: Color(0xFFC0392B),
    criticalWash: Color(0xFFFCEDEB),
  );

  static const AppColors dark = AppColors(
    page: Color(0xFF0A0C0F),
    surface: Color(0xFF14171C),
    surfaceRaised: Color(0xFF1B1F26),
    hairline: Color(0xFF252A32),
    inkPrimary: Color(0xFFF2F4F7),
    inkSecondary: Color(0xFFA8B0BC),
    inkMuted: Color(0xFF79818F),
    accent: Color(0xFF7C93FF),
    accentWash: Color(0xFF191E2E),
    dataFill: Color(0xFF5B87FF),
    dataTrack: Color(0xFF222730),
    good: Color(0xFF4ADE80),
    goodWash: Color(0xFF11201A),
    warning: Color(0xFFFBBF4B),
    warningWash: Color(0xFF241D10),
    critical: Color(0xFFF87171),
    criticalWash: Color(0xFF251518),
  );

  /// Цвет вердикта по очкам за ответ. Никогда не используется в одиночку:
  /// рядом всегда иконка и слово, иначе смысл держался бы только на цвете.
  Color verdict(double score) {
    if (score >= 1.0) {
      return good;
    }
    if (score > 0.0) {
      return warning;
    }
    return critical;
  }

  Color verdictWash(double score) {
    if (score >= 1.0) {
      return goodWash;
    }
    if (score > 0.0) {
      return warningWash;
    }
    return criticalWash;
  }

  @override
  AppColors copyWith({
    Color? page,
    Color? surface,
    Color? surfaceRaised,
    Color? hairline,
    Color? inkPrimary,
    Color? inkSecondary,
    Color? inkMuted,
    Color? accent,
    Color? accentWash,
    Color? dataFill,
    Color? dataTrack,
    Color? good,
    Color? goodWash,
    Color? warning,
    Color? warningWash,
    Color? critical,
    Color? criticalWash,
  }) =>
      AppColors(
        page: page ?? this.page,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        hairline: hairline ?? this.hairline,
        inkPrimary: inkPrimary ?? this.inkPrimary,
        inkSecondary: inkSecondary ?? this.inkSecondary,
        inkMuted: inkMuted ?? this.inkMuted,
        accent: accent ?? this.accent,
        accentWash: accentWash ?? this.accentWash,
        dataFill: dataFill ?? this.dataFill,
        dataTrack: dataTrack ?? this.dataTrack,
        good: good ?? this.good,
        goodWash: goodWash ?? this.goodWash,
        warning: warning ?? this.warning,
        warningWash: warningWash ?? this.warningWash,
        critical: critical ?? this.critical,
        criticalWash: criticalWash ?? this.criticalWash,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      page: mix(page, other.page),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      hairline: mix(hairline, other.hairline),
      inkPrimary: mix(inkPrimary, other.inkPrimary),
      inkSecondary: mix(inkSecondary, other.inkSecondary),
      inkMuted: mix(inkMuted, other.inkMuted),
      accent: mix(accent, other.accent),
      accentWash: mix(accentWash, other.accentWash),
      dataFill: mix(dataFill, other.dataFill),
      dataTrack: mix(dataTrack, other.dataTrack),
      good: mix(good, other.good),
      goodWash: mix(goodWash, other.goodWash),
      warning: mix(warning, other.warning),
      warningWash: mix(warningWash, other.warningWash),
      critical: mix(critical, other.critical),
      criticalWash: mix(criticalWash, other.criticalWash),
    );
  }
}

/// Доступ к палитре из виджетов: `context.colors.accent`.
extension AppColorsX on BuildContext {
  /// Если расширение не подключено к теме — берём набор по яркости.
  /// Виджет должен нарисоваться в любом окружении, включая тесты и превью.
  AppColors get colors {
    final ThemeData theme = Theme.of(this);
    return theme.extension<AppColors>() ??
        (theme.brightness == Brightness.dark ? AppColors.dark : AppColors.light);
  }
}

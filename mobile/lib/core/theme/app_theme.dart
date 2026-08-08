import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Тема приложения. Аудитория — работающие разработчики перед собеседованием,
/// поэтому интерфейс собранный и плотный, без обучающей игривости.
///
/// Главная кнопка окрашена чернилами, а не акцентом: чёрное на белом читается
/// увереннее любого цветного пятна, а акцент остаётся редким и потому заметным.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final bool isLight = brightness == Brightness.light;
    final TextTheme text = AppTypography.textTheme(colors.inkPrimary, colors.inkSecondary);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: colors.inkPrimary,
      onPrimary: colors.surface,
      secondary: colors.accent,
      onSecondary: isLight ? Colors.white : colors.page,
      surface: colors.surface,
      onSurface: colors.inkPrimary,
      surfaceContainerHighest: colors.surfaceRaised,
      onSurfaceVariant: colors.inkSecondary,
      outline: colors.hairline,
      outlineVariant: colors.hairline,
      error: colors.critical,
      onError: isLight ? Colors.white : colors.page,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: colors.page,
      canvasColor: colors.page,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.page,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.inkPrimary,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusLarge),
          side: BorderSide(color: colors.hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.inkPrimary,
          foregroundColor: colors.surface,
          disabledBackgroundColor: colors.hairline,
          disabledForegroundColor: colors.inkMuted,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          ),
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.inkPrimary,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: colors.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: text.bodyMedium?.copyWith(color: colors.inkMuted),
        labelStyle: text.bodyMedium?.copyWith(color: colors.inkMuted),
        floatingLabelStyle: text.labelMedium?.copyWith(color: colors.accent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          borderSide: BorderSide(color: colors.hairline),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          borderSide: BorderSide(color: colors.hairline),
        ),
        // Фокус подчёркиваем толщиной и акцентом: рамка в 1.6 px заметна,
        // но не превращает поле в подсвеченный прямоугольник.
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          borderSide: BorderSide(color: colors.accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          borderSide: BorderSide(color: colors.critical),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
          borderSide: BorderSide(color: colors.critical, width: 1.6),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.hairline, space: 1, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.dataFill,
        linearTrackColor: colors.dataTrack,
        circularTrackColor: colors.dataTrack,
        linearMinHeight: 6,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inkPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: colors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
        ),
      ),
      // Переход задаём только для Android: на iOS системный свайп-назад
      // ощущается правильнее любой замены.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

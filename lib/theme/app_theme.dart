import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_typography.dart';

/// App-wide light / dark themes with consistent typography & color.
///
/// Light mode is the corporate Medifit system (warm off-white, navy ink,
/// muted teal CTA). Dark mode tokens are intentionally unchanged.
class AppTheme {
  AppTheme._();

  /// Muted teal used for light-mode actions, selection, and focus.
  static const Color brandPrimary = Color(0xFF176B63);

  /// Original shared brand red. Dark ColorScheme still uses this value.
  static const Color darkBrandPrimary = Color(0xFFFF6D55);

  /// Existing dark-mode accents. Do not use these as light-mode brand paint.
  static const Color brandSecondary = Color(0xFF2EE5A3);
  static const Color brandAccent = Color(0xFF5B8CFF);

  static const Color brandInk = Color(0xFF182B3A);
  static const Color brandSoft = Color(0xFFE8F2EF);
  static const Color lightBg = Color(0xFFF6F7F5);
  static const Color lightMuted = Color(0xFF596B78);
  static const Color lightBorder = Color(0xFFDCE3E1);
  static const Color lightDanger = Color(0xFFB42318);

  static const Color darkBg = Color(0xFF0A0D10);
  static const Color darkSurface = Color(0xFF0F1318);

  /// Colors.blueAccent — preserved as the dark-mode action fallback.
  static const Color _darkActionBlue = Color(0xFF448AFF);

  /// Light CTA / selection color. Dark keeps the previous accent.
  static Color action(bool isDark, {Color? dark}) {
    if (isDark) return dark ?? _darkActionBlue;
    return brandPrimary;
  }

  static Color actionOf(BuildContext context, {Color? dark}) {
    return action(Theme.of(context).brightness == Brightness.dark, dark: dark);
  }

  static Color actionSoftOf(
    BuildContext context, {
    Color? dark,
    double alpha = 0.12,
  }) {
    return actionOf(context, dark: dark).withValues(alpha: alpha);
  }

  static ThemeData light() {
    const ink = brandInk;
    final colorScheme = ColorScheme.light(
      primary: brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: brandSoft,
      onPrimaryContainer: ink,
      secondary: ink,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFEEF1F6),
      onSecondaryContainer: ink,
      tertiary: brandAccent,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: ink,
      onSurfaceVariant: lightMuted,
      outline: lightBorder,
      outlineVariant: const Color(0xFFE8ECEA),
      error: lightDanger,
      onError: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFBFCFA),
      surfaceContainer: lightBg,
      surfaceContainerHigh: const Color(0xFFEEEFED),
    );

    final textTheme = AppTypography.textTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBg,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandPrimary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: brandPrimary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandPrimary;
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandPrimary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return brandPrimary.withValues(alpha: 0.35);
          }
          return null;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF9AA3B2),
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: brandPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        selectedColor: brandSoft,
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: 0.08),
        thickness: 1,
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkBrandPrimary,
      brightness: Brightness.dark,
      primary: darkBrandPrimary,
      secondary: brandSecondary,
      surface: darkSurface,
    );

    final textTheme = AppTypography.textTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.4),
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: darkBrandPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),
    );
  }
}

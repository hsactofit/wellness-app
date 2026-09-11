import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_brand.dart';
import 'app_typography.dart';

/// App-wide light / dark themes with consistent typography & color.
///
/// Light mode follows a quiet corporate editorial system: warm parchment
/// canvas, near-black ink, black CTAs, and a champagne-gold accent.
/// Dark mode is unchanged.
class AppTheme {
  AppTheme._();

  /// Near-black used for light-mode actions, selection, and focus.
  static const Color brandPrimary = Color(0xFF161616);

  /// Original shared brand red. Dark ColorScheme still uses this value.
  static const Color darkBrandPrimary = Color(0xFFFF6D55);

  /// Existing dark-mode accents. Do not use these as light-mode brand paint.
  static const Color brandSecondary = Color(0xFF2EE5A3);
  static const Color brandAccent = Color(0xFF5B8CFF);

  static const Color brandInk = Color(0xFF161616);
  static const Color brandSoft = Color(0xFFF0E6D4);
  static const Color lightBg = Color(0xFFF6F1E6);
  static const Color lightMuted = Color(0xFF6F675C);
  static const Color lightBorder = Color(0xFFE6DCCB);
  static const Color lightDanger = Color(0xFFB42318);
  static const Color lightGold = Color(0xFFE0CFA8);
  static const Color lightNav = Color(0xFF161616);
  static const Color mednovationsBlue = Color(0xFF0878A8);
  static const Color mednovationsGreen = Color(0xFF55A630);
  static const Color mednovationsSoft = Color(0xFFE1F3F8);
  static const Color mednovationsInk = Color(0xFF123E58);

  static const Color darkBg = Color(0xFF0A0D10);
  static const Color darkSurface = Color(0xFF0F1318);

  /// Colors.blueAccent — preserved as the dark-mode action fallback.
  static const Color _darkActionBlue = Color(0xFF448AFF);

  /// Light CTA / selection color. Dark keeps the previous accent.
  static Color action(bool isDark, {Color? dark}) {
    if (isDark) {
      return dark ??
          (AppBrand.isMednovations ? const Color(0xFF38B9DC) : _darkActionBlue);
    }
    return AppBrand.isMednovations ? mednovationsBlue : brandPrimary;
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
    final ink = AppBrand.isMednovations ? mednovationsInk : brandInk;
    final primary = AppBrand.isMednovations ? mednovationsBlue : brandPrimary;
    final primarySoft = AppBrand.isMednovations ? mednovationsSoft : brandSoft;
    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primarySoft,
      onPrimaryContainer: ink,
      secondary: AppBrand.isMednovations
          ? mednovationsGreen
          : const Color(0xFFB89A62),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFF3E8D4),
      onSecondaryContainer: ink,
      tertiary: brandAccent,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: ink,
      onSurfaceVariant: lightMuted,
      outline: lightBorder,
      outlineVariant: const Color(0xFFEFE6D6),
      error: lightDanger,
      onError: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF8F3E8),
      surfaceContainer: lightBg,
      surfaceContainerHigh: const Color(0xFFE9DFCC),
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
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.35);
          }
          return null;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF9AA3B2),
        ),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: primary),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        selectedColor: primarySoft,
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: 0.08),
        thickness: 1,
      ),
    );
  }

  static ThemeData dark() {
    final darkPrimary = AppBrand.isMednovations
        ? const Color(0xFF38B9DC)
        : darkBrandPrimary;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
      primary: darkPrimary,
      secondary: AppBrand.isMednovations
          ? const Color(0xFF76CF55)
          : brandSecondary,
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

import 'package:flutter/material.dart';
import '../app_brand.dart';
import '../theme/app_theme.dart';

/// Renders the logo selected for the current build.
class AppBrandLogo extends StatelessWidget {
  /// Overall height of the logo plate (width is derived from aspect ratio).
  final double height;

  /// Max width cap so very wide logos don't overflow small screens.
  final double? maxWidth;

  /// Corner radius of the dark plate behind the logo.
  final double borderRadius;

  /// Extra padding inside the plate around the image.
  final EdgeInsetsGeometry padding;

  /// Show a soft brand glow / border (splash, hero).
  final bool elevated;

  const AppBrandLogo({
    super.key,
    this.height = 72,
    this.maxWidth,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.elevated = false,
  });

  /// Compact mark for app bars / signup headers.
  const AppBrandLogo.compact({super.key})
    : height = 52,
      maxWidth = 200,
      borderRadius = 14,
      padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      elevated = false;

  /// Large hero mark for splash.
  const AppBrandLogo.hero({super.key})
    : height = 108,
      maxWidth = 360,
      borderRadius = 24,
      padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      elevated = true;

  /// Default Medifit logo kept as a constant for existing callers.
  static const String assetPath = 'assets/app_logo.png';

  static String get selectedAssetPath => AppBrand.logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final isMednovations = AppBrand.isMednovations;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plateHeight = height;
    final plateWidth = (plateHeight * AppBrand.logoAspectRatio).clamp(
      plateHeight,
      maxWidth ?? double.infinity,
    );

    final useLightPlate = isMednovations || !isDark;
    final Color plateBorder;
    if (isMednovations) {
      plateBorder = const Color(0xFF167FB7).withValues(alpha: 0.18);
    } else if (isDark) {
      plateBorder = elevated
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.06);
    } else {
      plateBorder = AppTheme.brandInk.withValues(alpha: elevated ? 0.10 : 0.08);
    }

    final glowColor = isMednovations
        ? const Color(0xFF1B9D4D)
        : (isDark ? const Color(0xFFE53935) : AppTheme.brandPrimary);

    return Container(
      width: plateWidth,
      height: plateHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: useLightPlate ? Colors.white : const Color(0xFF0B0B10),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: plateBorder, width: 1),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: isDark ? 0.18 : 0.14),
                  blurRadius: 22,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        gradient: isMednovations
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF2FBFD)],
              )
            : (isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF16161C),
                        Color(0xFF0B0B10),
                        Color(0xFF121218),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF7F5F2)],
                    )),
      ),
      child: Image.asset(
        selectedAssetPath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            AppBrand.name,
            style: TextStyle(
              color: isMednovations
                  ? const Color(0xFF167FB7)
                  : (isDark ? Colors.white : AppTheme.brandInk),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}

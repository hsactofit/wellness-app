import 'package:flutter/material.dart';
import '../app_brand.dart';

/// Renders the wordmark selected for the current build.
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

  /// Original/default Medifit wordmark kept as a constant for existing callers.
  static const String assetPath = 'assets/logo_2.png';

  static String get selectedAssetPath => AppBrand.logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final isMednovations = AppBrand.isMednovations;
    final plateHeight = height;
    final plateWidth = (plateHeight * AppBrand.logoAspectRatio).clamp(
      plateHeight,
      maxWidth ?? double.infinity,
    );

    return Container(
      width: plateWidth,
      height: plateHeight,
      padding: padding,
      decoration: BoxDecoration(
        color: isMednovations ? Colors.white : const Color(0xFF0B0B10),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isMednovations
              ? const Color(0xFF167FB7).withValues(alpha: 0.18)
              : (elevated
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.06)),
          width: 1,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color:
                      (isMednovations
                              ? const Color(0xFF1B9D4D)
                              : const Color(0xFFE53935))
                          .withValues(alpha: 0.18),
                  blurRadius: 22,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
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
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF16161C),
                  Color(0xFF0B0B10),
                  Color(0xFF121218),
                ],
              ),
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
              color: isMednovations ? const Color(0xFF167FB7) : Colors.white,
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

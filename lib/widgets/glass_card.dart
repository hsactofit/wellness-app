import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_brand.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.borderRadius = 22.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : (AppBrand.isMednovations
              ? const Color(0xFFFCFEFF)
              : const Color(0xFFFFFEFB));

    final defaultBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : AppTheme.lightBorderColor,
      width: isDark ? 1.3 : 1.0,
    );

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? defaultBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? defaultBorder,
      ),
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppTheme.lightInk.withValues(alpha: 0.05),
            blurRadius: isDark ? 24 : 18,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: isDark
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: card,
              )
            : card,
      ),
    );
  }
}

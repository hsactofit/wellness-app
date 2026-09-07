import 'dart:ui';
import 'package:flutter/material.dart';

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
    this.borderRadius = 18.0,
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
        : Colors.white.withValues(alpha: 0.96);

    final defaultBorder = Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFFDCE3E1),
      width: isDark ? 1.3 : 1.0,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF182B3A).withValues(alpha: 0.06),
            blurRadius: isDark ? 24 : 16,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? defaultBgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? defaultBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

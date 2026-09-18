import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../theme/app_theme.dart';

/// Prominent Home / health-hub entry for Face Scan. Not a Quick Access tile.
class FaceScanHomeCard extends StatelessWidget {
  const FaceScanHomeCard({
    super.key,
    required this.onStartScan,
    required this.onViewReports,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final VoidCallback onStartScan;
  final VoidCallback onViewReports;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : AppTheme.lightInk;
    final muted = isDark ? Colors.white70 : AppTheme.lightMutedColor;
    final accent = isDark ? const Color(0xFF3DCFB6) : const Color(0xFF0E8F78);

    return Padding(
      padding: padding,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFF16332E), Color(0xFF0F1318)]
                  : const [Color(0xFFE7F7F2), Color(0xFFFCFEFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : const Color(0xFF0E8F78).withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.face_retouching_natural,
                      color: accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Check your vitals',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          'Hold still for 30 seconds to estimate heart rate, breathing, oxygen and blood pressure.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _VitalChip(label: 'Heart rate'),
                  _VitalChip(label: 'Breathing'),
                  _VitalChip(label: 'Oxygen'),
                  _VitalChip(label: 'Blood pressure'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: enabled ? onStartScan : null,
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: const AppText('Start Face Scan'),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: enabled ? onViewReports : null,
                  child: const AppText('View past reports'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalChip extends StatelessWidget {
  const _VitalChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : const Color(0xFF0E8F78).withValues(alpha: 0.16),
        ),
      ),
      child: AppText(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : AppTheme.lightInk,
        ),
      ),
    );
  }
}

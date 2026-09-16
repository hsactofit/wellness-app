import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Keeps Apple Health permission recovery visible after the authorization
/// sheet closes. HealthKit deliberately does not reveal whether read access
/// was granted, so this banner must not describe that state as "connected".
class HealthAccessReviewBanner extends StatelessWidget {
  const HealthAccessReviewBanner({super.key, required this.onReviewAccess});

  final VoidCallback onReviewAccess;

  static bool shouldShow({
    required bool isIos,
    required bool accessRequested,
    required bool syncEnabled,
  }) {
    return isIos && accessRequested && syncEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 28,
              color: AppTheme.actionOf(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Apple Health access requested',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    'Review or change what this app can read in Apple Health.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              key: const Key('reviewAppleHealthAccessButton'),
              onPressed: onReviewAccess,
              child: const AppText('Review Access'),
            ),
          ],
        ),
      ),
    );
  }
}

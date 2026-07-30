import 'package:flutter/material.dart';
import '../models/plan_models.dart';
import '../widgets/glass_card.dart';

/// Member-facing workout/nutrition plan CRUD and AI generation have no
/// backend yet — wellness-server only lets staff manage TrainingPlan /
/// WorkoutSession records for a member, there is no self-service plan
/// endpoint. Shown as a "coming soon" placeholder rather than firing calls
/// against routes that don't exist.
class PlanScreen extends StatelessWidget {
  final PlanKind kind;
  final VoidCallback? onPlanChanged;

  const PlanScreen({
    super.key,
    required this.kind,
    this.onPlanChanged,
  });

  bool get _isWorkout => kind == PlanKind.workout;
  Color get _accent => _isWorkout ? const Color(0xFF5B8CFF) : const Color(0xFFFF9F43);
  String get _title => _isWorkout ? 'Workout Plans' : 'Nutrition Plans';
  String get _emoji => _isWorkout ? '💪' : '🥗';
  String get _subtitle =>
      _isWorkout ? 'Train with a clear daily path' : 'Meals, portions & macros';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF6F8FC),
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withOpacity(isDark ? 0.14 : 0.08),
                    _accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.04),
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        color: isDark ? Colors.white70 : Colors.black87,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _accent.withOpacity(0.12),
                                border: Border.all(color: _accent.withOpacity(0.3), width: 1.5),
                              ),
                              child: Center(
                                child: Text(_emoji, style: const TextStyle(fontSize: 30)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _accent.withOpacity(0.3)),
                              ),
                              child: Text(
                                "COMING SOON",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: _accent,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "$_subtitle — personalized plans and AI-assisted generation are on the way. Check back soon.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

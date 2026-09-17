import 'package:flutter/material.dart';

import '../l10n/app_text.dart';
import '../models/plan_models.dart';
import '../models/workout_muscles.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/workout_muscle_map.dart';

class WorkoutPlanDayScreen extends StatelessWidget {
  const WorkoutPlanDayScreen({super.key, required this.day});

  final WorkoutPlanDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final targets = day.targetMuscles;
    final localizedDay = day.day.localized(context);
    final localizedWorkout = 'Workout'.localized(context);
    final title = switch (Localizations.localeOf(context).languageCode) {
      'hi' => '$localizedDay का $localizedWorkout',
      'kn' => '$localizedDayದ $localizedWorkout',
      _ => '$localizedDay’s $localizedWorkout',
    };

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F12) : AppTheme.lightCanvas,
      appBar: AppBar(
        title: AppText(title, key: const Key('workout-day-title')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            GlassCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      day.isRestDay
                          ? Icons.self_improvement_rounded
                          : Icons.fitness_center_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          day.isRestDay ? 'Rest and recovery' : 'Workout focus',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          day.focus?.trim().isNotEmpty == true
                              ? day.focus!
                              : day.isRestDay
                              ? 'Rest day'
                              : '${day.exercises.length} exercises',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppText(
              'Workout activities',
              key: const Key('workout-day-activities'),
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            if (day.exercises.isEmpty)
              GlassCard(
                margin: EdgeInsets.zero,
                child: AppText(
                  day.isRestDay ? 'Rest day' : 'No activities scheduled.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              )
            else
              ...day.exercises.asMap().entries.map(
                (entry) =>
                    _ExerciseCard(number: entry.key + 1, exercise: entry.value),
              ),
            if (day.exercises.isNotEmpty) ...[
              const SizedBox(height: 24),
              if (targets.isEmpty)
                GlassCard(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: [
                      Icon(
                        Icons.accessibility_new_rounded,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          'Muscle targets unavailable',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                WorkoutMuscleMapCard(
                  key: const Key('workout-day-muscle-map'),
                  targetMuscles: targets,
                  heading: 'Targeted muscles',
                  semanticsPrefix: 'Targeted muscles',
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.number, required this.exercise});

  final int number;
  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return GlassCard(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  exercise.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (exercise.dosageLabel.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  AppText(
                    exercise.dosageLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
                if (exercise.targetMuscles.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  AppText(
                    'Targets: ${workoutTargetMuscleSummary(exercise.targetMuscles)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (exercise.notes?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 7),
                  AppText(
                    exercise.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

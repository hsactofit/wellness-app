import 'package:flutter/material.dart';

import '../models/workout_muscles.dart';

/// A compact, stylized body map for the target muscles in an active workout.
/// It is intentionally neutral and bilateral: a workout plan does not encode
/// left/right or member body characteristics.
class WorkoutMuscleMapCard extends StatelessWidget {
  const WorkoutMuscleMapCard({super.key, required this.targetMuscles});

  final Iterable<String> targetMuscles;

  @override
  Widget build(BuildContext context) {
    final muscles = normalizeWorkoutTargetMuscles(targetMuscles);
    if (muscles.isEmpty) return const SizedBox.shrink();
    final summary = workoutTargetMuscleSummary(muscles);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Target muscles today: $summary',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Muscles targeted today',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                'Highlighted areas are trained in today\'s checklist.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BodyView(
                          label: 'Front',
                          isFront: true,
                          targetMuscles: muscles,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _BodyView(
                          label: 'Back',
                          isFront: false,
                          targetMuscles: muscles,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: muscles
                    .map(
                      (muscle) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(workoutTargetMuscleLabel(muscle)),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyView extends StatelessWidget {
  const _BodyView({
    required this.label,
    required this.isFront,
    required this.targetMuscles,
  });

  final String label;
  final bool isFront;
  final List<String> targetMuscles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        AspectRatio(
          aspectRatio: 0.48,
          child: CustomPaint(
            painter: _MuscleBodyPainter(
              isFront: isFront,
              targetMuscles: targetMuscles.toSet(),
              colorScheme: Theme.of(context).colorScheme,
            ),
          ),
        ),
      ],
    );
  }
}

class _MuscleBodyPainter extends CustomPainter {
  const _MuscleBodyPainter({
    required this.isFront,
    required this.targetMuscles,
    required this.colorScheme,
  });

  final bool isFront;
  final Set<String> targetMuscles;
  final ColorScheme colorScheme;

  bool _isTarget(String muscle) =>
      targetMuscles.contains(fullBodyTargetMuscle) ||
      targetMuscles.contains(muscle);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 220);
    final base = Color.alphaBlend(
      colorScheme.onSurface.withValues(alpha: 0.08),
      colorScheme.surfaceContainerHighest,
    );
    final fill = Paint()..style = PaintingStyle.fill;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = colorScheme.outlineVariant;

    void part(Rect rect, String muscle, {double radius = 9}) {
      fill.color = _isTarget(muscle) ? colorScheme.primary : base;
      final shape = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(shape, fill);
      canvas.drawRRect(shape, outline);
    }

    fill.color = base;
    canvas.drawCircle(const Offset(50, 17), 13, fill);
    canvas.drawCircle(const Offset(50, 17), 13, outline);
    part(const Rect.fromLTWH(44, 28, 12, 13), 'core', radius: 4);

    part(const Rect.fromLTWH(20, 38, 18, 19), 'shoulders');
    part(const Rect.fromLTWH(62, 38, 18, 19), 'shoulders');
    part(const Rect.fromLTWH(28, 46, 44, 31), isFront ? 'chest' : 'upper_back');
    part(const Rect.fromLTWH(33, 76, 34, 39), isFront ? 'core' : 'lats');
    part(const Rect.fromLTWH(31, 108, 38, 21), isFront ? 'core' : 'lower_back');

    part(const Rect.fromLTWH(10, 50, 16, 41), isFront ? 'biceps' : 'triceps');
    part(const Rect.fromLTWH(74, 50, 16, 41), isFront ? 'biceps' : 'triceps');
    part(const Rect.fromLTWH(8, 87, 15, 38), 'forearms');
    part(const Rect.fromLTWH(77, 87, 15, 38), 'forearms');

    part(
      const Rect.fromLTWH(30, 123, 40, 20),
      isFront ? 'quadriceps' : 'glutes',
    );
    part(
      const Rect.fromLTWH(31, 140, 17, 47),
      isFront ? 'quadriceps' : 'hamstrings',
    );
    part(
      const Rect.fromLTWH(52, 140, 17, 47),
      isFront ? 'quadriceps' : 'hamstrings',
    );
    part(const Rect.fromLTWH(43, 143, 6, 40), 'inner_thighs', radius: 3);
    part(const Rect.fromLTWH(51, 143, 6, 40), 'inner_thighs', radius: 3);
    part(const Rect.fromLTWH(33, 184, 14, 31), 'calves');
    part(const Rect.fromLTWH(53, 184, 14, 31), 'calves');
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MuscleBodyPainter oldDelegate) =>
      oldDelegate.isFront != isFront ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.targetMuscles.length != targetMuscles.length ||
      !oldDelegate.targetMuscles.containsAll(targetMuscles);
}

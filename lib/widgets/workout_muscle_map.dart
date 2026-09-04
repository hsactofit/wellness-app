import 'package:flutter/material.dart';

import '../models/workout_muscles.dart';
import 'glass_card.dart';

/// An interactive, neutral anatomy guide for the muscles in an active workout.
///
/// It does not imply a member's body shape or left/right asymmetry. The named
/// target controls are the primary explanation; the paired body views make it
/// immediately clear where each target is located.
class WorkoutMuscleMapCard extends StatefulWidget {
  const WorkoutMuscleMapCard({super.key, required this.targetMuscles});

  final Iterable<String> targetMuscles;

  @override
  State<WorkoutMuscleMapCard> createState() => _WorkoutMuscleMapCardState();
}

class _WorkoutMuscleMapCardState extends State<WorkoutMuscleMapCard> {
  String? _selectedMuscle;

  List<String> get _muscles => normalizeWorkoutTargetMuscles(
    widget.targetMuscles,
  );

  @override
  void didUpdateWidget(covariant WorkoutMuscleMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedMuscle != null && !_muscles.contains(_selectedMuscle)) {
      _selectedMuscle = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final muscles = _muscles;
    if (muscles.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final isFullBody = muscles.singleOrNull == fullBodyTargetMuscle;
    final selectedLocation = _selectedMuscle == null
        ? null
        : _targetMuscleLocations[_selectedMuscle]!;
    final summary = isFullBody
        ? 'Full-body training'
        : workoutTargetMuscleSummary(muscles);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Target muscles today: $summary',
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        color: Color.alphaBlend(
          scheme.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.055
                : 0.025,
          ),
          scheme.surface,
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.72),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MapHeader(isFullBody: isFullBody, targetCount: muscles.length),
            const SizedBox(height: 12),
            if (isFullBody)
              _FullBodyCallout(colorScheme: scheme)
            else ...[
              Text(
                'Tap a target to locate it on the body map.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: muscles
                    .map(
                      (muscle) => _TargetMuscleChip(
                        muscle: muscle,
                        selected: _selectedMuscle == muscle,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMuscle = selected ? muscle : null;
                          });
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
              if (selectedLocation != null) ...[
                const SizedBox(height: 12),
                _FocusCaption(
                  muscle: _selectedMuscle!,
                  location: selectedLocation,
                ),
              ],
            ],
            const SizedBox(height: 14),
            _BodyMapPanel(
              targetMuscles: muscles,
              selectedMuscle: _selectedMuscle,
            ),
            const SizedBox(height: 10),
            _MapKey(isFullBody: isFullBody),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.isFullBody, required this.targetCount});

  final bool isFullBody;
  final int targetCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.accessibility_new_rounded,
            color: scheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s muscle focus',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                isFullBody
                    ? 'A balanced full-body session'
                    : '$targetCount targeted ${targetCount == 1 ? 'area' : 'areas'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FullBodyCallout extends StatelessWidget {
  const _FullBodyCallout({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.all_inclusive_rounded, color: colorScheme.primary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full-body training',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Today\'s exercises work the upper body, core and lower body.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _TargetMuscleChip extends StatelessWidget {
  const _TargetMuscleChip({
    required this.muscle,
    required this.selected,
    required this.onSelected,
  });

  final String muscle;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = workoutTargetMuscleLabel(muscle);
    return Semantics(
      label: '$label target. Tap to locate it on the body map.',
      button: true,
      selected: selected,
      child: ChoiceChip(
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        side: BorderSide(
          color: selected
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: 0.8),
        ),
        avatar: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary
                : scheme.primary.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
        ),
        label: Text(label),
      ),
    );
  }
}

class _FocusCaption extends StatelessWidget {
  const _FocusCaption({required this.muscle, required this.location});

  final String muscle;
  final String location;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location_rounded, size: 17, color: scheme.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${workoutTargetMuscleLabel(muscle)} · $location',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMapPanel extends StatelessWidget {
  const _BodyMapPanel({required this.targetMuscles, required this.selectedMuscle});

  final List<String> targetMuscles;
  final String? selectedMuscle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: selectedMuscle == null
          ? 'Front and back body map. All listed targets are highlighted.'
          : 'Front and back body map. ${workoutTargetMuscleLabel(selectedMuscle!)} is highlighted.',
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.035 : 0.025,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Row(
              children: [
                Expanded(
                  child: _BodyView(
                    label: 'Front',
                    isFront: true,
                    targetMuscles: targetMuscles,
                    selectedMuscle: selectedMuscle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 196,
                  color: scheme.outlineVariant.withValues(alpha: 0.75),
                ),
                Expanded(
                  child: _BodyView(
                    label: 'Back',
                    isFront: false,
                    targetMuscles: targetMuscles,
                    selectedMuscle: selectedMuscle,
                  ),
                ),
              ],
            ),
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
    required this.selectedMuscle,
  });

  final String label;
  final bool isFront;
  final List<String> targetMuscles;
  final String? selectedMuscle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        AspectRatio(
          aspectRatio: 0.66,
          child: CustomPaint(
            painter: _AnatomyBodyPainter(
              isFront: isFront,
              targetMuscles: targetMuscles.toSet(),
              selectedMuscle: selectedMuscle,
              colorScheme: scheme,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapKey extends StatelessWidget {
  const _MapKey({required this.isFullBody});

  final bool isFullBody;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          isFullBody ? 'All major muscle groups' : 'Selected training areas',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AnatomyBodyPainter extends CustomPainter {
  const _AnatomyBodyPainter({
    required this.isFront,
    required this.targetMuscles,
    required this.selectedMuscle,
    required this.colorScheme,
  });

  final bool isFront;
  final Set<String> targetMuscles;
  final String? selectedMuscle;
  final ColorScheme colorScheme;

  bool get _isFullBody => targetMuscles.contains(fullBodyTargetMuscle);

  bool _isTarget(String muscle) => _isFullBody || targetMuscles.contains(muscle);

  bool _isFocused(String muscle) => selectedMuscle == null || selectedMuscle == muscle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 210);

    final bodyColor = Color.alphaBlend(
      colorScheme.onSurface.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.13 : 0.075,
      ),
      colorScheme.surface,
    );
    final bodyPaint = Paint()..color = bodyColor;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color = colorScheme.onSurface.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.32 : 0.17,
      );

    _drawBodyBase(canvas, bodyPaint, outline);

    void drawMuscle(Path path, String muscle) {
      if (!_isTarget(muscle)) return;
      final isFocused = _isFocused(muscle);
      final alpha = _isFullBody
          ? (isFocused ? 0.64 : 0.18)
          : (isFocused ? 0.88 : 0.20);
      final fill = Paint()
        ..color = Color.alphaBlend(
          colorScheme.primary.withValues(alpha: alpha),
          bodyColor,
        );
      canvas.drawPath(path, fill);
      if (selectedMuscle == muscle) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.05
            ..color = colorScheme.primary,
        );
      }
    }

    if (isFront) {
      _drawFrontMuscles(drawMuscle);
    } else {
      _drawBackMuscles(drawMuscle);
    }
    canvas.restore();
  }

  void _drawBodyBase(Canvas canvas, Paint fill, Paint outline) {
    void draw(Path path) {
      canvas.drawPath(path, fill);
      canvas.drawPath(path, outline);
    }

    final head = Path()..addOval(const Rect.fromLTWH(40, 4, 20, 23));
    draw(head);
    draw(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(45, 25, 10, 12),
            const Radius.circular(4),
          ),
        ),
    );

    draw(
      Path()
        ..moveTo(45, 32)
        ..cubicTo(37, 33, 29, 36, 27, 45)
        ..cubicTo(30, 55, 33, 63, 34, 75)
        ..cubicTo(35, 87, 34, 95, 31, 105)
        ..cubicTo(36, 111, 42, 114, 50, 114)
        ..cubicTo(58, 114, 64, 111, 69, 105)
        ..cubicTo(66, 95, 65, 87, 66, 75)
        ..cubicTo(67, 63, 70, 55, 73, 45)
        ..cubicTo(71, 36, 63, 33, 55, 32)
        ..close(),
    );

    final leftArm = Path()
      ..moveTo(30, 41)
      ..cubicTo(22, 43, 17, 49, 17, 61)
      ..lineTo(16, 91)
      ..cubicTo(16, 101, 20, 107, 25, 106)
      ..cubicTo(30, 105, 32, 99, 31, 91)
      ..lineTo(31, 69)
      ..cubicTo(35, 58, 38, 48, 36, 43)
      ..cubicTo(35, 40, 33, 40, 30, 41)
      ..close();
    draw(leftArm);
    canvas.save();
    canvas.translate(100, 0);
    canvas.scale(-1, 1);
    draw(leftArm);
    canvas.restore();

    final leftLeg = Path()
      ..moveTo(36, 106)
      ..cubicTo(31, 120, 31, 144, 34, 166)
      ..lineTo(35, 197)
      ..cubicTo(36, 205, 40, 208, 45, 207)
      ..cubicTo(49, 206, 50, 202, 49, 196)
      ..lineTo(48, 166)
      ..cubicTo(50, 145, 50, 121, 47, 108)
      ..close();
    draw(leftLeg);
    canvas.save();
    canvas.translate(100, 0);
    canvas.scale(-1, 1);
    draw(leftLeg);
    canvas.restore();
  }

  void _drawFrontMuscles(void Function(Path path, String muscle) draw) {
    void oval(Rect rect, String muscle) => draw(Path()..addOval(rect), muscle);
    void rounded(Rect rect, String muscle, [double radius = 4]) => draw(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        ),
      muscle,
    );
    Rect mirror(Rect rect) => Rect.fromLTRB(
      100 - rect.right,
      rect.top,
      100 - rect.left,
      rect.bottom,
    );

    oval(const Rect.fromLTWH(27, 35, 17, 15), 'shoulders');
    oval(mirror(const Rect.fromLTWH(27, 35, 17, 15)), 'shoulders');

    final leftChest = Path()
      ..moveTo(33, 49)
      ..cubicTo(38, 45, 45, 46, 49, 50)
      ..lineTo(49, 63)
      ..cubicTo(42, 64, 35, 62, 32, 57)
      ..close();
    draw(leftChest, 'chest');
    final rightChest = Path()
      ..moveTo(67, 49)
      ..cubicTo(62, 45, 55, 46, 51, 50)
      ..lineTo(51, 63)
      ..cubicTo(58, 64, 65, 62, 68, 57)
      ..close();
    draw(rightChest, 'chest');

    rounded(const Rect.fromLTWH(41, 66, 8, 11), 'core', 3);
    rounded(const Rect.fromLTWH(51, 66, 8, 11), 'core', 3);
    rounded(const Rect.fromLTWH(41, 79, 8, 11), 'core', 3);
    rounded(const Rect.fromLTWH(51, 79, 8, 11), 'core', 3);
    rounded(const Rect.fromLTWH(41, 92, 8, 9), 'core', 3);
    rounded(const Rect.fromLTWH(51, 92, 8, 9), 'core', 3);

    oval(const Rect.fromLTWH(19, 53, 11, 26), 'biceps');
    oval(mirror(const Rect.fromLTWH(19, 53, 11, 26)), 'biceps');
    oval(const Rect.fromLTWH(18, 79, 10, 22), 'forearms');
    oval(mirror(const Rect.fromLTWH(18, 79, 10, 22)), 'forearms');

    oval(const Rect.fromLTWH(34, 111, 13, 50), 'quadriceps');
    oval(mirror(const Rect.fromLTWH(34, 111, 13, 50)), 'quadriceps');
    rounded(const Rect.fromLTWH(45, 115, 4, 43), 'inner_thighs', 2);
    rounded(const Rect.fromLTWH(51, 115, 4, 43), 'inner_thighs', 2);
    oval(const Rect.fromLTWH(36, 166, 11, 33), 'calves');
    oval(mirror(const Rect.fromLTWH(36, 166, 11, 33)), 'calves');
  }

  void _drawBackMuscles(void Function(Path path, String muscle) draw) {
    void oval(Rect rect, String muscle) => draw(Path()..addOval(rect), muscle);
    void rounded(Rect rect, String muscle, [double radius = 4]) => draw(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        ),
      muscle,
    );
    Rect mirror(Rect rect) => Rect.fromLTRB(
      100 - rect.right,
      rect.top,
      100 - rect.left,
      rect.bottom,
    );

    oval(const Rect.fromLTWH(27, 35, 17, 15), 'shoulders');
    oval(mirror(const Rect.fromLTWH(27, 35, 17, 15)), 'shoulders');

    final upperBack = Path()
      ..moveTo(33, 48)
      ..cubicTo(40, 43, 60, 43, 67, 48)
      ..lineTo(64, 66)
      ..cubicTo(56, 71, 44, 71, 36, 66)
      ..close();
    draw(upperBack, 'upper_back');
    final leftLat = Path()
      ..moveTo(36, 67)
      ..cubicTo(40, 69, 45, 70, 49, 69)
      ..lineTo(49, 92)
      ..cubicTo(43, 93, 37, 89, 35, 81)
      ..close();
    draw(leftLat, 'lats');
    final rightLat = Path()
      ..moveTo(64, 67)
      ..cubicTo(60, 69, 55, 70, 51, 69)
      ..lineTo(51, 92)
      ..cubicTo(57, 93, 63, 89, 65, 81)
      ..close();
    draw(rightLat, 'lats');
    rounded(const Rect.fromLTWH(42, 89, 7, 14), 'lower_back', 3);
    rounded(const Rect.fromLTWH(51, 89, 7, 14), 'lower_back', 3);

    oval(const Rect.fromLTWH(19, 53, 11, 26), 'triceps');
    oval(mirror(const Rect.fromLTWH(19, 53, 11, 26)), 'triceps');
    oval(const Rect.fromLTWH(18, 79, 10, 22), 'forearms');
    oval(mirror(const Rect.fromLTWH(18, 79, 10, 22)), 'forearms');

    oval(const Rect.fromLTWH(34, 104, 15, 18), 'glutes');
    oval(mirror(const Rect.fromLTWH(34, 104, 15, 18)), 'glutes');
    oval(const Rect.fromLTWH(34, 122, 13, 42), 'hamstrings');
    oval(mirror(const Rect.fromLTWH(34, 122, 13, 42)), 'hamstrings');
    oval(const Rect.fromLTWH(36, 166, 11, 33), 'calves');
    oval(mirror(const Rect.fromLTWH(36, 166, 11, 33)), 'calves');
  }

  @override
  bool shouldRepaint(covariant _AnatomyBodyPainter oldDelegate) =>
      oldDelegate.isFront != isFront ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.selectedMuscle != selectedMuscle ||
      oldDelegate.targetMuscles.length != targetMuscles.length ||
      !oldDelegate.targetMuscles.containsAll(targetMuscles);
}

const Map<String, String> _targetMuscleLocations = {
  'chest': 'front chest',
  'shoulders': 'upper shoulders',
  'biceps': 'front upper arms',
  'triceps': 'back upper arms',
  'forearms': 'lower arms',
  'core': 'abdomen and midsection',
  'upper_back': 'upper back',
  'lats': 'sides of the back',
  'lower_back': 'lower back',
  'glutes': 'hips and glutes',
  'quadriceps': 'front thighs',
  'hamstrings': 'back thighs',
  'inner_thighs': 'inner thighs',
  'calves': 'lower legs',
};

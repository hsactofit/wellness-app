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

    final bodyColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFFD5A48B)
        : const Color(0xFFE7B69D);
    final targetColor = colorScheme.brightness == Brightness.dark
        ? const Color(0xFFFF6254)
        : const Color(0xFFE5483A);
    final bodyPaint = Paint()..color = bodyColor;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = colorScheme.brightness == Brightness.dark
          ? const Color(0xFF8B5C52)
          : const Color(0xFFB57667);

    _drawBodyBase(canvas, bodyPaint, outline);

    void drawMuscle(Path path, String muscle) {
      if (!_isTarget(muscle)) return;
      final isFocused = _isFocused(muscle);
      final fill = Paint()
        ..color = isFocused
            ? targetColor
            : Color.alphaBlend(targetColor.withValues(alpha: 0.28), bodyColor);
      canvas.drawPath(path, fill);
      if (selectedMuscle == muscle) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.9
            ..color = const Color(0xFFFFA69E),
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

    final head = Path()..addOval(const Rect.fromLTWH(40.5, 3, 19, 22));
    draw(head);
    draw(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(45, 23, 10, 14),
            const Radius.circular(4.5),
          ),
        ),
    );

    draw(
      Path()
        ..moveTo(45, 32)
        ..cubicTo(37, 33, 30, 36, 27, 44)
        ..cubicTo(29, 52, 32, 61, 33, 72)
        ..cubicTo(35, 83, 34, 94, 31, 106)
        ..cubicTo(35, 113, 41, 117, 50, 118)
        ..cubicTo(59, 117, 65, 113, 69, 106)
        ..cubicTo(66, 94, 65, 83, 67, 72)
        ..cubicTo(68, 61, 71, 52, 73, 44)
        ..cubicTo(70, 36, 63, 33, 55, 32)
        ..close(),
    );

    final leftArm = Path()
      ..moveTo(31, 39)
      ..cubicTo(23, 40, 17, 47, 16, 59)
      ..lineTo(14, 90)
      ..cubicTo(14, 100, 16, 108, 19, 113)
      ..cubicTo(20, 117, 20, 122, 19, 126)
      ..cubicTo(20, 129, 23, 130, 25, 128)
      ..cubicTo(27, 126, 28, 119, 28, 113)
      ..cubicTo(31, 105, 31, 96, 30, 88)
      ..lineTo(30, 69)
      ..cubicTo(34, 56, 37, 47, 36, 42)
      ..cubicTo(35, 39, 33, 38, 31, 39)
      ..close();
    draw(leftArm);
    canvas.save();
    canvas.translate(100, 0);
    canvas.scale(-1, 1);
    draw(leftArm);
    canvas.restore();

    final leftLeg = Path()
      ..moveTo(36, 112)
      ..cubicTo(31, 126, 31, 148, 34, 169)
      ..lineTo(35, 196)
      ..cubicTo(35, 203, 34, 209, 31, 213)
      ..cubicTo(33, 216, 41, 216, 45, 214)
      ..cubicTo(49, 211, 50, 206, 49, 198)
      ..lineTo(48, 170)
      ..cubicTo(51, 148, 50, 126, 47, 113)
      ..close();
    draw(leftLeg);
    canvas.save();
    canvas.translate(100, 0);
    canvas.scale(-1, 1);
    draw(leftLeg);
    canvas.restore();
  }

  void _drawFrontMuscles(void Function(Path path, String muscle) draw) {
    final leftShoulder = Path()
      ..moveTo(30, 37)
      ..cubicTo(24, 38, 21, 43, 22, 49)
      ..cubicTo(25, 53, 30, 54, 35, 52)
      ..cubicTo(39, 49, 40, 43, 37, 39)
      ..close();
    draw(leftShoulder, 'shoulders');
    final rightShoulder = Path()
      ..moveTo(70, 37)
      ..cubicTo(76, 38, 79, 43, 78, 49)
      ..cubicTo(75, 53, 70, 54, 65, 52)
      ..cubicTo(61, 49, 60, 43, 63, 39)
      ..close();
    draw(rightShoulder, 'shoulders');

    final leftChest = Path()
      ..moveTo(34, 49)
      ..cubicTo(38, 44, 45, 45, 49, 49)
      ..lineTo(49, 63)
      ..cubicTo(43, 64, 36, 61, 33, 56)
      ..close();
    draw(leftChest, 'chest');
    final rightChest = Path()
      ..moveTo(66, 49)
      ..cubicTo(62, 44, 55, 45, 51, 49)
      ..lineTo(51, 63)
      ..cubicTo(57, 64, 64, 61, 67, 56)
      ..close();
    draw(rightChest, 'chest');

    final leftOblique = Path()
      ..moveTo(35, 63)
      ..cubicTo(38, 65, 40, 69, 40, 80)
      ..lineTo(39, 95)
      ..cubicTo(36, 93, 34, 88, 34, 80)
      ..close();
    draw(leftOblique, 'core');
    final rightOblique = Path()
      ..moveTo(65, 63)
      ..cubicTo(62, 65, 60, 69, 60, 80)
      ..lineTo(61, 95)
      ..cubicTo(64, 93, 66, 88, 66, 80)
      ..close();
    draw(rightOblique, 'core');
    for (final rect in const [
      Rect.fromLTWH(42, 65, 7, 9),
      Rect.fromLTWH(51, 65, 7, 9),
      Rect.fromLTWH(42, 76, 7, 9),
      Rect.fromLTWH(51, 76, 7, 9),
      Rect.fromLTWH(42, 87, 7, 8),
      Rect.fromLTWH(51, 87, 7, 8),
    ]) {
      draw(
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(2.8)),
          ),
        'core',
      );
    }

    final leftBiceps = Path()
      ..moveTo(20, 54)
      ..cubicTo(17, 60, 17, 69, 20, 76)
      ..cubicTo(23, 80, 28, 79, 29, 74)
      ..lineTo(29, 60)
      ..cubicTo(27, 54, 23, 52, 20, 54)
      ..close();
    draw(leftBiceps, 'biceps');
    final rightBiceps = Path()
      ..moveTo(80, 54)
      ..cubicTo(83, 60, 83, 69, 80, 76)
      ..cubicTo(77, 80, 72, 79, 71, 74)
      ..lineTo(71, 60)
      ..cubicTo(73, 54, 77, 52, 80, 54)
      ..close();
    draw(rightBiceps, 'biceps');

    final leftForearm = Path()
      ..moveTo(18, 78)
      ..cubicTo(15, 85, 15, 98, 19, 104)
      ..cubicTo(22, 107, 26, 104, 27, 99)
      ..lineTo(27, 84)
      ..cubicTo(25, 79, 21, 77, 18, 78)
      ..close();
    draw(leftForearm, 'forearms');
    final rightForearm = Path()
      ..moveTo(82, 78)
      ..cubicTo(85, 85, 85, 98, 81, 104)
      ..cubicTo(78, 107, 74, 104, 73, 99)
      ..lineTo(73, 84)
      ..cubicTo(75, 79, 79, 77, 82, 78)
      ..close();
    draw(rightForearm, 'forearms');

    final leftQuad = Path()
      ..moveTo(35, 116)
      ..cubicTo(31, 129, 32, 150, 35, 165)
      ..cubicTo(38, 170, 44, 169, 46, 164)
      ..lineTo(47, 124)
      ..cubicTo(45, 117, 39, 113, 35, 116)
      ..close();
    draw(leftQuad, 'quadriceps');
    final rightQuad = Path()
      ..moveTo(65, 116)
      ..cubicTo(69, 129, 68, 150, 65, 165)
      ..cubicTo(62, 170, 56, 169, 54, 164)
      ..lineTo(53, 124)
      ..cubicTo(55, 117, 61, 113, 65, 116)
      ..close();
    draw(rightQuad, 'quadriceps');

    final leftInnerThigh = Path()
      ..moveTo(45, 119)
      ..cubicTo(43, 134, 43, 151, 45, 161)
      ..cubicTo(47, 164, 49, 161, 49, 157)
      ..lineTo(48, 123)
      ..close();
    draw(leftInnerThigh, 'inner_thighs');
    final rightInnerThigh = Path()
      ..moveTo(55, 119)
      ..cubicTo(57, 134, 57, 151, 55, 161)
      ..cubicTo(53, 164, 51, 161, 51, 157)
      ..lineTo(52, 123)
      ..close();
    draw(rightInnerThigh, 'inner_thighs');

    final leftCalf = Path()
      ..moveTo(36, 169)
      ..cubicTo(33, 181, 34, 196, 38, 202)
      ..cubicTo(42, 205, 46, 200, 46, 194)
      ..lineTo(46, 177)
      ..cubicTo(44, 171, 40, 168, 36, 169)
      ..close();
    draw(leftCalf, 'calves');
    final rightCalf = Path()
      ..moveTo(64, 169)
      ..cubicTo(67, 181, 66, 196, 62, 202)
      ..cubicTo(58, 205, 54, 200, 54, 194)
      ..lineTo(54, 177)
      ..cubicTo(56, 171, 60, 168, 64, 169)
      ..close();
    draw(rightCalf, 'calves');
  }

  void _drawBackMuscles(void Function(Path path, String muscle) draw) {
    final leftShoulder = Path()
      ..moveTo(30, 37)
      ..cubicTo(24, 38, 21, 43, 22, 49)
      ..cubicTo(25, 53, 30, 54, 35, 52)
      ..cubicTo(39, 49, 40, 43, 37, 39)
      ..close();
    draw(leftShoulder, 'shoulders');
    final rightShoulder = Path()
      ..moveTo(70, 37)
      ..cubicTo(76, 38, 79, 43, 78, 49)
      ..cubicTo(75, 53, 70, 54, 65, 52)
      ..cubicTo(61, 49, 60, 43, 63, 39)
      ..close();
    draw(rightShoulder, 'shoulders');

    final upperBack = Path()
      ..moveTo(37, 44)
      ..cubicTo(41, 39, 46, 37, 50, 37)
      ..cubicTo(54, 37, 59, 39, 63, 44)
      ..lineTo(65, 60)
      ..cubicTo(58, 66, 42, 66, 35, 60)
      ..close();
    draw(upperBack, 'upper_back');
    final leftLat = Path()
      ..moveTo(36, 62)
      ..cubicTo(40, 64, 45, 65, 49, 64)
      ..lineTo(49, 93)
      ..cubicTo(43, 95, 37, 90, 35, 80)
      ..close();
    draw(leftLat, 'lats');
    final rightLat = Path()
      ..moveTo(64, 62)
      ..cubicTo(60, 64, 55, 65, 51, 64)
      ..lineTo(51, 93)
      ..cubicTo(57, 95, 63, 90, 65, 80)
      ..close();
    draw(rightLat, 'lats');

    final leftLowerBack = Path()
      ..moveTo(42, 91)
      ..cubicTo(44, 88, 47, 88, 49, 91)
      ..lineTo(49, 105)
      ..cubicTo(46, 106, 43, 104, 42, 99)
      ..close();
    draw(leftLowerBack, 'lower_back');
    final rightLowerBack = Path()
      ..moveTo(58, 91)
      ..cubicTo(56, 88, 53, 88, 51, 91)
      ..lineTo(51, 105)
      ..cubicTo(54, 106, 57, 104, 58, 99)
      ..close();
    draw(rightLowerBack, 'lower_back');

    final leftTriceps = Path()
      ..moveTo(20, 54)
      ..cubicTo(17, 61, 17, 70, 20, 77)
      ..cubicTo(23, 80, 28, 78, 29, 73)
      ..lineTo(29, 59)
      ..cubicTo(27, 54, 23, 52, 20, 54)
      ..close();
    draw(leftTriceps, 'triceps');
    final rightTriceps = Path()
      ..moveTo(80, 54)
      ..cubicTo(83, 61, 83, 70, 80, 77)
      ..cubicTo(77, 80, 72, 78, 71, 73)
      ..lineTo(71, 59)
      ..cubicTo(73, 54, 77, 52, 80, 54)
      ..close();
    draw(rightTriceps, 'triceps');

    final leftForearm = Path()
      ..moveTo(18, 78)
      ..cubicTo(15, 85, 15, 98, 19, 104)
      ..cubicTo(22, 107, 26, 104, 27, 99)
      ..lineTo(27, 84)
      ..cubicTo(25, 79, 21, 77, 18, 78)
      ..close();
    draw(leftForearm, 'forearms');
    final rightForearm = Path()
      ..moveTo(82, 78)
      ..cubicTo(85, 85, 85, 98, 81, 104)
      ..cubicTo(78, 107, 74, 104, 73, 99)
      ..lineTo(73, 84)
      ..cubicTo(75, 79, 79, 77, 82, 78)
      ..close();
    draw(rightForearm, 'forearms');

    final leftGlute = Path()
      ..moveTo(35, 105)
      ..cubicTo(32, 108, 32, 116, 36, 120)
      ..cubicTo(40, 124, 47, 122, 49, 117)
      ..lineTo(49, 106)
      ..cubicTo(45, 103, 39, 102, 35, 105)
      ..close();
    draw(leftGlute, 'glutes');
    final rightGlute = Path()
      ..moveTo(65, 105)
      ..cubicTo(68, 108, 68, 116, 64, 120)
      ..cubicTo(60, 124, 53, 122, 51, 117)
      ..lineTo(51, 106)
      ..cubicTo(55, 103, 61, 102, 65, 105)
      ..close();
    draw(rightGlute, 'glutes');

    final leftHamstring = Path()
      ..moveTo(35, 121)
      ..cubicTo(31, 135, 32, 153, 35, 166)
      ..cubicTo(38, 171, 44, 169, 46, 164)
      ..lineTo(47, 128)
      ..cubicTo(45, 122, 39, 119, 35, 121)
      ..close();
    draw(leftHamstring, 'hamstrings');
    final rightHamstring = Path()
      ..moveTo(65, 121)
      ..cubicTo(69, 135, 68, 153, 65, 166)
      ..cubicTo(62, 171, 56, 169, 54, 164)
      ..lineTo(53, 128)
      ..cubicTo(55, 122, 61, 119, 65, 121)
      ..close();
    draw(rightHamstring, 'hamstrings');

    final leftCalf = Path()
      ..moveTo(36, 169)
      ..cubicTo(33, 181, 34, 196, 38, 202)
      ..cubicTo(42, 205, 46, 200, 46, 194)
      ..lineTo(46, 177)
      ..cubicTo(44, 171, 40, 168, 36, 169)
      ..close();
    draw(leftCalf, 'calves');
    final rightCalf = Path()
      ..moveTo(64, 169)
      ..cubicTo(67, 181, 66, 196, 62, 202)
      ..cubicTo(58, 205, 54, 200, 54, 194)
      ..lineTo(54, 177)
      ..cubicTo(56, 171, 60, 168, 64, 169)
      ..close();
    draw(rightCalf, 'calves');
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

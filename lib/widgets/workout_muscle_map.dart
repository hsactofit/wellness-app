import 'package:flutter/material.dart';

import '../models/workout_muscles.dart';
import 'glass_card.dart';

/// An interactive, neutral anatomy guide for the muscles in an active workout.
///
/// It does not imply a member's body shape or left/right asymmetry. The named
/// target controls are the primary explanation; the detailed front/back view
/// makes it immediately clear where each target is located.
class WorkoutMuscleMapCard extends StatefulWidget {
  const WorkoutMuscleMapCard({super.key, required this.targetMuscles});

  final Iterable<String> targetMuscles;

  @override
  State<WorkoutMuscleMapCard> createState() => _WorkoutMuscleMapCardState();
}

class _WorkoutMuscleMapCardState extends State<WorkoutMuscleMapCard> {
  String? _selectedMuscle;

  List<String> get _muscles =>
      normalizeWorkoutTargetMuscles(widget.targetMuscles);

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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 1),
              Text(
                isFullBody
                    ? 'A balanced full-body session'
                    : '$targetCount targeted ${targetCount == 1 ? 'area' : 'areas'}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
  const _BodyMapPanel({
    required this.targetMuscles,
    required this.selectedMuscle,
  });

  final List<String> targetMuscles;
  final String? selectedMuscle;

  @override
  Widget build(BuildContext context) {
    return _DetailedAnatomyBodyMap(
      targetMuscles: targetMuscles,
      selectedMuscle: selectedMuscle,
    );
  }
}

enum _AnatomyMapView { front, back }

class _DetailedAnatomyBodyMap extends StatefulWidget {
  const _DetailedAnatomyBodyMap({
    required this.targetMuscles,
    required this.selectedMuscle,
  });

  final List<String> targetMuscles;
  final String? selectedMuscle;

  @override
  State<_DetailedAnatomyBodyMap> createState() =>
      _DetailedAnatomyBodyMapState();
}

class _DetailedAnatomyBodyMapState extends State<_DetailedAnatomyBodyMap> {
  _AnatomyMapView _view = _AnatomyMapView.front;

  @override
  void didUpdateWidget(covariant _DetailedAnatomyBodyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.selectedMuscle;
    if (selected != null && selected != oldWidget.selectedMuscle) {
      _view = _preferredAnatomyView(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedLabel = widget.selectedMuscle == null
        ? null
        : workoutTargetMuscleLabel(widget.selectedMuscle!);
    final figureWidth = MediaQuery.sizeOf(context).height >= 720 ? 150.0 : 84.0;

    return Semantics(
      label: selectedLabel == null
          ? 'Detailed front and back anatomy map. All listed targets are highlighted in red.'
          : 'Detailed ${_view.name} anatomy map. $selectedLabel is focused in red.',
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF151113),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.78),
          ),
        ),
        child: Column(
          children: [
            _AnatomyViewSwitch(
              value: _view,
              onChanged: (view) => setState(() => _view = view),
            ),
            const SizedBox(height: 7),
            _DetailedAnatomyFigure(
              width: figureWidth,
              view: _view,
              targetMuscles: widget.targetMuscles.toSet(),
              selectedMuscle: widget.selectedMuscle,
              colorScheme: scheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnatomyViewSwitch extends StatelessWidget {
  const _AnatomyViewSwitch({required this.value, required this.onChanged});

  final _AnatomyMapView value;
  final ValueChanged<_AnatomyMapView> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          _AnatomyViewOption(
            label: 'Front',
            icon: Icons.accessibility_new_rounded,
            selected: value == _AnatomyMapView.front,
            onTap: () => onChanged(_AnatomyMapView.front),
          ),
          _AnatomyViewOption(
            label: 'Back',
            icon: Icons.accessibility_new_rounded,
            selected: value == _AnatomyMapView.back,
            onTap: () => onChanged(_AnatomyMapView.back),
          ),
        ],
      ),
    );
  }
}

class _AnatomyViewOption extends StatelessWidget {
  const _AnatomyViewOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: '$label view',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? scheme.primary.withValues(alpha: 0.20) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? scheme.primary : const Color(0xFFC9BBB5),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? scheme.onSurface
                          : const Color(0xFFC9BBB5),
                      fontWeight: FontWeight.w800,
                    ),
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

class _DetailedAnatomyFigure extends StatelessWidget {
  const _DetailedAnatomyFigure({
    required this.width,
    required this.view,
    required this.targetMuscles,
    required this.selectedMuscle,
    required this.colorScheme,
  });

  static const _assetPath = 'assets/workouts/anatomy_body_map_neutral_v2.png';

  final double width;
  final _AnatomyMapView view;
  final Set<String> targetMuscles;
  final String? selectedMuscle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: const AssetImage(_assetPath),
                fit: BoxFit.cover,
                alignment: view == _AnatomyMapView.front
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                filterQuality: FilterQuality.high,
              ),
              CustomPaint(
                painter: _DetailedAnatomyHighlightPainter(
                  isFront: view == _AnatomyMapView.front,
                  targetMuscles: targetMuscles,
                  selectedMuscle: selectedMuscle,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailedAnatomyHighlightPainter extends CustomPainter {
  const _DetailedAnatomyHighlightPainter({
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

  bool _isTarget(String muscle) =>
      _isFullBody || targetMuscles.contains(muscle);

  bool _isFocused(String muscle) =>
      selectedMuscle == null || selectedMuscle == muscle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 512, size.height / 1536);

    void draw(String muscle, List<Path> paths) {
      if (!_isTarget(muscle)) return;
      final isFocused = _isFocused(muscle);
      final fill = Paint()
        ..color = colorScheme.primary.withValues(
          alpha: isFocused ? 0.78 : 0.28,
        );
      for (final path in paths) {
        canvas.drawPath(path, fill);
        if (selectedMuscle == muscle) {
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4.5
              ..color = const Color(0xFFFFD3CC).withValues(alpha: 0.9),
          );
        }
      }
    }

    if (isFront) {
      _drawFrontRegions(draw);
    } else {
      _drawBackRegions(draw);
    }
    canvas.restore();
  }

  void _drawFrontRegions(void Function(String, List<Path>) draw) {
    Path lobe(double left, double top, double right, double bottom) => Path()
      ..moveTo((left + right) / 2, top)
      ..cubicTo(left, top + 14, left, bottom - 20, (left + right) / 2, bottom)
      ..cubicTo(right, bottom - 20, right, top + 14, (left + right) / 2, top)
      ..close();

    draw('shoulders', [
      Path()
        ..moveTo(82, 298)
        ..cubicTo(55, 318, 50, 365, 82, 399)
        ..cubicTo(117, 407, 160, 374, 169, 332)
        ..cubicTo(145, 301, 112, 288, 82, 298)
        ..close(),
      Path()
        ..moveTo(430, 298)
        ..cubicTo(457, 318, 462, 365, 430, 399)
        ..cubicTo(395, 407, 352, 374, 343, 332)
        ..cubicTo(367, 301, 400, 288, 430, 298)
        ..close(),
    ]);
    draw('chest', [
      Path()
        ..moveTo(166, 355)
        ..cubicTo(199, 333, 238, 342, 251, 371)
        ..lineTo(251, 452)
        ..cubicTo(204, 467, 163, 443, 153, 402)
        ..close(),
      Path()
        ..moveTo(346, 355)
        ..cubicTo(313, 333, 274, 342, 261, 371)
        ..lineTo(261, 452)
        ..cubicTo(308, 467, 349, 443, 359, 402)
        ..close(),
    ]);
    draw('biceps', [lobe(54, 415, 137, 560), lobe(375, 415, 458, 560)]);
    draw('forearms', [lobe(19, 554, 126, 744), lobe(386, 554, 493, 744)]);
    draw('core', [
      Path()
        ..moveTo(200, 447)
        ..cubicTo(170, 490, 169, 584, 198, 653)
        ..lineTo(314, 653)
        ..cubicTo(343, 584, 342, 490, 312, 447)
        ..close(),
      ...[
        const Rect.fromLTWH(207, 462, 42, 53),
        const Rect.fromLTWH(263, 462, 42, 53),
        const Rect.fromLTWH(207, 524, 42, 55),
        const Rect.fromLTWH(263, 524, 42, 55),
        const Rect.fromLTWH(208, 590, 41, 52),
        const Rect.fromLTWH(263, 590, 41, 52),
      ].map(
        (rect) => Path()
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12))),
      ),
    ]);
    draw('quadriceps', [lobe(113, 699, 238, 970), lobe(274, 699, 399, 970)]);
    draw('inner_thighs', [lobe(205, 699, 258, 963), lobe(254, 699, 307, 963)]);
    draw('calves', [lobe(126, 1033, 232, 1289), lobe(280, 1033, 386, 1289)]);
  }

  void _drawBackRegions(void Function(String, List<Path>) draw) {
    Path lobe(double left, double top, double right, double bottom) => Path()
      ..moveTo((left + right) / 2, top)
      ..cubicTo(left, top + 14, left, bottom - 20, (left + right) / 2, bottom)
      ..cubicTo(right, bottom - 20, right, top + 14, (left + right) / 2, top)
      ..close();

    draw('shoulders', [
      Path()
        ..moveTo(80, 302)
        ..cubicTo(52, 322, 52, 371, 86, 399)
        ..cubicTo(119, 405, 159, 374, 170, 332)
        ..cubicTo(147, 303, 111, 290, 80, 302)
        ..close(),
      Path()
        ..moveTo(432, 302)
        ..cubicTo(460, 322, 460, 371, 426, 399)
        ..cubicTo(393, 405, 353, 374, 342, 332)
        ..cubicTo(365, 303, 401, 290, 432, 302)
        ..close(),
    ]);
    draw('upper_back', [
      Path()
        ..moveTo(190, 282)
        ..cubicTo(215, 249, 244, 242, 256, 242)
        ..cubicTo(268, 242, 297, 249, 322, 282)
        ..lineTo(345, 446)
        ..cubicTo(294, 474, 218, 474, 167, 446)
        ..close(),
    ]);
    draw('lats', [
      Path()
        ..moveTo(163, 422)
        ..cubicTo(190, 443, 217, 451, 246, 445)
        ..lineTo(246, 640)
        ..cubicTo(199, 662, 157, 623, 148, 536)
        ..close(),
      Path()
        ..moveTo(349, 422)
        ..cubicTo(322, 443, 295, 451, 266, 445)
        ..lineTo(266, 640)
        ..cubicTo(313, 662, 355, 623, 364, 536)
        ..close(),
    ]);
    draw('lower_back', [
      Path()
        ..moveTo(209, 603)
        ..cubicTo(226, 583, 244, 581, 256, 595)
        ..lineTo(256, 707)
        ..cubicTo(230, 702, 211, 677, 209, 637)
        ..close(),
      Path()
        ..moveTo(303, 603)
        ..cubicTo(286, 583, 268, 581, 256, 595)
        ..lineTo(256, 707)
        ..cubicTo(282, 702, 301, 677, 303, 637)
        ..close(),
    ]);
    draw('triceps', [lobe(54, 420, 139, 565), lobe(373, 420, 458, 565)]);
    draw('forearms', [lobe(18, 554, 126, 744), lobe(386, 554, 494, 744)]);
    draw('glutes', [
      Path()
        ..moveTo(150, 693)
        ..cubicTo(118, 729, 131, 802, 186, 823)
        ..cubicTo(228, 837, 252, 795, 248, 729)
        ..cubicTo(219, 690, 181, 676, 150, 693)
        ..close(),
      Path()
        ..moveTo(362, 693)
        ..cubicTo(394, 729, 381, 802, 326, 823)
        ..cubicTo(284, 837, 260, 795, 264, 729)
        ..cubicTo(293, 690, 331, 676, 362, 693)
        ..close(),
    ]);
    draw('hamstrings', [lobe(112, 813, 240, 1030), lobe(272, 813, 400, 1030)]);
    draw('calves', [lobe(124, 1040, 232, 1290), lobe(280, 1040, 388, 1290)]);
  }

  @override
  bool shouldRepaint(covariant _DetailedAnatomyHighlightPainter oldDelegate) =>
      oldDelegate.isFront != isFront ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.selectedMuscle != selectedMuscle ||
      oldDelegate.targetMuscles.length != targetMuscles.length ||
      !oldDelegate.targetMuscles.containsAll(targetMuscles);
}

_AnatomyMapView _preferredAnatomyView(String muscle) {
  switch (muscle) {
    case 'triceps':
    case 'upper_back':
    case 'lats':
    case 'lower_back':
    case 'glutes':
    case 'hamstrings':
      return _AnatomyMapView.back;
    default:
      return _AnatomyMapView.front;
  }
}

// Retained only for legacy golden comparison while the detailed asset settles.
// ignore: unused_element
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
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isFullBody ? 'All major muscle groups' : 'Selected training areas',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
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

  bool _isTarget(String muscle) =>
      _isFullBody || targetMuscles.contains(muscle);

  bool _isFocused(String muscle) =>
      selectedMuscle == null || selectedMuscle == muscle;

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
      Path()..addRRect(
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
          ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2.8))),
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/plan_models.dart';
import 'package:wellnessconnect/models/workout_muscles.dart';
import 'package:wellnessconnect/widgets/workout_muscle_map.dart';

void main() {
  test('normalizes target muscles and gives full body precedence', () {
    expect(normalizeWorkoutTargetMuscles(['Triceps', 'biceps', 'biceps']), [
      'biceps',
      'triceps',
    ]);
    expect(normalizeWorkoutTargetMuscles(['calves', 'full_body']), [
      fullBodyTargetMuscle,
    ]);
  });

  test('collects unique target muscles from the active session snapshot', () {
    expect(
      targetMusclesForWorkoutSnapshot([
        {
          'name': 'Curl',
          'target_muscles': ['biceps', 'forearms'],
        },
        {
          'name': 'Extension',
          'target_muscles': ['triceps', 'biceps'],
        },
      ]),
      ['biceps', 'triceps', 'forearms'],
    );
  });

  test('parses target muscles from a reviewed workout plan', () {
    final plan = WorkoutPlan.fromReviewedJson({
      'id': 'plan-1',
      'content': [
        {
          'day': 'Monday',
          'exercises': [
            {
              'name': 'Curl',
              'target_muscles': ['biceps', 'forearms'],
            },
          ],
        },
      ],
    });

    expect(plan.days.single.exercises.single.targetMuscles, [
      'biceps',
      'forearms',
    ]);
  });

  test('uses the approved workout session settings instead of defaults', () {
    final plan = WorkoutPlan.fromReviewedJson({
      'id': 'plan-1',
      'session_minutes': 60,
      'days_per_week': 6,
      'content': const [],
    });

    expect(plan.sessionMinutes, 60);
    expect(plan.daysPerWeek, 6);
  });

  testWidgets('shows an interactive front and back anatomy guide', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WorkoutMuscleMapCard(targetMuscles: ['biceps', 'triceps']),
        ),
      ),
    );

    expect(find.text('Today\'s muscle focus'), findsOneWidget);
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Biceps'), findsOneWidget);
    expect(find.text('Triceps'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Target muscles today: Biceps, Triceps'),
      findsOneWidget,
    );

    await tester.tap(find.text('Biceps'));
    await tester.pump();

    expect(find.text('Biceps · front upper arms'), findsOneWidget);
  });

  testWidgets('explains a full-body workout without an ambiguous label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WorkoutMuscleMapCard(targetMuscles: ['full_body']),
        ),
      ),
    );

    expect(find.text('Full-body training'), findsOneWidget);
    expect(
      find.text('Today\'s exercises work the upper body, core and lower body.'),
      findsOneWidget,
    );
  });

  testWidgets('renders a polished full-body guide in dark mode', (
    tester,
  ) async {
    const mapKey = Key('full-body-muscle-map');
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(
          body: ColoredBox(
            color: Color(0xFF0A0D10),
            child: Center(
              child: SizedBox(
                width: 390,
                child: RepaintBoundary(
                  key: mapKey,
                  child: WorkoutMuscleMapCard(targetMuscles: ['full_body']),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(mapKey),
      matchesGoldenFile('goldens/workout_muscle_map_full_body_dark.png'),
    );
  });
}

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

  testWidgets('shows front and back body views with target labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WorkoutMuscleMapCard(targetMuscles: ['biceps', 'triceps']),
        ),
      ),
    );

    expect(find.text('Muscles targeted today'), findsOneWidget);
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Biceps'), findsOneWidget);
    expect(find.text('Triceps'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Target muscles today: Biceps, Triceps'),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/l10n/app_text.dart';
import 'package:wellnessconnect/models/plan_models.dart';
import 'package:wellnessconnect/screens/workout_plan_day_screen.dart';

void main() {
  const workoutDay = WorkoutPlanDay(
    day: 'Monday',
    focus: 'Upper body strength and core',
    exercises: [
      WorkoutExercise(
        name: 'Push-up with a deliberately long activity name',
        sets: 3,
        reps: '12',
        restSec: 45,
        notes: 'Keep your core braced.',
        targetMuscles: ['chest', 'triceps'],
      ),
      WorkoutExercise(
        name: 'Plank',
        sets: 3,
        reps: '30 seconds',
        targetMuscles: ['core', 'chest'],
      ),
    ],
  );

  testWidgets('shows exercises before the combined targeted-muscle map', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: WorkoutPlanDayScreen(day: workoutDay)),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppText && widget.key == const Key('workout-day-title'),
      ),
      findsOneWidget,
    );
    expect(find.text('Monday’s Workout'), findsOneWidget);
    expect(find.text('Upper body strength and core'), findsOneWidget);
    expect(
      find.text('Push-up with a deliberately long activity name'),
      findsOneWidget,
    );
    expect(find.text('3 sets · 12 reps · 45s rest'), findsOneWidget);
    expect(find.text('Targets: Chest, Triceps'), findsOneWidget);
    expect(find.text('Keep your core braced.'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
    expect(find.text('Targeted muscles'), findsOneWidget);

    final activitiesTop = tester
        .getTopLeft(
          find.byWidgetPredicate(
            (widget) =>
                widget is AppText &&
                widget.key == const Key('workout-day-activities'),
          ),
        )
        .dy;
    final mapTop = tester
        .getTopLeft(find.byKey(const Key('workout-day-muscle-map')))
        .dy;
    expect(activitiesTop, lessThan(mapTop));
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Triceps'), findsOneWidget);
    expect(find.text('Core'), findsOneWidget);
  });

  testWidgets('shows unavailable copy without inferring muscle targets', (
    tester,
  ) async {
    const day = WorkoutPlanDay(
      day: 'Tuesday',
      focus: 'Cardio',
      exercises: [WorkoutExercise(name: 'Mountain climber')],
    );

    await tester.pumpWidget(
      const MaterialApp(home: WorkoutPlanDayScreen(day: day)),
    );

    expect(find.text('Mountain climber'), findsOneWidget);
    expect(find.text('Muscle targets unavailable'), findsOneWidget);
    expect(find.byKey(const Key('workout-day-muscle-map')), findsNothing);
  });

  testWidgets('empty rest day has no muscle illustration', (tester) async {
    const day = WorkoutPlanDay(
      day: 'Sunday',
      focus: 'Recover and prepare for the week',
      isRestDay: true,
    );

    await tester.pumpWidget(
      const MaterialApp(home: WorkoutPlanDayScreen(day: day)),
    );

    expect(find.text('Rest and recovery'), findsOneWidget);
    expect(find.text('Recover and prepare for the week'), findsOneWidget);
    expect(find.text('Rest day'), findsOneWidget);
    expect(find.byKey(const Key('workout-day-muscle-map')), findsNothing);
    expect(find.text('Muscle targets unavailable'), findsNothing);
  });

  testWidgets('back button returns to the workout plan route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkoutPlanDayScreen(day: workoutDay),
                ),
              ),
              child: const Text('Open Monday'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Monday'));
    await tester.pumpAndSettle();
    expect(find.text('Workout activities'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open Monday'), findsOneWidget);
  });
}

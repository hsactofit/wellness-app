import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/workout_progress.dart';

void main() {
  final snapshot = [
    {'id': 'exercise-1', 'name': 'Goblet squat', 'sets': 3, 'reps': '12'},
    {'id': 'exercise-2', 'name': 'Seated row', 'sets': 3, 'reps': '10'},
    {'id': 'exercise-3', 'name': 'Plank'},
  ];

  test('gates the main checkbox until every prescribed set is done', () {
    final incomplete = gatedAssignedProgress(
      item: snapshot.first,
      completedSetIndexes: const [1, 2],
      exerciseCompleted: true,
    );
    final complete = gatedAssignedProgress(
      item: snapshot.first,
      completedSetIndexes: const [1, 2, 3],
      exerciseCompleted: true,
    );

    expect(incomplete.exerciseCompleted, isFalse);
    expect(complete.exerciseCompleted, isTrue);
  });

  test('auto-completes the exercise once every set is ticked in order', () {
    final skipped = gatedAssignedProgress(
      item: snapshot.first,
      completedSetIndexes: const [1, 3],
      exerciseCompleted: false,
    );
    final allDone = gatedAssignedProgress(
      item: snapshot.first,
      completedSetIndexes: const [1, 2, 3],
      exerciseCompleted: false,
    );

    expect(skipped.completedSetIndexes, [1]);
    expect(skipped.exerciseCompleted, isFalse);
    expect(allDone.completedSetIndexes, [1, 2, 3]);
    expect(allDone.exerciseCompleted, isTrue);
  });

  test('unlocks the next set only after the previous set is ticked', () {
    expect(isSequentialSetUnlocked(1, const []), isTrue);
    expect(isSequentialSetUnlocked(2, const []), isFalse);
    expect(isSequentialSetUnlocked(2, const [1]), isTrue);
    expect(isSequentialSetUnlocked(3, const [1]), isFalse);
    expect(isSequentialSetUnlocked(3, const [1, 2]), isTrue);
  });

  test('unchecking a set clears every later set', () {
    expect(
      toggleSequentialSet(
        completed: const [1, 2, 3],
        setIndex: 2,
        selected: false,
        maximum: 3,
      ),
      [1],
    );
    expect(
      toggleSequentialSet(
        completed: const [1],
        setIndex: 2,
        selected: true,
        maximum: 3,
      ),
      [1, 2],
    );
    expect(
      toggleSequentialSet(
        completed: const [1],
        setIndex: 3,
        selected: true,
        maximum: 3,
      ),
      [1],
    );
  });

  test('computes assigned set completion and ignores extra work', () {
    final progress = WorkoutProgress(
      assigned: {
        'exercise-1': const AssignedExerciseProgress(
          completedSetIndexes: [1, 2],
        ),
        'exercise-2': const AssignedExerciseProgress(
          completedSetIndexes: [1, 2, 3],
          exerciseCompleted: true,
        ),
      },
      extraSets: {
        'exercise-1': const ExtraSetsProgress(
          count: 2,
          completedIndexes: [1, 2],
        ),
      },
      extraExercises: const [
        ExtraExerciseProgress(
          id: 'extra-1',
          name: 'Face pulls',
          sets: 3,
          completedSetIndexes: [1, 2, 3],
          exerciseCompleted: true,
        ),
      ],
    );

    expect(
      assignedCompletionPct(planSnapshot: snapshot, progress: progress),
      closeTo(71.43, 0.01),
    );
  });

  test('restores legacy exercise ids as full set completion', () {
    final progress = WorkoutProgress.fromLegacyIds(
      planSnapshot: snapshot,
      completedItemIds: const ['exercise-1', 'exercise-3'],
    );

    expect(progress.forExercise('exercise-1').completedSetIndexes, [1, 2, 3]);
    expect(progress.forExercise('exercise-1').exerciseCompleted, isTrue);
    expect(progress.forExercise('exercise-3').exerciseCompleted, isTrue);
    expect(
      assignedCompletionPct(planSnapshot: snapshot, progress: progress),
      closeTo(57.14, 0.01),
    );
  });
}

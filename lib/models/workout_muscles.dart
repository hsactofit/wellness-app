const String fullBodyTargetMuscle = 'full_body';

const List<String> workoutTargetMuscleOrder = [
  'chest',
  'shoulders',
  'biceps',
  'triceps',
  'forearms',
  'core',
  'upper_back',
  'lats',
  'lower_back',
  'glutes',
  'quadriceps',
  'hamstrings',
  'inner_thighs',
  'calves',
  fullBodyTargetMuscle,
];

const Map<String, String> workoutTargetMuscleLabels = {
  'chest': 'Chest',
  'shoulders': 'Shoulders',
  'biceps': 'Biceps',
  'triceps': 'Triceps',
  'forearms': 'Forearms',
  'core': 'Core',
  'upper_back': 'Upper back',
  'lats': 'Lats',
  'lower_back': 'Lower back',
  'glutes': 'Glutes',
  'quadriceps': 'Quadriceps',
  'hamstrings': 'Hamstrings',
  'inner_thighs': 'Inner thighs',
  'calves': 'Calves',
  fullBodyTargetMuscle: 'Full body',
};

List<String> workoutTargetMusclesFromJson(Object? value) {
  if (value is! Iterable) return const [];
  return normalizeWorkoutTargetMuscles(value);
}

List<String> normalizeWorkoutTargetMuscles(Iterable<Object?> values) {
  final requested = <String>{};
  for (final value in values) {
    if (value is! String) continue;
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    if (workoutTargetMuscleLabels.containsKey(normalized)) {
      requested.add(normalized);
    }
  }
  if (requested.contains(fullBodyTargetMuscle)) {
    return const [fullBodyTargetMuscle];
  }
  return workoutTargetMuscleOrder
      .where(requested.contains)
      .toList(growable: false);
}

List<String> targetMusclesForWorkoutSnapshot(
  Iterable<Map<String, dynamic>> exercises,
) {
  final values = <Object?>[];
  for (final exercise in exercises) {
    final targetMuscles = exercise['target_muscles'];
    if (targetMuscles is Iterable) values.addAll(targetMuscles);
  }
  return normalizeWorkoutTargetMuscles(values);
}

String workoutTargetMuscleLabel(String value) =>
    workoutTargetMuscleLabels[value] ?? value;

String workoutTargetMuscleSummary(Iterable<String> values) =>
    values.map(workoutTargetMuscleLabel).join(', ');

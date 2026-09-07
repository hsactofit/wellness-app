/// Set-level workout checklist helpers shared by Gym Access and Workout Reports.
library;

int prescribedSetCount(Map<String, dynamic> item) {
  final raw = item['sets'];
  if (raw is num) return raw.toInt().clamp(0, 100);
  if (raw is String) return int.tryParse(raw.trim())?.clamp(0, 100) ?? 0;
  return 0;
}

String exerciseIdOf(Map<String, dynamic> item, {int fallbackIndex = 0}) {
  final id = item['id']?.toString().trim();
  if (id != null && id.isNotEmpty) return id;
  final name = item['name']?.toString().trim();
  if (name != null && name.isNotEmpty) return name;
  return 'exercise-${fallbackIndex + 1}';
}

List<int> uniqueSetIndexes(Iterable<dynamic>? values, int maximum) {
  if (values == null || maximum <= 0) return const [];
  final indexes = <int>{};
  for (final value in values) {
    final index = value is num ? value.toInt() : int.tryParse(value.toString());
    if (index != null && index >= 1 && index <= maximum) {
      indexes.add(index);
    }
  }
  final ordered = indexes.toList()..sort();
  return ordered;
}

/// Keep only a contiguous prefix: set 2 cannot count unless set 1 is done.
List<int> sequentialSetIndexes(Iterable<dynamic>? values, int maximum) {
  final unique = uniqueSetIndexes(values, maximum);
  if (unique.isEmpty) return const [];
  final sequential = <int>[];
  for (var index = 1; index <= maximum; index++) {
    if (!unique.contains(index)) break;
    sequential.add(index);
  }
  return sequential;
}

bool isSequentialSetUnlocked(int setIndex, List<int> completed) {
  if (setIndex <= 1) return true;
  final done = completed.toSet();
  for (var index = 1; index < setIndex; index++) {
    if (!done.contains(index)) return false;
  }
  return true;
}

List<int> toggleSequentialSet({
  required Iterable<int> completed,
  required int setIndex,
  required bool selected,
  required int maximum,
}) {
  final current = sequentialSetIndexes(completed, maximum);
  if (setIndex < 1 || setIndex > maximum) return current;
  if (selected) {
    if (!isSequentialSetUnlocked(setIndex, current)) return current;
    return sequentialSetIndexes([...current, setIndex], maximum);
  }
  return [
    for (final index in current)
      if (index < setIndex) index,
  ];
}

class AssignedExerciseProgress {
  const AssignedExerciseProgress({
    this.completedSetIndexes = const [],
    this.exerciseCompleted = false,
  });

  final List<int> completedSetIndexes;
  final bool exerciseCompleted;

  AssignedExerciseProgress copyWith({
    List<int>? completedSetIndexes,
    bool? exerciseCompleted,
  }) => AssignedExerciseProgress(
    completedSetIndexes: completedSetIndexes ?? this.completedSetIndexes,
    exerciseCompleted: exerciseCompleted ?? this.exerciseCompleted,
  );

  Map<String, dynamic> toJson() => {
    'completed_set_indexes': completedSetIndexes,
    'exercise_completed': exerciseCompleted,
  };

  factory AssignedExerciseProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AssignedExerciseProgress();
    return AssignedExerciseProgress(
      completedSetIndexes: sequentialSetIndexes(
        json['completed_set_indexes'] as Iterable?,
        100,
      ),
      exerciseCompleted: json['exercise_completed'] == true,
    );
  }
}

class ExtraSetsProgress {
  const ExtraSetsProgress({
    this.count = 0,
    this.completedIndexes = const [],
    this.reps,
  });

  final int count;
  final List<int> completedIndexes;
  final String? reps;

  ExtraSetsProgress copyWith({
    int? count,
    List<int>? completedIndexes,
    String? reps,
  }) => ExtraSetsProgress(
    count: count ?? this.count,
    completedIndexes: completedIndexes ?? this.completedIndexes,
    reps: reps ?? this.reps,
  );

  Map<String, dynamic> toJson() => {
    'count': count,
    'completed_indexes': completedIndexes,
    'reps': reps,
  };

  factory ExtraSetsProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExtraSetsProgress();
    final count = ((json['count'] as num?)?.toInt() ?? 0).clamp(0, 10);
    return ExtraSetsProgress(
      count: count,
      completedIndexes: sequentialSetIndexes(
        json['completed_indexes'] as Iterable?,
        count,
      ),
      reps: json['reps']?.toString(),
    );
  }
}

class ExtraExerciseProgress {
  const ExtraExerciseProgress({
    required this.id,
    required this.name,
    this.sets = 0,
    this.reps,
    this.source = 'custom',
    this.videoId,
    this.completedSetIndexes = const [],
    this.exerciseCompleted = false,
  });

  final String id;
  final String name;
  final int sets;
  final String? reps;
  final String source;
  final String? videoId;
  final List<int> completedSetIndexes;
  final bool exerciseCompleted;

  ExtraExerciseProgress copyWith({
    String? id,
    String? name,
    int? sets,
    String? reps,
    String? source,
    String? videoId,
    List<int>? completedSetIndexes,
    bool? exerciseCompleted,
  }) => ExtraExerciseProgress(
    id: id ?? this.id,
    name: name ?? this.name,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    source: source ?? this.source,
    videoId: videoId ?? this.videoId,
    completedSetIndexes: completedSetIndexes ?? this.completedSetIndexes,
    exerciseCompleted: exerciseCompleted ?? this.exerciseCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets,
    'reps': reps,
    'source': source,
    'video_id': videoId,
    'completed_set_indexes': completedSetIndexes,
    'exercise_completed': exerciseCompleted,
  };

  factory ExtraExerciseProgress.fromJson(Map json) => ExtraExerciseProgress(
    id: json['id']?.toString() ?? 'extra',
    name: json['name']?.toString() ?? 'Exercise',
    sets: (json['sets'] as num?)?.toInt() ?? 0,
    reps: json['reps']?.toString(),
    source: json['source']?.toString() ?? 'custom',
    videoId: json['video_id']?.toString(),
    completedSetIndexes: sequentialSetIndexes(
      json['completed_set_indexes'] as Iterable?,
      20,
    ),
    exerciseCompleted: json['exercise_completed'] == true,
  );
}

class WorkoutProgress {
  const WorkoutProgress({
    this.assigned = const {},
    this.extraSets = const {},
    this.extraExercises = const [],
  });

  final Map<String, AssignedExerciseProgress> assigned;
  final Map<String, ExtraSetsProgress> extraSets;
  final List<ExtraExerciseProgress> extraExercises;

  bool get isEmpty =>
      assigned.isEmpty && extraSets.isEmpty && extraExercises.isEmpty;

  AssignedExerciseProgress forExercise(String id) =>
      assigned[id] ?? const AssignedExerciseProgress();

  ExtraSetsProgress extraSetsFor(String id) =>
      extraSets[id] ?? const ExtraSetsProgress();

  WorkoutProgress copyWith({
    Map<String, AssignedExerciseProgress>? assigned,
    Map<String, ExtraSetsProgress>? extraSets,
    List<ExtraExerciseProgress>? extraExercises,
  }) => WorkoutProgress(
    assigned: assigned ?? this.assigned,
    extraSets: extraSets ?? this.extraSets,
    extraExercises: extraExercises ?? this.extraExercises,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'assigned': assigned.map((key, value) => MapEntry(key, value.toJson())),
    'extra_sets': extraSets.map((key, value) => MapEntry(key, value.toJson())),
    'extra_exercises': extraExercises.map((item) => item.toJson()).toList(),
  };

  factory WorkoutProgress.fromJson(Map? json) {
    if (json == null) return const WorkoutProgress();
    final assignedRaw = json['assigned'];
    final extraSetsRaw = json['extra_sets'];
    final extraExercisesRaw = json['extra_exercises'];
    return WorkoutProgress(
      assigned: assignedRaw is Map
          ? assignedRaw.map(
              (key, value) => MapEntry(
                key.toString(),
                AssignedExerciseProgress.fromJson(
                  value is Map ? Map<String, dynamic>.from(value) : null,
                ),
              ),
            )
          : const {},
      extraSets: extraSetsRaw is Map
          ? extraSetsRaw.map(
              (key, value) => MapEntry(
                key.toString(),
                ExtraSetsProgress.fromJson(
                  value is Map ? Map<String, dynamic>.from(value) : null,
                ),
              ),
            )
          : const {},
      extraExercises: extraExercisesRaw is List
          ? extraExercisesRaw
                .whereType<Map>()
                .map(ExtraExerciseProgress.fromJson)
                .toList()
          : const [],
    );
  }

  factory WorkoutProgress.fromLegacyIds({
    required List<Map<String, dynamic>> planSnapshot,
    required Iterable<String> completedItemIds,
  }) {
    final completed = completedItemIds.toSet();
    final assigned = <String, AssignedExerciseProgress>{};
    for (final (index, item) in planSnapshot.indexed) {
      final id = exerciseIdOf(item, fallbackIndex: index);
      final prescribed = prescribedSetCount(item);
      final checked = completed.contains(id);
      assigned[id] = AssignedExerciseProgress(
        completedSetIndexes: checked && prescribed > 0
            ? [for (var i = 1; i <= prescribed; i++) i]
            : const [],
        exerciseCompleted: checked,
      );
    }
    return WorkoutProgress(assigned: assigned);
  }

  static WorkoutProgress coerce({
    required List<Map<String, dynamic>> planSnapshot,
    required Iterable<String> completedItemIds,
    Map? stored,
  }) {
    if (stored is Map &&
        (stored['version'] == 1 ||
            (stored['assigned'] is Map &&
                (stored['assigned'] as Map).isNotEmpty))) {
      return WorkoutProgress.fromJson(stored);
    }
    return WorkoutProgress.fromLegacyIds(
      planSnapshot: planSnapshot,
      completedItemIds: completedItemIds,
    );
  }
}

bool allPrescribedSetsComplete(Map<String, dynamic> item, List<int> completed) {
  final prescribed = prescribedSetCount(item);
  if (prescribed <= 0) return true;
  return sequentialSetIndexes(completed, prescribed).length == prescribed;
}

AssignedExerciseProgress gatedAssignedProgress({
  required Map<String, dynamic> item,
  required List<int> completedSetIndexes,
  required bool exerciseCompleted,
}) {
  final prescribed = prescribedSetCount(item);
  final completed = sequentialSetIndexes(completedSetIndexes, prescribed);
  final setsDone = prescribed <= 0 || completed.length == prescribed;
  return AssignedExerciseProgress(
    completedSetIndexes: completed,
    exerciseCompleted: prescribed <= 0 ? exerciseCompleted : setsDone,
  );
}

ExtraSetsProgress gatedExtraSetsProgress(ExtraSetsProgress extra) =>
    extra.copyWith(
      completedIndexes: sequentialSetIndexes(
        extra.completedIndexes,
        extra.count,
      ),
    );

ExtraExerciseProgress gatedExtraExerciseProgress(
  ExtraExerciseProgress item, {
  List<int>? completedSetIndexes,
  bool? exerciseCompleted,
}) {
  final completed = sequentialSetIndexes(
    completedSetIndexes ?? item.completedSetIndexes,
    item.sets,
  );
  final setsDone = item.sets <= 0 || completed.length == item.sets;
  return item.copyWith(
    completedSetIndexes: completed,
    exerciseCompleted: item.sets <= 0
        ? (exerciseCompleted ?? item.exerciseCompleted)
        : setsDone,
  );
}

WorkoutProgress normalizeWorkoutProgress({
  required List<Map<String, dynamic>> planSnapshot,
  required WorkoutProgress progress,
}) {
  final assigned = <String, AssignedExerciseProgress>{};
  for (final (index, item) in planSnapshot.indexed) {
    final id = exerciseIdOf(item, fallbackIndex: index);
    final current = progress.forExercise(id);
    assigned[id] = gatedAssignedProgress(
      item: item,
      completedSetIndexes: current.completedSetIndexes,
      exerciseCompleted: current.exerciseCompleted,
    );
  }
  return progress.copyWith(
    assigned: assigned,
    extraSets: {
      for (final entry in progress.extraSets.entries)
        entry.key: gatedExtraSetsProgress(entry.value),
    },
    extraExercises: [
      for (final item in progress.extraExercises)
        gatedExtraExerciseProgress(item),
    ],
  );
}

({int completed, int prescribed}) assignedSetTotals({
  required List<Map<String, dynamic>> planSnapshot,
  required WorkoutProgress progress,
}) {
  var completed = 0;
  var prescribed = 0;
  for (final (index, item) in planSnapshot.indexed) {
    final id = exerciseIdOf(item, fallbackIndex: index);
    final units = prescribedSetCount(item);
    prescribed += units > 0 ? units : 1;
    final entry = progress.forExercise(id);
    if (units > 0) {
      completed += sequentialSetIndexes(
        entry.completedSetIndexes,
        units,
      ).length;
    } else if (entry.exerciseCompleted) {
      completed += 1;
    }
  }
  return (completed: completed, prescribed: prescribed);
}

double? assignedCompletionPct({
  required List<Map<String, dynamic>> planSnapshot,
  required WorkoutProgress progress,
}) {
  final totals = assignedSetTotals(
    planSnapshot: planSnapshot,
    progress: progress,
  );
  if (totals.prescribed == 0) return null;
  return totals.completed / totals.prescribed * 100;
}

import 'facility_booking_service.dart';
import 'workout_progress.dart';

/// Deterministic presentation facts from the frozen checkout data plus any
/// member correction. AI supplies only narrative/estimate fields.
class WorkoutReportPresentation {
  const WorkoutReportPresentation._();

  static WorkoutReportFacts factsFor(WorkoutReport report) {
    final progress = report.workoutProgress;
    final items = report.planSnapshot.indexed
        .where((entry) => entry.$2.isNotEmpty)
        .map((entry) {
          final item = entry.$2;
          final id = exerciseIdOf(item, fallbackIndex: entry.$1);
          final assigned = gatedAssignedProgress(
            item: item,
            completedSetIndexes: progress.forExercise(id).completedSetIndexes,
            exerciseCompleted: progress.forExercise(id).exerciseCompleted,
          );
          return WorkoutReportChecklistItem.fromSnapshot(
            item,
            fallbackIndex: entry.$1,
            assigned: assigned,
            extraSets: progress.extraSetsFor(id),
          );
        })
        .toList(growable: false);
    final totals = assignedSetTotals(
      planSnapshot: report.planSnapshot,
      progress: progress,
    );
    return WorkoutReportFacts(
      items: items,
      extraExercises: progress.extraExercises,
      completedSetCount: totals.completed,
      prescribedSetCount: totals.prescribed,
      memberEdited: report.memberEdited,
      aiStale: report.aiStale,
    );
  }

  static String statusLabel(WorkoutReport report) {
    if (report.aiStale) return 'Updating estimate';
    if (report.isComplete) return 'Ready';
    if (report.isPreparing) return 'Preparing';
    return report.hasRetryScheduled ? 'Retrying' : 'Temporarily unavailable';
  }

  static String statusDescription(WorkoutReport report) {
    if (report.aiStale) {
      return 'Your checklist is saved. Your estimated workout insights are being updated.';
    }
    if (report.isComplete) return 'Your workout report is ready to review.';
    if (report.isPreparing) {
      return 'Your estimated workout insights are being prepared. This page refreshes automatically.';
    }
    if (report.hasRetryScheduled) {
      return 'Your workout facts are safely saved. We will retry the AI estimate automatically.';
    }
    return 'Your workout facts are safely saved. The AI estimate is temporarily unavailable.';
  }

  static String checklistDetails(Map<String, dynamic> item) {
    final fields = <String>[];
    for (final key in const ['sets', 'reps', 'duration', 'rest']) {
      final value = item[key]?.toString().trim();
      if (value != null && value.isNotEmpty) fields.add('$key: $value');
    }
    final notes = item['notes']?.toString().trim();
    if (notes != null && notes.isNotEmpty) fields.add(notes);
    return fields.join(' - ');
  }
}

class WorkoutReportFacts {
  const WorkoutReportFacts({
    required this.items,
    this.extraExercises = const [],
    required this.completedSetCount,
    required this.prescribedSetCount,
    this.memberEdited = false,
    this.aiStale = false,
  });

  final List<WorkoutReportChecklistItem> items;
  final List<ExtraExerciseProgress> extraExercises;
  final int completedSetCount;
  final int prescribedSetCount;
  final bool memberEdited;
  final bool aiStale;

  bool get hasChecklist => items.isNotEmpty;
  int get completedCount => items.where((item) => item.completed).length;
  int get notCompletedCount => items.length - completedCount;
  int get extraSetCount =>
      items.fold<int>(0, (sum, item) => sum + item.extraSetCount);
  bool get hasExtraWork => extraExercises.isNotEmpty || extraSetCount > 0;
  double? get completionPct => prescribedSetCount > 0
      ? completedSetCount / prescribedSetCount * 100
      : null;
}

class WorkoutReportChecklistItem {
  const WorkoutReportChecklistItem({
    required this.id,
    required this.name,
    required this.details,
    required this.completed,
    required this.prescribedSets,
    required this.completedSetIndexes,
    required this.repsLabel,
    this.extraSetCount = 0,
    this.extraCompletedIndexes = const [],
  });

  final String id;
  final String name;
  final String details;
  final bool completed;
  final int prescribedSets;
  final List<int> completedSetIndexes;
  final String repsLabel;
  final int extraSetCount;
  final List<int> extraCompletedIndexes;

  String get setSummary {
    if (prescribedSets <= 0) {
      return completed ? 'Completed' : 'Not completed';
    }
    final extra = extraSetCount > 0
        ? ' · ${extraCompletedIndexes.length}/$extraSetCount extra'
        : '';
    return '${completedSetIndexes.length}/$prescribedSets sets$extra';
  }

  factory WorkoutReportChecklistItem.fromSnapshot(
    Map<String, dynamic> item, {
    required int fallbackIndex,
    required AssignedExerciseProgress assigned,
    ExtraSetsProgress extraSets = const ExtraSetsProgress(),
  }) {
    final id = exerciseIdOf(item, fallbackIndex: fallbackIndex);
    final reps = item['reps']?.toString().trim() ?? '';
    return WorkoutReportChecklistItem(
      id: id,
      name: item['name']?.toString().trim().isNotEmpty == true
          ? item['name'].toString().trim()
          : 'Exercise ${fallbackIndex + 1}',
      details: WorkoutReportPresentation.checklistDetails(item),
      completed: assigned.exerciseCompleted,
      prescribedSets: prescribedSetCount(item),
      completedSetIndexes: assigned.completedSetIndexes,
      repsLabel: reps,
      extraSetCount: extraSets.count,
      extraCompletedIndexes: extraSets.completedIndexes,
    );
  }
}

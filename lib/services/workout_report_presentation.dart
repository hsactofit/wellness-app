import 'facility_booking_service.dart';

/// Read-only, deterministic presentation facts from the frozen checkout data.
/// AI supplies only narrative/estimate fields; checklist progress always comes
/// from the plan snapshot and the member's saved checkbox selections.
class WorkoutReportPresentation {
  const WorkoutReportPresentation._();

  static WorkoutReportFacts factsFor(WorkoutReport report) {
    final completedIds = report.completedItemIds.toSet();
    final items = report.planSnapshot.indexed
        .where((entry) => entry.$2.isNotEmpty)
        .map(
          (entry) => WorkoutReportChecklistItem.fromSnapshot(
            entry.$2,
            fallbackIndex: entry.$1,
            completedIds: completedIds,
          ),
        )
        .toList(growable: false);
    return WorkoutReportFacts(items);
  }

  static String statusLabel(WorkoutReport report) {
    if (report.isComplete) return 'Ready';
    if (report.isPreparing) return 'Preparing';
    return report.hasRetryScheduled ? 'Retrying' : 'Temporarily unavailable';
  }

  static String statusDescription(WorkoutReport report) {
    if (report.isComplete) return 'Your workout report is ready to review.';
    if (report.isPreparing) {
      return 'Tarqa is preparing your estimated workout insights. This page refreshes automatically.';
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
  const WorkoutReportFacts(this.items);

  final List<WorkoutReportChecklistItem> items;

  bool get hasChecklist => items.isNotEmpty;
  int get completedCount => items.where((item) => item.completed).length;
  int get notCompletedCount => items.length - completedCount;
  double? get completionPct =>
      hasChecklist ? completedCount / items.length * 100 : null;
}

class WorkoutReportChecklistItem {
  const WorkoutReportChecklistItem({
    required this.id,
    required this.name,
    required this.details,
    required this.completed,
  });

  final String id;
  final String name;
  final String details;
  final bool completed;

  factory WorkoutReportChecklistItem.fromSnapshot(
    Map<String, dynamic> item, {
    required int fallbackIndex,
    required Set<String> completedIds,
  }) {
    final id = item['id']?.toString().trim();
    final stableId = id == null || id.isEmpty ? 'exercise-$fallbackIndex' : id;
    return WorkoutReportChecklistItem(
      id: stableId,
      name: item['name']?.toString().trim().isNotEmpty == true
          ? item['name'].toString().trim()
          : 'Exercise ${fallbackIndex + 1}',
      details: WorkoutReportPresentation.checklistDetails(item),
      completed: completedIds.contains(stableId),
    );
  }
}

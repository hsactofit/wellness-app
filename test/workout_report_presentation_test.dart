import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/facility_booking_service.dart';
import 'package:wellnessconnect/services/workout_report_pdf_service.dart';
import 'package:wellnessconnect/services/workout_report_presentation.dart';

void main() {
  final completeReport = WorkoutReport.fromJson({
    'id': 'report-1',
    'session_id': 'session-1',
    'facility_id': 'facility-1',
    'facility_name': 'Medifit Indiranagar',
    'check_in_at': '2026-09-04T09:00:00Z',
    'check_out_at': '2026-09-04T09:48:00Z',
    'duration_min': 48,
    'status': 'complete',
    'plan_snapshot': [
      {'id': 'exercise-1', 'name': 'Goblet squat', 'sets': 3, 'reps': 12},
      {'id': 'exercise-2', 'name': 'Seated row', 'sets': 3, 'reps': 10},
      {'id': 'exercise-3', 'name': 'Plank', 'duration': '30 sec'},
    ],
    'completed_item_ids': ['exercise-1', 'exercise-3'],
    'ai_estimated_calories': 340,
    'ai_intensity': 'Moderate',
    'completion_pct': 66.67,
    'summary': 'A steady strength session.',
    'recovery_note': 'Hydrate after training.',
    'generated_at': '2026-09-04T09:49:00Z',
  });

  test(
    'maps full report data and derives checklist progress from saved facts',
    () {
      final facts = WorkoutReportPresentation.factsFor(completeReport);

      expect(completeReport.facilityName, 'Medifit Indiranagar');
      expect(completeReport.checkOutAt, DateTime.utc(2026, 9, 4, 9, 48));
      expect(facts.completedCount, 2);
      expect(facts.notCompletedCount, 1);
      expect(facts.completionPct, closeTo(66.67, 0.01));
      expect(facts.items.map((item) => item.completed), [true, false, true]);
      expect(facts.items.first.details, 'sets: 3 - reps: 12');
    },
  );

  test(
    'distinguishes a missing checklist from a checklist with no selections',
    () {
      final noChecklist = WorkoutReport.fromJson({
        'id': 'report-2',
        'status': 'complete',
        'plan_snapshot': const [],
        'completed_item_ids': const [],
      });
      final incompleteChecklist = WorkoutReport.fromJson({
        'id': 'report-3',
        'status': 'complete',
        'plan_snapshot': [
          {'id': 'exercise-1', 'name': 'Goblet squat'},
        ],
        'completed_item_ids': const [],
      });

      expect(
        WorkoutReportPresentation.factsFor(noChecklist).completionPct,
        isNull,
      );
      expect(
        WorkoutReportPresentation.factsFor(incompleteChecklist).completionPct,
        0,
      );
    },
  );

  test('builds a visual workout report PDF', () async {
    final bytes = await WorkoutReportPdfService.buildReportPdf(completeReport);

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(1200));
  });
}

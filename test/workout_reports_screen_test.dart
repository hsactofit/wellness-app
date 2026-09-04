import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/workout_reports_screen.dart';
import 'package:wellnessconnect/services/facility_booking_service.dart';

void main() {
  WorkoutReport report({required String id, required String status}) =>
      WorkoutReport.fromJson({
        'id': id,
        'session_id': 'session-$id',
        'facility_id': 'facility-1',
        'facility_name': 'Medifit Indiranagar',
        'check_in_at': '2026-09-04T09:00:00Z',
        'check_out_at': '2026-09-04T09:48:00Z',
        'duration_min': 48,
        'status': status,
        'plan_snapshot': [
          {'id': 'exercise-1', 'name': 'Goblet squat'},
        ],
        'completed_item_ids': ['exercise-1'],
        if (status == 'complete') ...{
          'ai_estimated_calories': 340,
          'ai_intensity': 'Moderate',
          'summary': 'A steady strength session.',
          'recovery_note': 'Hydrate after training.',
        },
      });

  testWidgets('opens a completed workout report preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutReportsScreen(
          loadReports: () async => [report(id: 'complete', status: 'complete')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final completedSummary = find.textContaining(
      '100% complete - 340 kcal estimated',
    );
    expect(completedSummary, findsOneWidget);

    await tester.tap(completedSummary);
    await tester.pumpAndSettle();

    expect(find.text('Workout Report'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('labels a newly completed report as preparing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutReportsScreen(
          loadReports: () async => [report(id: 'preparing', status: 'pending')],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preparing'), findsOneWidget);
    expect(
      find.textContaining(
        'Tarqa is preparing your estimated workout insights. This page refreshes automatically.',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });
}

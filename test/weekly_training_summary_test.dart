import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/weekly_training.dart';
import 'package:wellnessconnect/widgets/weekly_training_summary.dart';

void main() {
  test('weekly summary parser tolerates an older unavailable response', () {
    expect(WeeklyTrainingSummary.tryParse(null), isNull);
    expect(WeeklyTrainingSummary.tryParse(<String, dynamic>{}), isNull);
  });

  testWidgets('unavailable weekly summary has a retry state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeeklyTrainingSummarySection(
            summary: null,
            loading: false,
            onRefresh: () async {},
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Weekly training is unavailable. Your existing health data is still safe.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('consistency uses plain-language progress and a compact editor', (
    tester,
  ) async {
    final summary = WeeklyTrainingSummary(
      weekStart: DateTime(2026, 9, 1),
      weekEnd: DateTime(2026, 9, 7),
      asOf: DateTime(2026, 9, 5),
      planAvailable: true,
      planMessage: null,
      completedPlannedDays: 0,
      plannedDaysDue: 2,
      totalPlannedDays: 3,
      futurePlannedDays: 1,
      actualTrainingDays: 0,
      days: List.generate(
        7,
        (index) => WeeklyTrainingDay(
          date: DateTime(2026, 9, index + 1),
          weekday: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
          state: index < 4
              ? 'rest'
              : index < 6
              ? 'missed'
              : 'future',
          planned: index >= 4,
          due: index < 6,
          completed: false,
          extraWorkout: false,
          memberEntered: false,
        ),
      ),
      totalIncludedSessions: 0,
      trainingTypes: const [],
      includedSessions: const [],
      weight: _metric('weight', 'kg'),
      restingHeartRate: _metric('resting_heart_rate', 'bpm'),
      sleep: _metric('sleep', 'hours'),
      activeCorrectionIds: const {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeeklyTrainingSummarySection(
              summary: summary,
              loading: false,
              onRefresh: () async {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('2 planned days due · no workouts completed'),
      findsOneWidget,
    );
    expect(find.text('0/2'), findsNothing);
    expect(
      find.text('Completed · Missed · Future · Rest · Extra workout'),
      findsNothing,
    );

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();

    expect(find.text('View correction history'), findsNothing);
    expect(find.text('Completed sessions'), findsNothing);
  });
}

WeeklyMetric _metric(String metric, String unit) => WeeklyMetric(
  metric: metric,
  value: null,
  unit: unit,
  delta: null,
  sampleCount: 0,
  comparisonSampleCount: 0,
  displayBasis: 'No synced data',
  sparkline: const [],
  activeCorrectionId: null,
);

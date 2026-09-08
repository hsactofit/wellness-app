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

  testWidgets(
    'consistency shows only completed-workout ticks and a compact editor',
    (tester) async {
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
                : index == 4
                ? 'extra'
                : index < 6
                ? 'missed'
                : 'future',
            planned: index >= 4,
            due: index < 6,
            completed: false,
            extraWorkout: index == 4,
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

      expect(find.text('Workout days this week'), findsOneWidget);
      expect(find.text('0/2'), findsNothing);
      expect(
        find.text('2 planned days due · no workouts completed'),
        findsNothing,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
      expect(find.byIcon(Icons.bedtime_outlined), findsNothing);
      expect(
        find.text('Completed · Missed · Future · Rest · Extra workout'),
        findsNothing,
      );

      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      expect(find.text('View correction history'), findsNothing);
      expect(find.text('Completed sessions'), findsNothing);
    },
  );

  testWidgets('workout breakdown explains its total and unspecified type', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final summary = _summary(
      totalIncludedSessions: 1,
      trainingTypes: const [TrainingTypeCount(type: 'other', count: 1)],
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

    expect(find.text('Completed workouts'), findsOneWidget);
    expect(find.text('This week, grouped by workout type'), findsOneWidget);
    expect(find.text('1 workout completed this week'), findsOneWidget);
    expect(find.text('Not specified'), findsOneWidget);
    expect(
      find.text(
        'Not specified means the workout was recorded without a workout type.',
      ),
      findsOneWidget,
    );
    expect(find.text('How you trained'), findsNothing);
    expect(find.text('Other'), findsNothing);
  });
}

WeeklyTrainingSummary _summary({
  required int totalIncludedSessions,
  required List<TrainingTypeCount> trainingTypes,
}) => WeeklyTrainingSummary(
  weekStart: DateTime(2026, 9, 7),
  weekEnd: DateTime(2026, 9, 13),
  asOf: DateTime(2026, 9, 8),
  planAvailable: true,
  planMessage: null,
  completedPlannedDays: 1,
  plannedDaysDue: 1,
  totalPlannedDays: 1,
  futurePlannedDays: 0,
  actualTrainingDays: totalIncludedSessions == 0 ? 0 : 1,
  days: List.generate(
    7,
    (index) => WeeklyTrainingDay(
      date: DateTime(2026, 9, 7 + index),
      weekday: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
      state: index == 0 ? 'completed' : 'rest',
      planned: index == 0,
      due: index == 0,
      completed: index == 0,
      extraWorkout: false,
      memberEntered: false,
    ),
  ),
  totalIncludedSessions: totalIncludedSessions,
  trainingTypes: trainingTypes,
  includedSessions: const [],
  weight: _metric('weight', 'kg'),
  restingHeartRate: _metric('resting_heart_rate', 'bpm'),
  sleep: _metric('sleep', 'hours'),
  activeCorrectionIds: const {},
);

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

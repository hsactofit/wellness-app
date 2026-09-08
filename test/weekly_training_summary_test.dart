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
            onViewWorkoutReports: () {},
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
                onViewWorkoutReports: () {},
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

  testWidgets('latest workout shows the newest completed session', (
    tester,
  ) async {
    var openedReports = false;
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final summary = _summary(
      includedSessions: [
        IncludedTrainingSession(
          id: 'older-session',
          date: DateTime(2026, 9, 7),
          type: 'cardio',
          durationMinutes: 30,
          memberEntered: false,
          correctionId: null,
        ),
        IncludedTrainingSession(
          id: 'latest-session',
          date: DateTime(2026, 9, 8),
          type: 'strength',
          durationMinutes: 42,
          memberEntered: false,
          correctionId: null,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeeklyTrainingSummarySection(
              summary: summary,
              loading: false,
              onRefresh: () async {},
              onViewWorkoutReports: () => openedReports = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Latest workout'), findsOneWidget);
    expect(
      find.text('Most recent completed session this week'),
      findsOneWidget,
    );
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Tuesday · 42 min'), findsOneWidget);
    expect(find.text('View workout reports'), findsOneWidget);
    expect(find.text('Cardio'), findsNothing);
    expect(find.text('Completed workouts'), findsNothing);

    await tester.tap(find.text('View workout reports'));
    expect(openedReports, isTrue);
  });

  testWidgets('latest workout stays hidden without a completed session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeeklyTrainingSummarySection(
              summary: _summary(includedSessions: const []),
              loading: false,
              onRefresh: () async {},
              onViewWorkoutReports: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Latest workout'), findsNothing);
    expect(find.text('Completed workouts'), findsNothing);
    expect(find.text('Body & recovery'), findsOneWidget);
  });

  testWidgets('latest workout uses a clear label for a generic session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeeklyTrainingSummarySection(
              summary: _summary(
                includedSessions: [
                  IncludedTrainingSession(
                    id: 'generic-session',
                    date: DateTime(2026, 9, 8),
                    type: 'other',
                    durationMinutes: 1,
                    memberEntered: false,
                    correctionId: null,
                  ),
                ],
              ),
              loading: false,
              onRefresh: () async {},
              onViewWorkoutReports: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Not specified'), findsNothing);
    expect(find.text('Tuesday · 1 min'), findsOneWidget);
  });
}

WeeklyTrainingSummary _summary({
  required List<IncludedTrainingSession> includedSessions,
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
  actualTrainingDays: includedSessions.isEmpty ? 0 : 1,
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
  totalIncludedSessions: includedSessions.length,
  trainingTypes: const [],
  includedSessions: includedSessions,
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

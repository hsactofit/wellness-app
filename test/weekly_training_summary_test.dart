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
            recentActivity: null,
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
                recentActivity: null,
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

  testWidgets(
    'weekly summary omits latest workout even with completed sessions',
    (tester) async {
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
                recentActivity: RecentActivity(
                  sessionId: 'recent-session',
                  activityCode: 'yoga',
                  activityName: 'Yoga',
                  facilityName: 'Medifit Indiranagar',
                  completedAt: DateTime(2026, 9, 8, 10),
                  localDate: DateTime(2026, 9, 8),
                  durationMinutes: 45,
                ),
                loading: false,
                onRefresh: () async {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Latest workout'), findsNothing);
      expect(
        find.text('Most recent completed session this week'),
        findsNothing,
      );
      expect(find.text('View workout reports'), findsNothing);
      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Yoga'), findsOneWidget);
      expect(find.text('Medifit Indiranagar'), findsOneWidget);
      expect(find.text('8 Sep 2026 · 45 min'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Consistency')).dy,
        lessThan(tester.getTopLeft(find.text('Recent activity')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Recent activity')).dy,
        lessThan(tester.getTopLeft(find.text('Body & recovery')).dy),
      );
      expect(find.text('Consistency'), findsOneWidget);
      expect(find.text('Body & recovery'), findsOneWidget);
      expect(find.text('Edit'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('latest workout stays hidden without a completed session', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WeeklyTrainingSummarySection(
              summary: _summary(includedSessions: const []),
              recentActivity: null,
              loading: false,
              onRefresh: () async {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Latest workout'), findsNothing);
    expect(find.text('Completed workouts'), findsNothing);
    expect(find.text('Body & recovery'), findsOneWidget);
  });

  test('recent activity parser is additive and tolerates older responses', () {
    expect(RecentActivity.tryParse(null), isNull);
    expect(RecentActivity.tryParse(<String, dynamic>{}), isNull);
    final activity = RecentActivity.tryParse(<String, dynamic>{
      'session_id': 'session-1',
      'activity_code': 'zumba',
      'activity_name': 'Zumba',
      'facility_name': 'Medifit Indiranagar',
      'completed_at': '2026-09-08T11:00:00+05:30',
      'local_date': '2026-09-08',
      'duration_minutes': 50,
    });
    expect(activity?.activityName, 'Zumba');
    expect(activity?.durationMinutes, 50);
  });

  testWidgets(
    'recent activity handles every activity icon and missing duration',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const activities = <String, IconData>{
        'gym': Icons.fitness_center_rounded,
        'yoga': Icons.self_improvement_rounded,
        'zumba': Icons.music_note_rounded,
        'meditation': Icons.spa_rounded,
        'pilates': Icons.accessibility_new_rounded,
        'aerobics': Icons.directions_run_rounded,
      };
      for (final entry in activities.entries) {
        await tester.pumpWidget(
          MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark(),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: WeeklyTrainingSummarySection(
                    summary: _summary(includedSessions: const []),
                    recentActivity: RecentActivity(
                      sessionId: 'session-${entry.key}',
                      activityCode: entry.key,
                      activityName: entry.key,
                      facilityName:
                          'A very long corporate facility name that needs two lines',
                      completedAt: DateTime(2026, 9, 8, 12),
                      localDate: DateTime(2026, 9, 8),
                      durationMinutes: null,
                    ),
                    loading: false,
                    onRefresh: () async {},
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.byIcon(entry.value), findsOneWidget);
        expect(find.text('8 Sep 2026 · Duration not recorded'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
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

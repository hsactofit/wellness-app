import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/care_program.dart';
import 'package:wellnessconnect/theme/app_theme.dart';
import 'package:wellnessconnect/widgets/weekly_care_progress.dart';

void main() {
  testWidgets('shows real weekly completion and the next active action', (
    tester,
  ) async {
    final summary = CareProgramSummary.fromJson({
      'review_requested': false,
      'current': {
        'id': 'program-1',
        'title': 'Cardiometabolic Foundation',
        'status': 'active',
        'revision': 1,
        'member_summary': 'A steady foundation.',
        'objectives': ['Build consistency'],
        'actions': <Object>[],
        'guidance': <Object>[],
        'review_due': false,
        'starts_on': '2026-09-07',
        'ends_on': '2026-11-02',
      },
      'history': <Object>[],
      'progress': {
        'expected_actions': 4,
        'completed_actions': 3,
        'weekly_expected_actions': 9,
        'weekly_completed_actions': 4,
        'next_action': {
          'key': 'water',
          'title': 'Log hydration',
          'occurrence_date': '2026-09-12',
        },
      },
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: WeeklyCareProgressSection(
            summary: summary,
            loading: false,
            loadFailed: false,
            onOpenProgram: () {},
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.text('Weekly Care Progress'), findsOneWidget);
    expect(find.text('4 of 9'), findsOneWidget);
    expect(find.textContaining('Next: Log hydration'), findsOneWidget);
    expect(find.text('View my program'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the review-requested care state', (tester) async {
    final summary = CareProgramSummary.fromJson({
      'review_requested': true,
      'current': null,
      'offer': null,
      'history': <Object>[],
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: WeeklyCareProgressSection(
            summary: summary,
            loading: false,
            loadFailed: false,
            onOpenProgram: () {},
            onRefresh: () {},
          ),
        ),
      ),
    );

    expect(find.text('Review in progress'), findsOneWidget);
    expect(find.text('View status'), findsOneWidget);
    expect(find.textContaining('Weekly training'), findsNothing);
  });
}

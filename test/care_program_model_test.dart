import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/care_program.dart';

void main() {
  test('parses an offered care program and its daily action', () {
    final summary = CareProgramSummary.fromJson({
      'review_requested': false,
      'current': {
        'id': 'program-1',
        'title': 'Cardiometabolic Foundation',
        'status': 'offered',
        'revision': 2,
        'member_summary': 'A steady eight-week foundation.',
        'objectives': ['Build a sustainable daily routine'],
        'actions': [
          {
            'key': 'water',
            'title': 'Record hydration',
            'type': 'hydration',
            'recurrence': 'daily',
            'weekdays': <int>[],
          },
        ],
        'guidance': <Object>[],
        'review_due': false,
      },
      'progress': {
        'weekly_expected_actions': 7,
        'weekly_completed_actions': 3,
        'next_action': {
          'key': 'water',
          'title': 'Record hydration',
          'occurrence_date': '2026-09-12',
        },
      },
      'history': <Object>[],
    });

    expect(summary.current?.status, 'offered');
    expect(summary.current?.actions.single.type, 'hydration');
    expect(
      summary.current?.objectives.single,
      'Build a sustainable daily routine',
    );
    expect(summary.weeklyExpectedActions, 7);
    expect(summary.weeklyCompletedActions, 3);
    expect(summary.nextAction?.title, 'Record hydration');
  });

  test('keeps no-program review state separate from history', () {
    final summary = CareProgramSummary.fromJson({
      'review_requested': true,
      'current': null,
      'history': <Object>[],
    });

    expect(summary.current, isNull);
    expect(summary.reviewRequested, isTrue);
    expect(summary.history, isEmpty);
  });
}

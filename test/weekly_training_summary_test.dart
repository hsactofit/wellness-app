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

    expect(find.text('Weekly training is unavailable. Your existing health data is still safe.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}

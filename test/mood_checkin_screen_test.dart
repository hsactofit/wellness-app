import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/mood_checkin.dart';
import 'package:wellnessconnect/screens/mood_checkin_screen.dart';
import 'package:wellnessconnect/theme/app_theme.dart';

void main() {
  testWidgets('shows past mood logs and prepends a new submission', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previous = MoodCheckin(
      id: 'previous',
      moodScore: 8,
      stressScore: 2,
      anonymous: true,
      checkedAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
    );
    int? submittedMood;
    int? submittedStress;
    bool? submittedAnonymously;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MoodCheckinScreen(
          loadCheckins: () async => [previous],
          submitCheckin:
              ({
                required moodScore,
                required stressScore,
                required anonymous,
              }) async {
                submittedMood = moodScore;
                submittedStress = stressScore;
                submittedAnonymously = anonymous;
                return MoodCheckin(
                  id: 'new',
                  moodScore: moodScore,
                  stressScore: stressScore,
                  anonymous: anonymous,
                  checkedAt: DateTime.now().toUtc(),
                );
              },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent check-ins'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Mood 8/10'), 240);
    expect(find.textContaining('Mood 8/10'), findsOneWidget);
    expect(find.textContaining('Stress 2/10'), findsOneWidget);
    expect(find.text('Submitted anonymously'), findsOneWidget);

    await tester.ensureVisible(find.text('Submit Check-in'));
    await tester.tap(find.text('Submit Check-in'));
    await tester.pumpAndSettle();

    expect(submittedMood, 6);
    expect(submittedStress, 4);
    expect(submittedAnonymously, isFalse);
    expect(find.text('Check-in logged'), findsOneWidget);
    await tester.scrollUntilVisible(find.textContaining('Mood 6/10'), 240);
    expect(find.textContaining('Mood 6/10'), findsOneWidget);
    expect(find.textContaining('Mood 8/10'), findsOneWidget);
    expect(find.text('Shared with the wellness team'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

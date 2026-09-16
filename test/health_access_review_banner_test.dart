import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/health_access_review_banner.dart';

void main() {
  test('review banner only follows a completed iOS health request', () {
    expect(
      HealthAccessReviewBanner.shouldShow(
        isIos: true,
        accessRequested: true,
        syncEnabled: true,
      ),
      isTrue,
    );
    expect(
      HealthAccessReviewBanner.shouldShow(
        isIos: true,
        accessRequested: false,
        syncEnabled: true,
      ),
      isFalse,
    );
    expect(
      HealthAccessReviewBanner.shouldShow(
        isIos: false,
        accessRequested: true,
        syncEnabled: true,
      ),
      isFalse,
    );
  });

  testWidgets('shows a persistent review action without claiming connection', (
    tester,
  ) async {
    var reviewed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthAccessReviewBanner(onReviewAccess: () => reviewed = true),
        ),
      ),
    );

    expect(find.text('Apple Health access requested'), findsOneWidget);
    expect(find.textContaining('connected'), findsNothing);
    await tester.tap(find.byKey(const Key('reviewAppleHealthAccessButton')));
    expect(reviewed, isTrue);
  });
}

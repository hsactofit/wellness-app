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

  testWidgets('shows a one-tap retry action without claiming connection', (
    tester,
  ) async {
    var requestedAgain = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthAccessReviewBanner(
            onRequestAgain: () => requestedAgain = true,
          ),
        ),
      ),
    );

    expect(find.text('Apple Health permissions'), findsOneWidget);
    expect(find.textContaining('connected'), findsNothing);
    await tester.tap(
      find.byKey(const Key('requestAppleHealthAccessAgainButton')),
    );
    expect(requestedAgain, isTrue);
  });
}

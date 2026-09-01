import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/plan_screen.dart';

void main() {
  testWidgets('workout consent begins unchecked and the member can select it', (
    tester,
  ) async {
    var consent = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => PlanConsentCheckbox(
              planLabel: 'workout',
              value: consent,
              accent: Colors.blue,
              textColor: Colors.black,
              onChanged: (value) => setState(() => consent = value ?? false),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('I consent to AI processing for my workout plan'),
      findsOneWidget,
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  test('workout generation warning names the missing consent', () {
    expect(
      reviewedPlanConsentWarning('workout'),
      'Please confirm AI processing consent before requesting your workout plan.',
    );
  });
}

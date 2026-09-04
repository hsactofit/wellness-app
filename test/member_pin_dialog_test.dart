import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/gym_checkin_screen.dart';

void main() {
  testWidgets(
    'member code dialog closes as soon as four valid digits are entered',
    (tester) async {
      String? submittedPin;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  submittedPin = await showDialog<String>(
                    context: context,
                    builder: (_) => const MemberPinDialog(
                      facilityName: 'Medifit Indiranagar',
                    ),
                  );
                },
                child: const Text('Open member code'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open member code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();

      expect(submittedPin, '1234');
      expect(find.text('Enter member code'), findsNothing);
    },
  );
}

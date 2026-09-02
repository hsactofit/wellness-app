import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/onboarding/consent_step.dart';

void main() {
  Map<String, bool> requiredGrants({bool medicalShare = false}) => {
    'terms': true,
    'healthData': true,
    'medicalShare': medicalShare,
    'employerAggregate': true,
  };

  Widget buildStep({
    required TextEditingController signatureController,
    required Map<String, bool> grants,
    required bool medicalShareRequired,
    required VoidCallback onNext,
  }) {
    return MaterialApp(
      home: ConsentStep(
        grants: grants,
        medicalShareRequired: medicalShareRequired,
        onToggleGrant: (key) => grants[key] = !(grants[key] ?? false),
        signatureController: signatureController,
        onBack: () {},
        onNext: onNext,
      ),
    );
  }

  testWidgets(
    'allows optional medical sharing when no condition needs clearance',
    (tester) async {
      final signatureController = TextEditingController(text: 'Ishaan Verma');
      var submissions = 0;

      await tester.pumpWidget(
        buildStep(
          signatureController: signatureController,
          grants: requiredGrants(),
          medicalShareRequired: false,
          onNext: () => submissions++,
        ),
      );

      expect(find.text('Optional'), findsOneWidget);
      expect(
        find.textContaining('Three consents below are required'),
        findsOneWidget,
      );

      await tester.tap(find.text('AGREE & ACTIVATE'));
      await tester.pump();

      expect(submissions, 1);
      signatureController.dispose();
    },
  );

  testWidgets(
    'requires medical sharing when a condition needs doctor clearance',
    (tester) async {
      final signatureController = TextEditingController(text: 'Ishaan Verma');
      var submissions = 0;

      await tester.pumpWidget(
        buildStep(
          signatureController: signatureController,
          grants: requiredGrants(),
          medicalShareRequired: true,
          onNext: () => submissions++,
        ),
      );

      expect(find.text('Required for doctor clearance'), findsOneWidget);
      expect(
        find.textContaining('All four consents below are required'),
        findsOneWidget,
      );

      await tester.tap(find.text('AGREE & ACTIVATE'));
      await tester.pump();

      expect(submissions, 0);
      expect(
        find.text('Please agree to the required consents and sign your name'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        buildStep(
          signatureController: signatureController,
          grants: requiredGrants(medicalShare: true),
          medicalShareRequired: true,
          onNext: () => submissions++,
        ),
      );
      await tester.tap(find.text('AGREE & ACTIVATE'));
      await tester.pump();

      expect(submissions, 1);
      signatureController.dispose();
    },
  );
}

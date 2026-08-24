import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/onboarding/profile_step.dart';

void main() {
  testWidgets('profile number fields provide keyboard-safe actions', (
    WidgetTester tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    addTearDown(() {
      nameController.dispose();
      dobController.dispose();
      heightController.dispose();
      weightController.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileStep(
            formKey: formKey,
            fullNameController: nameController,
            dobController: dobController,
            heightController: heightController,
            weightController: weightController,
            gender: 'Female',
            onGenderChanged: (_) {},
            heightUnit: 'cm',
            onHeightUnitChanged: (_) {},
            weightUnit: 'kg',
            onWeightUnitChanged: (_) {},
            onNext: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    final heightField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller == heightController,
      ),
    );
    final weightField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.controller == weightController,
      ),
    );
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );

    expect(heightField.textInputAction, TextInputAction.next);
    expect(weightField.textInputAction, TextInputAction.done);
    expect(heightField.onTapOutside, isNotNull);
    expect(weightField.onTapOutside, isNotNull);
    expect(
      scrollView.keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
  });

  testWidgets('profile step offers a back-to-sign-in action', (
    WidgetTester tester,
  ) async {
    var wentBack = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileStep(
            formKey: GlobalKey<FormState>(),
            fullNameController: TextEditingController(),
            dobController: TextEditingController(),
            heightController: TextEditingController(),
            weightController: TextEditingController(),
            gender: 'Female',
            onGenderChanged: (_) {},
            heightUnit: 'cm',
            onHeightUnitChanged: (_) {},
            weightUnit: 'kg',
            onWeightUnitChanged: (_) {},
            onNext: () {},
            onBack: () => wentBack = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    final backButton = find.text('Back to sign in');
    await tester.ensureVisible(backButton);
    await tester.tap(backButton);
    expect(wentBack, isTrue);
  });
}

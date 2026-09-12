import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/onboarding/signup_step.dart';

void main() {
  testWidgets('signup footer fits a narrow phone without overflowing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    addTearDown(name.dispose);
    addTearDown(email.dispose);
    addTearDown(password.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SignupStep(
            formKey: GlobalKey<FormState>(),
            nameController: name,
            emailController: email,
            passwordController: password,
            onSocialAuth: (_, _) {},
            onEmailSubmit: (_) {},
            onSsoPressed: (_) {},
            onLoginWithCode: (_, _) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Secure HIPAA compliant registration'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

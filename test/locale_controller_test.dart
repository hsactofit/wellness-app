import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellnessconnect/app_brand.dart';
import 'package:wellnessconnect/l10n/app_localizations.dart';
import 'package:wellnessconnect/l10n/app_text.dart';
import 'package:wellnessconnect/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('new installs and unsupported saved values use English', () async {
    await LocaleController.instance.load();
    expect(LocaleController.instance.value, const Locale('en'));

    SharedPreferences.setMockInitialValues({
      LocaleController.preferenceKey: 'unsupported',
    });
    await LocaleController.instance.load();
    expect(LocaleController.instance.value, const Locale('en'));
  });

  test('supported selection persists for the product installation', () async {
    if (!AppBrand.isMednovations) return;
    await LocaleController.instance.select('hi');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(LocaleController.preferenceKey), 'hi');

    await LocaleController.instance.load();
    expect(LocaleController.instance.value, const Locale('hi'));
  });

  testWidgets('Mednovations text changes in place for Hindi and Kannada', (
    tester,
  ) async {
    if (!AppBrand.isMednovations) return;

    Future<void> pump(Locale locale) => tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('hi'), Locale('kn')],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: AppText('Language')),
      ),
    );

    await pump(const Locale('hi'));
    expect(find.text('भाषा'), findsOneWidget);
    await pump(const Locale('kn'));
    expect(find.text('ಭಾಷೆ'), findsOneWidget);
  });

  testWidgets('Medifit text remains English', (tester) async {
    if (AppBrand.isMednovations) return;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppText('Language'))),
    );
    expect(find.text('Language'), findsOneWidget);
  });
}

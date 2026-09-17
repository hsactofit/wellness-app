import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/app_brand.dart';
import 'package:wellnessconnect/l10n/app_string_catalog.dart';

void main() {
  test('uses brand-safe English clinic terminology', () {
    final translated = AppStringCatalog.translate(
      'ORGANIZATION facilities and Facility managers',
      'en',
    );

    expect(
      translated,
      AppBrand.isMednovations
          ? 'CLINIC clinics and Clinic managers'
          : 'ORGANIZATION facilities and Facility managers',
    );
  });

  test('normalizes localized organization and facility wording', () {
    final hindi = AppStringCatalog.translate('ORGANIZATION', 'hi');
    final kannada = AppStringCatalog.translate('ORGANIZATION', 'kn');

    if (AppBrand.isMednovations) {
      expect(hindi, contains('क्लिनिक'));
      expect(kannada, contains('ಕ್ಲಿನಿಕ್'));
      expect(hindi, isNot(contains('संगठन')));
      expect(kannada, isNot(contains('ಸಂಘಟನೆ')));
    } else {
      expect(hindi, 'ORGANIZATION');
      expect(kannada, 'ORGANIZATION');
    }
  });
}

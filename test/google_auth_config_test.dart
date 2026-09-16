import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/app_brand.dart';
import 'package:wellnessconnect/config/google_auth_config.dart';

void main() {
  test('Google server audience stays within the selected product project', () {
    if (AppBrand.isMednovations) {
      expect(GoogleAuthConfig.serverClientId, isNull);
    } else {
      expect(
        GoogleAuthConfig.serverClientId,
        GoogleAuthConfig.medifitWebClientId,
      );
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/config/face_scan_web_config.dart';

void main() {
  test('scanner navigation permits only the configured HTTPS integration', () {
    final origin = FaceScanWebConfig.origin;
    expect(FaceScanWebConfig.allows(Uri.parse('$origin/integrations/mednovations#code=opaque')), isTrue);
    for (final url in [
      'http://vital.actofit.com/integrations/mednovations',
      'https://vital.actofit.com.evil.test/integrations/mednovations',
      'https://evil.test/integrations/mednovations',
      '$origin/login',
      '$origin/profile',
      '$origin/integrations/mednovations-other',
      '$origin/integrations/mednovations/../../login',
    ]) {
      expect(FaceScanWebConfig.allows(Uri.parse(url)), isFalse, reason: url);
    }
  });
}

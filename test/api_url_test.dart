import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/auth_service.dart';

void main() {
  test('legacy API paths use the namespace selected for this build', () {
    final base = AuthService.apiBaseUrl.endsWith('/')
        ? AuthService.apiBaseUrl.substring(0, AuthService.apiBaseUrl.length - 1)
        : AuthService.apiBaseUrl;
    final prefix = AuthService.apiPathPrefix.startsWith('/')
        ? AuthService.apiPathPrefix
        : '/${AuthService.apiPathPrefix}';

    expect(AuthService.apiUrl('/api/auth/login'), '$base$prefix/auth/login');
  });

  test('non-API paths remain rooted at the configured host', () {
    final base = AuthService.apiBaseUrl.endsWith('/')
        ? AuthService.apiBaseUrl.substring(0, AuthService.apiBaseUrl.length - 1)
        : AuthService.apiBaseUrl;
    expect(AuthService.apiUrl('/health'), '$base/health');
  });
}

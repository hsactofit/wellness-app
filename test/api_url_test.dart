import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/auth_service.dart';

void main() {
  test('legacy API paths use the namespace selected for this build', () {
    final prefixedPath = AuthService.apiPathPrefix.startsWith('/')
        ? AuthService.apiPathPrefix
        : '/${AuthService.apiPathPrefix}';
    final prefix = prefixedPath.endsWith('/') && prefixedPath.length > 1
        ? prefixedPath.substring(0, prefixedPath.length - 1)
        : prefixedPath;

    expect(AuthService.apiUrl('/api/auth/login').path, '$prefix/auth/login');
  });

  test('non-API paths remain rooted at the configured host', () {
    expect(AuthService.apiUrl('/health').path, '/health');
  });

  test('canonical paths are not versioned twice', () {
    expect(
      AuthService.apiUrl('/api/v1/attendance/workout-reports').path,
      '/api/v1/attendance/workout-reports',
    );
  });
}

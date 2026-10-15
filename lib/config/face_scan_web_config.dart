/// The browser may navigate only to this build's explicitly configured scanner.
class FaceScanWebConfig {
  static const origin = String.fromEnvironment(
    'FACE_SCAN_WEB_ORIGIN',
    defaultValue: 'https://vital.actofit.com',
  );

  static bool allows(Uri uri) {
    final trusted = Uri.tryParse(origin);
    return trusted != null &&
        trusted.scheme == 'https' &&
        uri.scheme == 'https' &&
        uri.origin == trusted.origin &&
        uri.userInfo.isEmpty &&
        (uri.path == '/integrations/mednovations' ||
            uri.path.startsWith('/integrations/mednovations/'));
  }
}

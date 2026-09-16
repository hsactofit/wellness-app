import '../app_brand.dart';

/// OAuth configuration that must stay in the same Google Cloud project as the
/// selected product's native Firebase client.
class GoogleAuthConfig {
  static const String medifitWebClientId =
      '133235672969-tam6tkijvkiv0jt9i379rvm9mgfsn531.apps.googleusercontent.com';

  /// Medifit needs its explicit Android web client. Mednovations intentionally
  /// uses its product-specific native Firebase configuration; passing the
  /// Medifit web client there makes Google reject the request as
  /// `invalid_audience` because the clients belong to different projects.
  static String? get serverClientId =>
      AppBrand.isMednovations ? null : medifitWebClientId;
}

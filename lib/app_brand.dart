import 'package:flutter/services.dart' show appFlavor;

/// Build-time branding for the shared wellness application.
///
/// Use `--dart-define=APP_BRAND=mednovations` for the Mednovations build.
/// The default deliberately remains Medifit so the existing product is
/// unchanged.
class AppBrand {
  static const String _definedBrand = String.fromEnvironment(
    'APP_BRAND',
    defaultValue: '',
  );

  static String get selectedBrand {
    final selected = (appFlavor ?? _definedBrand).trim().toLowerCase();
    if (selected.isEmpty) return 'medifit';
    if (selected != 'medifit' && selected != 'mednovations') {
      throw StateError('APP_BRAND must be medifit or mednovations');
    }
    return selected;
  }

  static bool get isMednovations => selectedBrand == 'mednovations';

  static String get name => isMednovations ? 'Mednovations' : 'Medifit';

  static String get wellnessName => '$name Wellness';

  static String get logoAssetPath => isMednovations
      ? 'assets/branding/mednovations/logo.png'
      : 'assets/branding/medifit/logo.png';

  static String get iconAssetPath => isMednovations
      ? 'assets/branding/mednovations/launcher.png'
      : 'assets/branding/medifit/launcher.png';

  static String get apiBrand => selectedBrand;

  static String get deepLinkScheme =>
      isMednovations ? 'mednovations' : 'medifit';

  static double get logoAspectRatio => isMednovations ? 1.46 : 1.0;
}

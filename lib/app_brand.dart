/// Build-time branding for the shared wellness application.
///
/// Use `--dart-define=APP_BRAND=mednovations` for the Mednovations build.
/// The default deliberately remains Medifit so the existing product is
/// unchanged.
class AppBrand {
  static const String _selectedBrand = String.fromEnvironment(
    'APP_BRAND',
    defaultValue: 'medifit',
  );

  static bool get isMednovations =>
      _selectedBrand.trim().toLowerCase() == 'mednovations';

  static String get name => isMednovations ? 'Mednovations' : 'Medifit';

  static String get wellnessName => '$name Wellness';

  static String get logoAssetPath => isMednovations
      ? 'assets/branding/mednovations_logo.png'
      : 'assets/app_logo.png';

  static String get iconAssetPath => isMednovations
      ? 'assets/branding/mednovations_launcher.png'
      : 'assets/app_logo.png';

  static double get logoAspectRatio => isMednovations ? 1.46 : 1.0;
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get kannada => 'कन्नड़';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get languageSaveFailed =>
      'आपकी भाषा सेव नहीं हो सकी। कृपया फिर से कोशिश करें।';
}

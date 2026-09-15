import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_brand.dart';

class LocaleController extends ValueNotifier<Locale> {
  LocaleController._() : super(const Locale('en'));

  static final LocaleController instance = LocaleController._();
  static const String _preferencePrefix = 'app_language';

  static String get preferenceKey =>
      '${_preferencePrefix}_${AppBrand.selectedBrand}';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(preferenceKey);
    final languageCode = AppBrand.supportedLanguageCodes.contains(saved)
        ? saved!
        : 'en';
    await _apply(languageCode);
  }

  Future<void> select(String languageCode) async {
    if (!AppBrand.supportedLanguageCodes.contains(languageCode)) {
      languageCode = 'en';
    }
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(preferenceKey, languageCode);
    if (!saved) throw StateError('Language preference was not saved');
    await _apply(languageCode);
  }

  Future<void> _apply(String languageCode) async {
    await initializeDateFormatting(languageCode);
    Intl.defaultLocale = languageCode;
    value = Locale(languageCode);
  }
}

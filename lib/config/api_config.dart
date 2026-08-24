import 'dart:io';

import 'package:flutter/foundation.dart';

/// Resolves the wellness-server base URL for this build.
///
/// A physical iPhone's `localhost` is the phone itself, which is why Google
/// sign-in was failing with `Connection refused` on port 8000. Debug iOS
/// builds therefore default to this Mac's LAN address. Override with
/// `--dart-define=API_BASE_URL=https://...` for a deployed API.
class ApiConfig {
  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  /// This machine's current Wi-Fi address (`ipconfig getifaddr en0`).
  /// Update if the Mac joins a different network.
  static const String _debugLanApiBaseUrl = String.fromEnvironment(
    'DEBUG_LAN_API_BASE_URL',
    defaultValue: 'http://192.168.29.226:8000',
  );

  static const String _loopbackApiBaseUrl = 'http://localhost:8000';

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kDebugMode && (Platform.isIOS || Platform.isAndroid)) {
      return _debugLanApiBaseUrl;
    }
    return _loopbackApiBaseUrl;
  }
}

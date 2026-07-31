import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

/// Must be a top-level (or static) function — the platform invokes it in a
/// separate isolate when a push arrives while the app is backgrounded or
/// terminated. Kept intentionally minimal: with a `notification` payload
/// (which is all the backend sends, see wellness-server's send_push), the
/// OS already displays the system notification on its own; there's no
/// extra work to do here unless/until the backend starts sending
/// data-only pushes.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Registers this device for real push notifications from staff
/// broadcasts (see medifit-dashboard's "New broadcast" composer →
/// POST /notifications/broadcast → wellness-server's send_push). Requests
/// permission, uploads the FCM token, and keeps it fresh across token
/// rotation — none of this does anything visible if the user declines the
/// permission prompt or if the backend has no FIREBASE_SERVICE_ACCOUNT_FILE
/// configured; it just means no push is delivered, same as any other
/// "optional integration not configured" gap in this app.
class PushService {
  PushService._privateConstructor();
  static final PushService instance = PushService._privateConstructor();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      messaging.onTokenRefresh.listen(_registerToken);
    } catch (e) {
      // Push is an enhancement, not a hard dependency — a misconfigured
      // Firebase project (e.g. no APNs key set up in Apple Developer
      // Console yet) shouldn't block app startup.
      debugPrint("PushService init error: $e");
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await ApiService.instance.registerDeviceToken(
        token,
        Platform.isIOS ? 'ios' : 'android',
      );
    } catch (e) {
      debugPrint("Device token registration error: $e");
    }
  }
}

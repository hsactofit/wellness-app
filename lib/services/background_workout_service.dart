import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The outcome of asking the operating system to show the workout timer.
///
/// iOS members can disable Live Activities in Settings, and devices below
/// iOS 16.1 do not support them. These states are intentionally reported to
/// Flutter so Gym Access can explain the missing system surface without
/// blocking the server-authoritative workout session.
enum PersistentTimerStatus { active, disabled, unsupported, failed }

/// Small platform bridge for the persistent workout indicator.
///
/// Android uses a foreground service. iOS uses a Live Activity where the OS
/// supports it, actionable local notifications on older versions, and a native
/// region monitor only while the workout remains active. The bridge remains
/// optional so a missing platform surface never blocks checkout.
class BackgroundWorkoutService {
  BackgroundWorkoutService._() {
    // The service is a singleton and can be touched by non-widget tests (or
    // during app startup) before the framework binding is otherwise created.
    // Initialise it before registering the platform-channel callback.
    WidgetsFlutterBinding.ensureInitialized();
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static final BackgroundWorkoutService instance = BackgroundWorkoutService._();
  static const _channel = MethodChannel('com.medifit/workout_background');
  final ValueNotifier<int> checkoutRequestedSignal = ValueNotifier<int>(0);
  final ValueNotifier<int> departureCheckoutRequiredSignal = ValueNotifier<int>(
    0,
  );
  final ValueNotifier<int> continueRequestedSignal = ValueNotifier<int>(0);
  final ValueNotifier<int> slotEndContinueRequestedSignal = ValueNotifier<int>(
    0,
  );
  bool _uiReady = false;

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'checkoutRequested':
        checkoutRequestedSignal.value++;
      case 'departureCheckoutRequired':
      case 'geofenceExited': // Compatibility with an already running native app.
        departureCheckoutRequiredSignal.value++;
      case 'continueRequested':
        continueRequestedSignal.value++;
      case 'slotEndContinueRequested':
        slotEndContinueRequestedSignal.value++;
    }
  }

  /// Flush native deep links only after [MainShell] has installed its event
  /// listeners. Calling this from the singleton constructor could otherwise
  /// lose a cold-launch checkout request before Flutter navigation exists.
  Future<void> markUiReady() async {
    if (kIsWeb || _uiReady) return;
    _uiReady = true;
    try {
      await _channel.invokeMethod<void>('ready');
    } on PlatformException catch (error) {
      _uiReady = false;
      debugPrint('Workout background bridge unavailable: $error');
    } on MissingPluginException catch (error) {
      _uiReady = false;
      debugPrint('Workout background bridge unavailable: $error');
    }
  }

  /// Starts the durable timer/prompt surface. Scanner-origin tracking is armed
  /// separately after the successful QR/PIN scan has captured a local point.
  Future<bool> start({
    required String sessionId,
    required String facilityName,
    DateTime? checkInAt,
    DateTime? slotEndAt,
    String? bookingId,
    bool showPersistentTimer = true,
  }) async {
    if (kIsWeb) return false;
    try {
      final nativeGeofence = await _channel.invokeMethod<bool>('start', {
        'sessionId': sessionId,
        'facilityName': facilityName,
        'checkInAt': (checkInAt ?? DateTime.now()).millisecondsSinceEpoch,
        if (slotEndAt != null) 'slotEndAt': slotEndAt.millisecondsSinceEpoch,
        if (bookingId != null) 'bookingId': bookingId,
        'showPersistentTimer': showPersistentTimer,
      });
      return nativeGeofence == true;
    } on PlatformException catch (error) {
      debugPrint('Workout background service unavailable: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Workout background service unavailable: $error');
    }
    return false;
  }

  /// Register the fixed 2 km departure monitor around the device's QR-scan
  /// location. Coordinates remain in native/local storage only for this
  /// active workout and are removed by [stop].
  Future<bool> armScannerOrigin({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    if (kIsWeb) return false;
    try {
      final registered = await _channel.invokeMethod<bool>('armScannerOrigin', {
        'sessionId': sessionId,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': 2000,
      });
      return registered == true;
    } on PlatformException catch (error) {
      debugPrint('Scanner-origin monitor unavailable: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Scanner-origin monitor unavailable: $error');
    }
    return false;
  }

  /// Ensures the operating-system timer represents this active workout.
  ///
  /// iOS creates or updates its Live Activity while the app is foregrounded;
  /// Android starts its existing foreground-service chronometer. The native
  /// result lets the app guide an iPhone member if Live Activities are off.
  Future<PersistentTimerStatus> showPersistentTimer({
    required String sessionId,
    required String facilityName,
    required DateTime checkInAt,
  }) async {
    if (kIsWeb) return PersistentTimerStatus.unsupported;
    try {
      final status = await _channel.invokeMethod<String>('showTimer', {
        'sessionId': sessionId,
        'facilityName': facilityName,
        'checkInAt': checkInAt.millisecondsSinceEpoch,
      });
      return switch (status) {
        'disabled' => PersistentTimerStatus.disabled,
        'unsupported' => PersistentTimerStatus.unsupported,
        'failed' => PersistentTimerStatus.failed,
        _ => PersistentTimerStatus.active,
      };
    } on PlatformException catch (error) {
      debugPrint('Workout timer surface unavailable: $error');
      return PersistentTimerStatus.failed;
    } on MissingPluginException catch (error) {
      debugPrint('Workout timer surface unavailable: $error');
      return PersistentTimerStatus.failed;
    }
  }

  /// Removes Android's duplicate foreground notification while the member is
  /// viewing the in-app workout. On iOS this deliberately does nothing: its
  /// Live Activity must remain active until authenticated checkout.
  Future<void> hidePersistentTimer() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('hideTimer');
    } on PlatformException catch (error) {
      debugPrint('Workout timer surface hide failed: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Workout timer surface hide unavailable: $error');
    }
  }

  Future<void> stop() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException catch (error) {
      debugPrint('Workout background service stop failed: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Workout background service stop unavailable: $error');
    }
  }
}

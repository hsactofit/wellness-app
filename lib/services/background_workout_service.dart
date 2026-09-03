import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
    unawaited(_markDartReady());
  }

  static final BackgroundWorkoutService instance = BackgroundWorkoutService._();
  static const _channel = MethodChannel('com.medifit/workout_background');
  final ValueNotifier<int> checkoutRequestedSignal = ValueNotifier<int>(0);
  final ValueNotifier<int> geofenceExitedSignal = ValueNotifier<int>(0);
  final ValueNotifier<int> continueRequestedSignal = ValueNotifier<int>(0);

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'checkoutRequested':
        checkoutRequestedSignal.value++;
      case 'geofenceExited':
        geofenceExitedSignal.value++;
      case 'continueRequested':
        continueRequestedSignal.value++;
    }
  }

  Future<void> _markDartReady() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('ready');
    } on PlatformException catch (error) {
      debugPrint('Workout background bridge unavailable: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Workout background bridge unavailable: $error');
    }
  }

  /// Returns true only when iOS is handling geofence registration natively.
  /// Flutter then avoids starting its continuous position stream, which keeps
  /// facility-exit detection private and OS-managed in the background.
  Future<bool> start({
    required String sessionId,
    required String facilityName,
    DateTime? checkInAt,
    DateTime? slotEndAt,
    String? bookingId,
    double? latitude,
    double? longitude,
    int? geofenceRadiusMeters,
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
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (geofenceRadiusMeters != null)
          'geofenceRadiusMeters': geofenceRadiusMeters,
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

  /// Makes the operating-system timer visible after the member leaves the
  /// in-app active-workout view. Native code owns the actual clock so it
  /// continues while Dart is paused or the phone is locked.
  Future<void> showPersistentTimer({
    required String sessionId,
    required String facilityName,
    required DateTime checkInAt,
  }) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('showTimer', {
        'sessionId': sessionId,
        'facilityName': facilityName,
        'checkInAt': checkInAt.millisecondsSinceEpoch,
      });
    } on PlatformException catch (error) {
      debugPrint('Workout timer surface unavailable: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Workout timer surface unavailable: $error');
    }
  }

  /// Removes only the duplicate operating-system timer while the member is
  /// looking at the in-app timer. It deliberately leaves native geofencing
  /// and workout-completion reminders running.
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

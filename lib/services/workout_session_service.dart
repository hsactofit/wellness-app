import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'auth_service.dart';
import 'background_workout_service.dart';
import 'facility_rating_service.dart';

enum WorkoutSessionPromptReason { hourly, slotEnd, leftFacility }

class ActiveWorkoutSession {
  const ActiveWorkoutSession({
    required this.id,
    required this.facilityName,
    required this.facilityPlace,
    required this.checkInAt,
    required this.geofenceRadiusMeters,
    this.latitude,
    this.longitude,
    this.bookingId,
    this.instantRequestId,
    this.slotEndAt,
    this.planSnapshot = const [],
  });

  final String id;
  final String facilityName;
  final String facilityPlace;
  final DateTime checkInAt;
  final double? latitude;
  final double? longitude;
  final int geofenceRadiusMeters;
  final String? bookingId;
  final String? instantRequestId;
  final DateTime? slotEndAt;
  final List<Map<String, dynamic>> planSnapshot;

  bool get hasGeofence => latitude != null && longitude != null;
}

class WorkoutSessionException implements Exception {
  WorkoutSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WorkoutCheckoutResult {
  const WorkoutCheckoutResult({required this.checkOutAt, this.ratingRequest});

  final DateTime checkOutAt;
  final FacilityRatingPrompt? ratingRequest;
}

typedef WorkoutSessionPrompt =
    Future<void> Function(
      ActiveWorkoutSession session,
      WorkoutSessionPromptReason reason,
    );

/// Owns local workout-session persistence, authenticated attendance calls,
/// and background-safe reminders. Android's foreground service keeps the
/// notification timer alive; iOS resumes the local reminder/location monitor
/// when the app returns to the foreground. The server remains authoritative.
class WorkoutSessionService {
  WorkoutSessionService._();

  static final WorkoutSessionService instance = WorkoutSessionService._();

  static const _checkedInKey = 'gym_checked_in';
  static const _nameKey = 'gym_name';
  static const _placeKey = 'gym_place';
  static const _checkInKey = 'gym_check_in_time';
  static const _sessionIdKey = 'gym_session_id';
  static const _checkoutRefKey = 'gym_checkout_client_ref';
  static const _latitudeKey = 'gym_facility_latitude';
  static const _longitudeKey = 'gym_facility_longitude';
  static const _radiusKey = 'gym_geofence_radius_m';
  static const _bookingIdKey = 'gym_booking_id';
  static const _instantRequestIdKey = 'gym_instant_request_id';
  static const _slotEndKey = 'gym_slot_end_at';
  static const _planSnapshotKey = 'gym_plan_snapshot';
  static const _nativeGeofenceKey = 'gym_native_geofence_registered';
  // Keep this separate from the server's attendance time. The server can
  // return an already-open record, but the first reminder must wait one hour
  // from the member's successful local check-in.
  static const _hourlyPromptAnchorKey = 'gym_hourly_prompt_anchor_at';
  static const _lastHourlyPromptKey = 'gym_last_hourly_prompt_at';
  static const _slotEndPromptedKey = 'gym_slot_end_prompted';

  Timer? _hourlyTimer;
  StreamSubscription<Position>? _positionSubscription;
  WorkoutSessionPrompt? _promptHandler;
  bool _promptInProgress = false;
  bool _outsideFacility = false;
  bool _wasInsideFacility = false;

  /// Notifies open workout screens when another part of the app changes the
  /// persisted session (for example, the global hourly/geofence prompt).
  final ValueNotifier<int> sessionRefreshSignal = ValueNotifier<int>(0);

  void configurePromptHandler(WorkoutSessionPrompt? handler) {
    _promptHandler = handler;
  }

  Future<ActiveWorkoutSession?> loadActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_checkedInKey) ?? false)) return null;

    final checkInAt = DateTime.tryParse(prefs.getString(_checkInKey) ?? '');
    final id = prefs.getString(_sessionIdKey);
    if (checkInAt == null || id == null || id.isEmpty) return null;

    final planJson = prefs.getString(_planSnapshotKey);
    final planSnapshot = _decodePlanSnapshot(planJson);
    return ActiveWorkoutSession(
      id: id,
      facilityName: prefs.getString(_nameKey) ?? 'Facility',
      facilityPlace: prefs.getString(_placeKey) ?? '',
      checkInAt: checkInAt,
      latitude: prefs.getDouble(_latitudeKey),
      longitude: prefs.getDouble(_longitudeKey),
      geofenceRadiusMeters: prefs.getInt(_radiusKey) ?? 2000,
      bookingId: prefs.getString(_bookingIdKey),
      instantRequestId: prefs.getString(_instantRequestIdKey),
      slotEndAt: DateTime.tryParse(prefs.getString(_slotEndKey) ?? ''),
      planSnapshot: planSnapshot,
    );
  }

  /// Reconcile the recovery cache with the server-owned open session. A
  /// process restart or OS eviction can remove the local cache while the
  /// server session is still active; a missing session is the only expected
  /// 404 and is treated as a normal signed-out state.
  Future<ActiveWorkoutSession?> recoverActiveSession() async {
    final cached = await loadActiveSession();
    try {
      var token = await AuthService.instance.getAccessToken();
      var response = await http.get(
        AuthService.apiUrl('/api/attendance/me/active'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 401) {
        await AuthService.instance.refreshSessionToken();
        token = await AuthService.instance.getAccessToken();
        response = await http.get(
          AuthService.apiUrl('/api/attendance/me/active'),
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        );
      }
      if (response.statusCode == 404) {
        if (cached != null) await clearLocalSession();
        return null;
      }
      final body = _decodeBody(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WorkoutSessionException(_errorMessage(body, response.statusCode));
      }
      final session = Map<String, dynamic>.from(body as Map);
      await saveCheckIn(
        session: session,
        fallbackFacilityName:
            session['facility_name']?.toString() ?? 'Facility',
        fallbackFacilityPlace: cached?.facilityPlace ?? '',
      );
      return loadActiveSession();
    } catch (_) {
      // Offline recovery still uses the last known cache. It is not treated
      // as authoritative once the server can be reached again.
      return cached;
    }
  }

  Future<Map<String, dynamic>> checkIn({
    required String facilityCode,
    required String memberPin,
    String? bookingId,
    String? instantRequestId,
  }) async {
    final token = await AuthService.instance.getAccessToken();
    final response = await http.post(
      AuthService.apiUrl('/api/attendance/checkin'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'facility_code': facilityCode,
        'member_pin': memberPin,
        'method': 'QR scan',
        'activity': 'Workout',
        'client_ref': Uuid().v4(),
        if (bookingId != null) 'booking_id': bookingId,
        if (instantRequestId != null) 'instant_request_id': instantRequestId,
      }),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw WorkoutSessionException(_errorMessage(body, response.statusCode));
    }
    return Map<String, dynamic>.from(body as Map);
  }

  Future<void> saveCheckIn({
    required Map<String, dynamic> session,
    required String fallbackFacilityName,
    required String fallbackFacilityPlace,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final localCheckInAt = DateTime.now();
    final checkInAt =
        session['check_in_at'] as String? ?? localCheckInAt.toIso8601String();
    final name = session['facility_name'] as String? ?? fallbackFacilityName;
    final latitude = (session['facility_latitude'] as num?)?.toDouble();
    final longitude = (session['facility_longitude'] as num?)?.toDouble();
    final radius = (session['geofence_radius_m'] as num?)?.toInt() ?? 2000;
    final planSnapshot = (session['plan_snapshot'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    await prefs.setBool(_checkedInKey, true);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_placeKey, fallbackFacilityPlace);
    await prefs.setString(_checkInKey, checkInAt);
    await prefs.setString(_sessionIdKey, session['id']?.toString() ?? '');
    await _setOptionalString(prefs, _bookingIdKey, session['booking_id']);
    await _setOptionalString(
      prefs,
      _instantRequestIdKey,
      session['instant_request_id'],
    );
    await _setOptionalString(prefs, _slotEndKey, session['slot_end_at']);
    await prefs.setString(_planSnapshotKey, jsonEncode(planSnapshot));
    await prefs.setString(
      _hourlyPromptAnchorKey,
      localCheckInAt.toIso8601String(),
    );
    await prefs.remove(_lastHourlyPromptKey);
    await prefs.remove(_slotEndPromptedKey);

    if (latitude != null && longitude != null) {
      await prefs.setDouble(_latitudeKey, latitude);
      await prefs.setDouble(_longitudeKey, longitude);
      await prefs.setInt(_radiusKey, radius);
    } else {
      await prefs.remove(_latitudeKey);
      await prefs.remove(_longitudeKey);
      await prefs.remove(_radiusKey);
    }
    final nativeGeofenceRegistered = await BackgroundWorkoutService.instance
        .start(
          sessionId: session['id']?.toString() ?? '',
          facilityName: name,
          checkInAt: DateTime.tryParse(checkInAt),
          slotEndAt: DateTime.tryParse(
            session['slot_end_at']?.toString() ?? '',
          ),
          bookingId: session['booking_id']?.toString(),
          latitude: latitude,
          longitude: longitude,
          geofenceRadiusMeters: radius,
        );
    await prefs.setBool(_nativeGeofenceKey, nativeGeofenceRegistered);
  }

  Future<WorkoutCheckoutResult> checkout({
    List<String> completedItemIds = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final checkoutRef = prefs.getString(_checkoutRefKey) ?? Uuid().v4();
    await prefs.setString(_checkoutRefKey, checkoutRef);
    final token = await AuthService.instance.getAccessToken();
    final response = await http.post(
      AuthService.apiUrl('/api/attendance/checkout'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'client_ref': checkoutRef,
        'completed_item_ids': completedItemIds,
      }),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw WorkoutSessionException(_errorMessage(body, response.statusCode));
    }

    final responseData = Map<String, dynamic>.from(body as Map);
    final checkOutAt =
        DateTime.tryParse(responseData['check_out_at'] as String? ?? '') ??
        DateTime.now();
    await clearLocalSession(checkOutAt: checkOutAt);
    final rawRating = responseData['rating_request'];
    return WorkoutCheckoutResult(
      checkOutAt: checkOutAt,
      ratingRequest: rawRating is Map
          ? FacilityRatingPrompt.fromJson(rawRating)
          : null,
    );
  }

  Future<void> continueWorkout({String? reason}) async {
    final token = await AuthService.instance.getAccessToken();
    final response = await http.post(
      AuthService.apiUrl('/api/attendance/continue'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{if (reason != null) 'reason': reason}),
    );
    final body = _decodeBody(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WorkoutSessionException(_errorMessage(body, response.statusCode));
    }
  }

  Future<void> clearLocalSession({DateTime? checkOutAt}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkedInKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_placeKey);
    await prefs.remove(_checkInKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_checkoutRefKey);
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
    await prefs.remove(_radiusKey);
    await prefs.remove(_bookingIdKey);
    await prefs.remove(_instantRequestIdKey);
    await prefs.remove(_slotEndKey);
    await prefs.remove(_planSnapshotKey);
    await prefs.remove(_nativeGeofenceKey);
    await prefs.remove(_hourlyPromptAnchorKey);
    await prefs.remove(_lastHourlyPromptKey);
    await prefs.remove('gym_logged_exercises');
    await prefs.setString(
      'gym_check_out_time',
      (checkOutAt ?? DateTime.now()).toIso8601String(),
    );
    await prefs.setString(
      'gym_done_today_date',
      DateTime.now().toIso8601String().substring(0, 10),
    );
    await BackgroundWorkoutService.instance.stop();
    await stopMonitoring();
    sessionRefreshSignal.value++;
  }

  Future<void> startMonitoring({bool requestLocationPermission = false}) async {
    final session = await loadActiveSession();
    if (session == null) {
      await stopMonitoring();
      return;
    }
    await _scheduleHourlyPrompt(session);
    await _startLocationMonitoring(
      session,
      requestLocationPermission: requestLocationPermission,
    );
  }

  Future<void> stopMonitoring() async {
    _hourlyTimer?.cancel();
    _hourlyTimer = null;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _outsideFacility = false;
    _wasInsideFacility = false;
  }

  Future<void> _scheduleHourlyPrompt(ActiveWorkoutSession session) async {
    _hourlyTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    final slotEndPrompted = prefs.getBool(_slotEndPromptedKey) ?? false;
    final slotEnd = session.slotEndAt;
    if (session.bookingId != null && !slotEndPrompted && slotEnd != null) {
      var slotDelay = slotEnd.difference(DateTime.now());
      if (slotDelay.isNegative) slotDelay = Duration.zero;
      _hourlyTimer = Timer(slotDelay, () async {
        await _triggerPrompt(session, WorkoutSessionPromptReason.slotEnd);
        final current = await loadActiveSession();
        if (current != null) await _scheduleHourlyPrompt(current);
      });
      return;
    }
    final lastPrompt = DateTime.tryParse(
      prefs.getString(_lastHourlyPromptKey) ?? '',
    );
    final localCheckInAnchor = DateTime.tryParse(
      prefs.getString(_hourlyPromptAnchorKey) ?? '',
    );
    final anchor = lastPrompt ?? localCheckInAnchor ?? session.checkInAt;
    var delay = const Duration(hours: 1) - DateTime.now().difference(anchor);
    if (delay.isNegative || delay == Duration.zero) delay = Duration.zero;

    _hourlyTimer = Timer(delay, () async {
      await _triggerPrompt(session, WorkoutSessionPromptReason.hourly);
      final current = await loadActiveSession();
      if (current != null) await _scheduleHourlyPrompt(current);
    });
  }

  Future<void> _startLocationMonitoring(
    ActiveWorkoutSession session, {
    required bool requestLocationPermission,
  }) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    if (!session.hasGeofence || kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    // Core Location region monitoring wakes an iPhone even when Flutter is
    // suspended. Do not keep a parallel continuous stream alive on iOS when
    // the native region registration was accepted at check-in.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        (prefs.getBool(_nativeGeofenceKey) ?? false)) {
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestLocationPermission) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final LocationSettings locationSettings =
        defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 50,
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationTitle: 'Workout in progress',
              notificationText: 'Medifit is monitoring your active workout.',
              enableWakeLock: true,
              enableWifiLock: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 50,
            activityType: ActivityType.fitness,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
          );
    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) => _handleLocation(session, position),
          onError: (Object error) =>
              debugPrint('Workout location monitoring error: $error'),
        );
  }

  Future<void> _handleLocation(
    ActiveWorkoutSession session,
    Position position,
  ) async {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      session.latitude!,
      session.longitude!,
    );
    // Only ask once the phone is confidently outside the configured range;
    // a weak GPS reading at the edge must not end a real workout.
    final confidentlyOutside =
        distance - position.accuracy > session.geofenceRadiusMeters;
    if (!confidentlyOutside) {
      // Leaving is meaningful only after the member has actually been inside
      // this facility during the current monitoring period. This prevents a
      // simulator's default location (or an initial stale GPS fix) from
      // immediately looking like the member has left right after check-in.
      _wasInsideFacility = true;
      _outsideFacility = false;
      return;
    }
    if (!_wasInsideFacility || _outsideFacility) return;
    _outsideFacility = true;
    await _triggerPrompt(session, WorkoutSessionPromptReason.leftFacility);
  }

  Future<void> _triggerPrompt(
    ActiveWorkoutSession session,
    WorkoutSessionPromptReason reason,
  ) async {
    if (_promptInProgress || _promptHandler == null) return;
    final active = await loadActiveSession();
    if (active == null || active.id != session.id) return;

    _promptInProgress = true;
    try {
      if (reason == WorkoutSessionPromptReason.hourly ||
          reason == WorkoutSessionPromptReason.slotEnd) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _lastHourlyPromptKey,
          DateTime.now().toIso8601String(),
        );
        if (reason == WorkoutSessionPromptReason.slotEnd) {
          await prefs.setBool(_slotEndPromptedKey, true);
        }
      }
      await _promptHandler!(session, reason);
    } finally {
      _promptInProgress = false;
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _errorMessage(dynamic body, int statusCode) {
    if (body is Map && body['detail'] != null) return body['detail'].toString();
    return 'Attendance request failed ($statusCode)';
  }

  List<Map<String, dynamic>> _decodePlanSnapshot(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _setOptionalString(
    SharedPreferences prefs,
    String key,
    Object? value,
  ) async {
    if (value == null || value.toString().isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value.toString());
    }
  }
}

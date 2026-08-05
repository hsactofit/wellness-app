import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

enum WorkoutSessionPromptReason { hourly, leftFacility }

class ActiveWorkoutSession {
  const ActiveWorkoutSession({
    required this.id,
    required this.facilityName,
    required this.facilityPlace,
    required this.checkInAt,
    required this.geofenceRadiusMeters,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String facilityName;
  final String facilityPlace;
  final DateTime checkInAt;
  final double? latitude;
  final double? longitude;
  final int geofenceRadiusMeters;

  bool get hasGeofence => latitude != null && longitude != null;
}

class WorkoutSessionException implements Exception {
  WorkoutSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WorkoutCheckoutResult {
  const WorkoutCheckoutResult({required this.checkOutAt});

  final DateTime checkOutAt;
}

typedef WorkoutSessionPrompt =
    Future<void> Function(
      ActiveWorkoutSession session,
      WorkoutSessionPromptReason reason,
    );

/// Owns local workout-session persistence, the authenticated attendance calls,
/// and foreground safety checks. Location is deliberately foreground-only: the
/// OS may suspend this app, but the hourly check is re-evaluated as soon as it
/// resumes so a missed background timer never becomes a stale open session.
class WorkoutSessionService {
  WorkoutSessionService._();

  static final WorkoutSessionService instance = WorkoutSessionService._();

  static const _checkedInKey = 'gym_checked_in';
  static const _nameKey = 'gym_name';
  static const _placeKey = 'gym_place';
  static const _checkInKey = 'gym_check_in_time';
  static const _sessionIdKey = 'gym_session_id';
  static const _latitudeKey = 'gym_facility_latitude';
  static const _longitudeKey = 'gym_facility_longitude';
  static const _radiusKey = 'gym_geofence_radius_m';
  // Keep this separate from the server's attendance time. The server can
  // return an already-open record, but the first reminder must wait one hour
  // from the member's successful local check-in.
  static const _hourlyPromptAnchorKey = 'gym_hourly_prompt_anchor_at';
  static const _lastHourlyPromptKey = 'gym_last_hourly_prompt_at';

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

    return ActiveWorkoutSession(
      id: id,
      facilityName: prefs.getString(_nameKey) ?? 'Facility',
      facilityPlace: prefs.getString(_placeKey) ?? '',
      checkInAt: checkInAt,
      latitude: prefs.getDouble(_latitudeKey),
      longitude: prefs.getDouble(_longitudeKey),
      geofenceRadiusMeters: prefs.getInt(_radiusKey) ?? 150,
    );
  }

  Future<Map<String, dynamic>> checkIn({
    required String facilityCode,
    required String memberPin,
  }) async {
    final token = await AuthService.instance.getAccessToken();
    final response = await http.post(
      Uri.parse('${AuthService.apiBaseUrl}/api/attendance/checkin'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'facility_code': facilityCode,
        'member_pin': memberPin,
        'method': 'QR scan',
        'activity': 'Workout',
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
    final radius = (session['geofence_radius_m'] as num?)?.toInt() ?? 150;

    await prefs.setBool(_checkedInKey, true);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_placeKey, fallbackFacilityPlace);
    await prefs.setString(_checkInKey, checkInAt);
    await prefs.setString(_sessionIdKey, session['id']?.toString() ?? '');
    await prefs.setString(
      _hourlyPromptAnchorKey,
      localCheckInAt.toIso8601String(),
    );
    await prefs.remove(_lastHourlyPromptKey);

    if (latitude != null && longitude != null) {
      await prefs.setDouble(_latitudeKey, latitude);
      await prefs.setDouble(_longitudeKey, longitude);
      await prefs.setInt(_radiusKey, radius);
    } else {
      await prefs.remove(_latitudeKey);
      await prefs.remove(_longitudeKey);
      await prefs.remove(_radiusKey);
    }
  }

  Future<WorkoutCheckoutResult> checkout() async {
    final token = await AuthService.instance.getAccessToken();
    final response = await http.post(
      Uri.parse('${AuthService.apiBaseUrl}/api/attendance/checkout'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{}),
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
    await stopMonitoring();
    return WorkoutCheckoutResult(checkOutAt: checkOutAt);
  }

  Future<void> clearLocalSession({DateTime? checkOutAt}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkedInKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_placeKey);
    await prefs.remove(_checkInKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
    await prefs.remove(_radiusKey);
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

    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestLocationPermission) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 50,
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
      if (reason == WorkoutSessionPromptReason.hourly) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _lastHourlyPromptKey,
          DateTime.now().toIso8601String(),
        );
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
}

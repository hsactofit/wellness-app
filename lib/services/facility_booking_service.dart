import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'auth_service.dart';

/// Client for the versioned facility-booking and access-request API.
///
/// The API returns timezone-aware timestamps.  The model deliberately keeps
/// the raw timezone on [DateTime] so the UI can show the facility-local slot
/// label without guessing the member's timezone.
class FacilityBookingService {
  FacilityBookingService._();

  static final FacilityBookingService instance = FacilityBookingService._();
  static const _uuid = Uuid();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = AuthService.apiUrl(path).replace(queryParameters: query);
    final headers = await _headers();
    final encoded = body == null ? null : jsonEncode(body);
    Future<http.Response> request(String tokenPath) {
      final requestUri = Uri.parse(tokenPath);
      switch (method) {
        case 'GET':
          return http.get(requestUri, headers: headers);
        case 'POST':
          return http.post(requestUri, headers: headers, body: encoded);
        case 'DELETE':
          return http.delete(requestUri, headers: headers);
        case 'PUT':
          return http.put(requestUri, headers: headers, body: encoded);
        default:
          throw ArgumentError('Unsupported HTTP method $method');
      }
    }

    var response = await request(uri.toString());
    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      final refreshed = await _headers();
      headers
        ..clear()
        ..addAll(refreshed);
      response = await request(uri.toString());
    }
    return response;
  }

  Future<dynamic> _json(http.Response response) async {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<T> _expect<T>(
    http.Response response,
    T Function(dynamic) parse,
  ) async {
    final body = await _json(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FacilityBookingException(
        _message(body, response.statusCode),
        statusCode: response.statusCode,
      );
    }
    return parse(body);
  }

  String _message(dynamic body, int code) {
    if (body is Map && body['detail'] != null) return body['detail'].toString();
    return 'Facility request failed ($code)';
  }

  Future<FacilityPage> fetchFacilities(DateTime day, {int page = 1}) async {
    final response = await _send(
      'GET',
      '/api/facilities/eligible',
      query: {'date': _date(day), 'page': '$page', 'page_size': '10'},
    );
    return _expect(response, (body) => FacilityPage.fromJson(body as Map));
  }

  Future<List<FacilitySlot>> fetchSlots(String facilityId, DateTime day) async {
    final response = await _send(
      'GET',
      '/api/facilities/$facilityId/slots',
      query: {'date': _date(day)},
    );
    return _expect(
      response,
      (body) => (body as List)
          .map((item) => FacilitySlot.fromJson(item as Map))
          .toList(),
    );
  }

  Future<MemberBooking> bookSlot(String slotId) async {
    final response = await _send(
      'POST',
      '/api/facility-bookings',
      body: {'slot_id': slotId, 'idempotency_key': _uuid.v4()},
    );
    return _expect(response, (body) => MemberBooking.fromJson(body as Map));
  }

  Future<FacilityWorkoutDataConsent> fetchWorkoutDataConsent() async {
    final response = await _send('GET', '/api/facility-workout-data-consent');
    return _expect(
      response,
      (body) => FacilityWorkoutDataConsent.fromJson(body as Map),
    );
  }

  Future<FacilityWorkoutDataConsent> setWorkoutDataConsent({
    required bool granted,
  }) async {
    final response = await _send(
      'PUT',
      '/api/facility-workout-data-consent',
      body: {
        'granted': granted,
        'disclosure_version': 'facility-workout-data-v3',
      },
    );
    return _expect(
      response,
      (body) => FacilityWorkoutDataConsent.fromJson(body as Map),
    );
  }

  Future<List<MemberBooking>> myBookings() async {
    final response = await _send('GET', '/api/facility-bookings/me');
    return _expect(
      response,
      (body) => (body as List)
          .map((item) => MemberBooking.fromJson(item as Map))
          .toList(),
    );
  }

  Future<MemberBooking> cancelBooking(String bookingId) async {
    final response = await _send('DELETE', '/api/facility-bookings/$bookingId');
    return _expect(response, (body) => MemberBooking.fromJson(body as Map));
  }

  Future<FacilityAccessRequest> requestInstant(
    String facilityId, {
    String? reason,
  }) async {
    final response = await _send(
      'POST',
      '/api/facility-access/instant-requests',
      body: {
        'facility_id': facilityId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        'idempotency_key': _uuid.v4(),
      },
    );
    return _expect(
      response,
      (body) => FacilityAccessRequest.fromJson(body as Map),
    );
  }

  Future<FacilityAccessRequest> requestCapacity(
    String facilityId, {
    DateTime? requestedFor,
    String? reason,
  }) async {
    final response = await _send(
      'POST',
      '/api/facility-access/capacity-requests',
      body: {
        'facility_id': facilityId,
        if (requestedFor != null)
          'requested_for': requestedFor.toIso8601String(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        'idempotency_key': _uuid.v4(),
      },
    );
    return _expect(
      response,
      (body) => FacilityAccessRequest.fromJson(body as Map),
    );
  }

  Future<FacilityAccessRequest> requestStatus(String requestId) async {
    final response = await _send(
      'GET',
      '/api/facility-access/requests/$requestId',
    );
    return _expect(
      response,
      (body) => FacilityAccessRequest.fromJson(body as Map),
    );
  }

  Future<FacilityAccessRequest> raiseIssue(
    String requestId, {
    String? reason,
  }) async {
    final response = await _send(
      'POST',
      '/api/facility-access/requests/$requestId/raise-issue',
      body: {'reason': reason ?? 'Unable to book an available slot'},
    );
    return _expect(
      response,
      (body) => FacilityAccessRequest.fromJson(body as Map),
    );
  }

  Future<MemberBooking> acceptSuggestion(String requestId) async {
    final response = await _send(
      'POST',
      '/api/facility-access/requests/$requestId/accept-suggestion',
      body: {'idempotency_key': _uuid.v4()},
    );
    return _expect(response, (body) => MemberBooking.fromJson(body as Map));
  }

  Future<List<WorkoutReport>> workoutReports() async {
    final response = await _send('GET', '/api/v1/attendance/workout-reports');
    return _expect(
      response,
      (body) => (body as List)
          .map((item) => WorkoutReport.fromJson(item as Map))
          .toList(),
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class FacilityBookingException implements Exception {
  FacilityBookingException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class FacilityWorkoutDataConsent {
  const FacilityWorkoutDataConsent({
    required this.active,
    required this.disclosureVersion,
    required this.disclosureText,
    this.grantedAt,
    this.revokedAt,
  });

  final bool active;
  final String disclosureVersion;
  final String disclosureText;
  final DateTime? grantedAt;
  final DateTime? revokedAt;

  factory FacilityWorkoutDataConsent.fromJson(Map body) =>
      FacilityWorkoutDataConsent(
        active: body['active'] == true,
        disclosureVersion:
            body['disclosure_version']?.toString() ??
            'facility-workout-data-v3',
        disclosureText: body['disclosure_text']?.toString() ?? '',
        grantedAt: body['granted_at'] == null
            ? null
            : DateTime.tryParse(body['granted_at'].toString()),
        revokedAt: body['revoked_at'] == null
            ? null
            : DateTime.tryParse(body['revoked_at'].toString()),
      );
}

class FacilityPage {
  const FacilityPage({
    required this.items,
    required this.page,
    required this.total,
  });

  final List<EligibleFacility> items;
  final int page;
  final int total;

  bool get hasNext => page * 10 < total;

  factory FacilityPage.fromJson(Map body) => FacilityPage(
    items: (body['items'] as List? ?? [])
        .map((item) => EligibleFacility.fromJson(item as Map))
        .toList(),
    page: (body['page'] as num?)?.toInt() ?? 1,
    total: (body['total'] as num?)?.toInt() ?? 0,
  );
}

class EligibleFacility {
  const EligibleFacility({
    required this.id,
    required this.code,
    required this.name,
    required this.city,
    required this.address,
    required this.timezone,
    required this.previouslyVisited,
    required this.recommended,
    required this.availableSlots,
    required this.totalSlots,
    required this.bookingClosed,
    required this.multiFacility,
    required this.mapsUrl,
    required this.slots,
  });

  final String id;
  final String code;
  final String name;
  final String city;
  final String? address;
  final String timezone;
  final bool previouslyVisited;
  final bool recommended;
  final int availableSlots;
  final int totalSlots;
  final bool bookingClosed;
  final bool multiFacility;
  final String? mapsUrl;
  final List<FacilitySlot> slots;

  factory EligibleFacility.fromJson(Map body) => EligibleFacility(
    id: body['id'].toString(),
    code: body['code']?.toString() ?? '',
    name: body['name']?.toString() ?? 'Facility',
    city: body['city']?.toString() ?? '',
    address: body['address']?.toString(),
    timezone: body['timezone']?.toString() ?? 'Asia/Kolkata',
    previouslyVisited: body['previously_visited'] == true,
    recommended: body['recommended'] == true,
    availableSlots: (body['available_slots'] as num?)?.toInt() ?? 0,
    totalSlots: (body['total_slots'] as num?)?.toInt() ?? 0,
    bookingClosed: body['booking_closed'] == true,
    multiFacility: body['multi_facility'] == true,
    mapsUrl: body['maps_url']?.toString(),
    slots: (body['slots'] as List? ?? [])
        .map((item) => FacilitySlot.fromJson(item as Map))
        .toList(),
  );
}

class FacilitySlot {
  const FacilitySlot({
    required this.id,
    required this.facilityId,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.booked,
    required this.remaining,
  });

  final String id;
  final String facilityId;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int booked;
  final int remaining;

  bool get isStarted => startsAt.isBefore(DateTime.now());

  factory FacilitySlot.fromJson(Map body) => FacilitySlot(
    id: body['id'].toString(),
    facilityId: body['facility_id'].toString(),
    startsAt: DateTime.parse(body['starts_at'].toString()),
    endsAt: DateTime.parse(body['ends_at'].toString()),
    capacity: (body['capacity'] as num?)?.toInt() ?? 0,
    booked: (body['booked'] as num?)?.toInt() ?? 0,
    remaining: (body['remaining'] as num?)?.toInt() ?? 0,
  );
}

class MemberBooking {
  const MemberBooking({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.facilityCode,
    required this.slot,
    required this.bookingDate,
    required this.status,
    required this.capacityOverride,
  });

  final String id;
  final String facilityId;
  final String facilityName;
  final String facilityCode;
  final FacilitySlot slot;
  final DateTime bookingDate;
  final String status;
  final bool capacityOverride;

  MemberBooking copyWith({String? status}) => MemberBooking(
    id: id,
    facilityId: facilityId,
    facilityName: facilityName,
    facilityCode: facilityCode,
    slot: slot,
    bookingDate: bookingDate,
    status: status ?? this.status,
    capacityOverride: capacityOverride,
  );

  factory MemberBooking.fromJson(Map body) => MemberBooking(
    id: body['id'].toString(),
    facilityId: body['facility_id'].toString(),
    facilityName: body['facility_name']?.toString() ?? 'Facility',
    facilityCode: body['facility_code']?.toString() ?? '',
    slot: FacilitySlot.fromJson(body['slot'] as Map),
    bookingDate: DateTime.parse(body['booking_date'].toString()),
    status: body['status']?.toString() ?? 'booked',
    capacityOverride: body['capacity_override'] == true,
  );
}

class FacilityAccessRequest {
  const FacilityAccessRequest({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.requestType,
    required this.status,
    required this.slotId,
    required this.expiresAt,
    required this.approvalExpiresAt,
    required this.suggestedSlotId,
    required this.resolvedByName,
    required this.resolutionNote,
  });

  final String id;
  final String facilityId;
  final String facilityName;
  final String requestType;
  final String status;
  final String? slotId;
  final DateTime expiresAt;
  final DateTime? approvalExpiresAt;
  final String? suggestedSlotId;
  final String? resolvedByName;
  final String? resolutionNote;

  bool get approved => status == 'approved';
  bool get rejected => status == 'rejected';
  bool get expired => status == 'expired';

  factory FacilityAccessRequest.fromJson(Map body) => FacilityAccessRequest(
    id: body['id'].toString(),
    facilityId: body['facility_id'].toString(),
    facilityName: body['facility_name']?.toString() ?? 'Facility',
    requestType: body['request_type']?.toString() ?? '',
    status: body['status']?.toString() ?? 'pending',
    slotId: body['slot_id']?.toString(),
    expiresAt:
        DateTime.tryParse(body['expires_at']?.toString() ?? '') ??
        DateTime.now(),
    approvalExpiresAt: DateTime.tryParse(
      body['approval_expires_at']?.toString() ?? '',
    ),
    suggestedSlotId: body['suggested_slot_id']?.toString(),
    resolvedByName: body['resolved_by_name']?.toString(),
    resolutionNote: body['resolution_note']?.toString(),
  );
}

class WorkoutReport {
  const WorkoutReport({
    required this.id,
    required this.status,
    required this.sessionId,
    required this.facilityId,
    required this.facilityName,
    required this.checkInAt,
    required this.checkOutAt,
    required this.durationMin,
    required this.planSnapshot,
    required this.completedItemIds,
    required this.intensity,
    required this.completionPct,
    this.calories,
    this.summary,
    this.recoveryNote,
    this.generatedAt,
    this.retryCount = 0,
    this.nextAttemptAt,
    this.selfFeedback,
  });

  final String id;
  final String status;
  final String sessionId;
  final String facilityId;
  final String facilityName;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final int? durationMin;
  final List<Map<String, dynamic>> planSnapshot;
  final List<String> completedItemIds;
  final int? calories;
  final String? intensity;
  final double? completionPct;
  final String? summary;
  final String? recoveryNote;
  final DateTime? generatedAt;
  final int retryCount;
  final DateTime? nextAttemptAt;
  final WorkoutSelfFeedbackSummary? selfFeedback;

  bool get isComplete => status == 'complete';
  bool get isPreparing => status == 'pending' || status == 'generating';
  bool get hasRetryScheduled => status == 'failed' && nextAttemptAt != null;

  factory WorkoutReport.fromJson(Map body) => WorkoutReport(
    id: body['id'].toString(),
    status: body['status']?.toString() ?? 'pending',
    sessionId: body['session_id']?.toString() ?? '',
    facilityId: body['facility_id']?.toString() ?? '',
    facilityName: body['facility_name']?.toString() ?? 'Facility workout',
    checkInAt: DateTime.tryParse(body['check_in_at']?.toString() ?? ''),
    checkOutAt: DateTime.tryParse(body['check_out_at']?.toString() ?? ''),
    durationMin: (body['duration_min'] as num?)?.toInt(),
    planSnapshot: (body['plan_snapshot'] as List? ?? [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false),
    completedItemIds: (body['completed_item_ids'] as List? ?? [])
        .map((item) => item.toString())
        .toList(growable: false),
    calories: (body['ai_estimated_calories'] as num?)?.toInt(),
    intensity: body['ai_intensity']?.toString(),
    completionPct: (body['completion_pct'] as num?)?.toDouble(),
    summary: body['summary']?.toString(),
    recoveryNote: body['recovery_note']?.toString(),
    generatedAt: DateTime.tryParse(body['generated_at']?.toString() ?? ''),
    retryCount: (body['retry_count'] as num?)?.toInt() ?? 0,
    nextAttemptAt: DateTime.tryParse(body['next_attempt_at']?.toString() ?? ''),
    selfFeedback: body['self_feedback'] is Map
        ? WorkoutSelfFeedbackSummary.fromJson(body['self_feedback'] as Map)
        : null,
  );
}

class WorkoutSelfFeedbackSummary {
  const WorkoutSelfFeedbackSummary({
    required this.status,
    this.workoutQuality,
    this.postWorkoutFeeling,
    this.painPresent,
    this.painSeverity,
    this.painBodyAreas = const [],
    this.painNote,
    this.perceivedProgress,
    this.note,
  });

  final String status;
  final int? workoutQuality;
  final String? postWorkoutFeeling;
  final bool? painPresent;
  final int? painSeverity;
  final List<String> painBodyAreas;
  final String? painNote;
  final String? perceivedProgress;
  final String? note;

  factory WorkoutSelfFeedbackSummary.fromJson(Map body) =>
      WorkoutSelfFeedbackSummary(
        status: body['status']?.toString() ?? 'pending',
        workoutQuality: (body['workout_quality'] as num?)?.toInt(),
        postWorkoutFeeling: body['post_workout_feeling']?.toString(),
        painPresent: body['pain_present'] as bool?,
        painSeverity: (body['pain_severity'] as num?)?.toInt(),
        painBodyAreas: (body['pain_body_areas'] as List? ?? [])
            .map((item) => item.toString())
            .toList(growable: false),
        painNote: body['pain_note']?.toString(),
        perceivedProgress: body['perceived_progress']?.toString(),
        note: body['note']?.toString(),
      );
}

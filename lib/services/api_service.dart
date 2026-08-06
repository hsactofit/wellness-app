import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../screens/challenges_screen.dart';

class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  /// Helper to get authorization headers.
  Future<Map<String, String>> _getHeaders({String? token}) async {
    final t = token ?? await AuthService.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  /// Helper to make authenticated GET requests with automatic token refresh.
  Future<http.Response> _get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final token = await AuthService.instance.getAccessToken();
    Uri uri = AuthService.apiUrl(path);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    var response = await http.get(
      uri,
      headers: await _getHeaders(token: token),
    );

    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      final newToken = await AuthService.instance.getAccessToken();
      response = await http.get(
        uri,
        headers: await _getHeaders(token: newToken),
      );
    }
    return response;
  }

  /// Helper to make authenticated POST requests with automatic token refresh.
  Future<http.Response> _post(String path, {Object? body}) async {
    final token = await AuthService.instance.getAccessToken();
    final uri = AuthService.apiUrl(path);

    var response = await http.post(
      uri,
      headers: await _getHeaders(token: token),
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      final newToken = await AuthService.instance.getAccessToken();
      response = await http.post(
        uri,
        headers: await _getHeaders(token: newToken),
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return response;
  }

  /// Helper to make authenticated PUT requests with automatic token refresh.
  Future<http.Response> _put(String path, {Object? body}) async {
    final token = await AuthService.instance.getAccessToken();
    final uri = AuthService.apiUrl(path);

    var response = await http.put(
      uri,
      headers: await _getHeaders(token: token),
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      final newToken = await AuthService.instance.getAccessToken();
      response = await http.put(
        uri,
        headers: await _getHeaders(token: newToken),
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return response;
  }

  /// Helper to make authenticated DELETE requests with automatic token refresh.
  Future<http.Response> _delete(String path) async {
    final token = await AuthService.instance.getAccessToken();
    final uri = AuthService.apiUrl(path);

    var response = await http.delete(
      uri,
      headers: await _getHeaders(token: token),
    );

    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      final newToken = await AuthService.instance.getAccessToken();
      response = await http.delete(
        uri,
        headers: await _getHeaders(token: newToken),
      );
    }
    return response;
  }

  /// Registers (or reassigns) this device's FCM token with the backend so
  /// staff broadcasts can reach it as a real push notification, not just
  /// the in-app feed. Safe to call on every app start / after login —
  /// the backend upserts by token, so re-registering the same token is a
  /// no-op beyond refreshing `updated_at`.
  Future<void> registerDeviceToken(String fcmToken, String platform) async {
    final response = await _post(
      '/api/notifications/device-token',
      body: {'fcm_token': fcmToken, 'platform': platform},
    );
    if (response.statusCode != 201) {
      throw Exception(
        "Failed to register device token: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// Returns the signed-in member's notification feed, newest first.
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final response = await _get('/api/notifications');
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load notifications: ${response.statusCode} - ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected notifications response format');
    }
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  /// Marks one notification delivery as read for the signed-in member.
  Future<void> markNotificationRead(String deliveryId) async {
    final response = await _post('/api/notifications/$deliveryId/read');
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark notification read: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Fetch the signed-in user's email (onboarding data → prefs → Firebase).
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonStr = prefs.getString('onboarding_data');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> onboarding = jsonDecode(jsonStr);
        final email = onboarding['auth']?['email']?.toString().trim();
        if (email != null && email.isNotEmpty) {
          return email;
        }
      } catch (_) {}
    }

    final storedEmail = prefs.getString('user_email')?.trim();
    if (storedEmail != null && storedEmail.isNotEmpty) {
      return storedEmail;
    }

    final firebaseEmail = AuthService.instance.currentUser?.email?.trim();
    if (firebaseEmail != null && firebaseEmail.isNotEmpty) {
      return firebaseEmail;
    }

    throw Exception('User email not found. Please sign in again.');
  }

  /// GET /api/health/goals
  Future<Map<String, dynamic>> fetchGoals() async {
    final response = await _get('/api/health/goals');
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load goals: ${response.statusCode}");
    }
  }

  /// GET /api/health/graph — member is identified by the Bearer token, not
  /// an email path segment; `email` is kept as a parameter (unused) so
  /// existing call sites don't need to change.
  Future<Map<String, dynamic>> fetchGraphData({
    required String email,
    required String metric,
    required String period,
    required String title,
  }) async {
    // Normalize metric param to one of wellness-server's 6 canonical names.
    const aliasMap = {
      'fitness': 'workouts',
      'sleep_duration_hours': 'sleep',
      'water_intake_ml': 'water',
      'workouts_count': 'workouts',
      'heart_rate_bpm': 'heart_rate',
    };
    String metricParam = metric.toLowerCase();
    metricParam = aliasMap[metricParam] ?? metricParam;

    const validMetrics = [
      'steps',
      'calories',
      'sleep',
      'water',
      'workouts',
      'heart_rate',
    ];
    if (!validMetrics.contains(metricParam)) {
      final titleLower = title.toLowerCase();
      if (titleLower.contains('step')) {
        metricParam = 'steps';
      } else if (titleLower.contains('water') ||
          titleLower.contains('hydrat')) {
        metricParam = 'water';
      } else if (titleLower.contains('sleep')) {
        metricParam = 'sleep';
      } else if (titleLower.contains('calor') || titleLower.contains('burn')) {
        metricParam = 'calories';
      } else if (titleLower.contains('workout') ||
          titleLower.contains('gym') ||
          titleLower.contains('exercis')) {
        metricParam = 'workouts';
      } else if (titleLower.contains('heart') || titleLower.contains('pulse')) {
        metricParam = 'heart_rate';
      } else {
        metricParam = 'steps';
      }
    }

    const validPeriods = ['days', 'weeks', 'month'];
    final periodParam = validPeriods.contains(period) ? period : 'days';

    final response = await _get(
      '/api/health/graph',
      queryParams: {'metric': metricParam, 'period': periodParam},
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load graph data: ${response.statusCode}");
    }
  }

  /// GET /api/challenges (Active & Joined challenges)
  Future<List<Challenge>> fetchActiveChallenges() async {
    final response = await _get('/api/challenges');
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      final parsed = list.map((item) => Challenge.fromJson(item)).toList();
      return parsed.where((c) => c.joined).toList();
    } else {
      throw Exception("Failed to fetch challenges: ${response.statusCode}");
    }
  }

  // ── Hydration / Water API ──────────────────────────────────────
  //
  // wellness-server identifies the member from the Bearer token, not an
  // email path segment, and log IDs are UUID strings, not ints. `email` is
  // kept as a parameter (unused) so call sites in the screens don't need to
  // change yet — only this file's routing does.
  //
  // NOT fixed here (needs the calling screen's request-body keys checked,
  // which this pass didn't read): wellness-server's WaterLogIn/WaterLogRead
  // use `amount_ml`, not `amount` — if water_logging_screen.dart builds
  // `{'amount': ...}` bodies or reads `decoded['amount']`, those will come
  // back null/absent until reconciled. See medifit-kb/MEDIFIT_KB.md §5/§6.

  /// GET /water/logs (current member, via Bearer token)
  Future<Map<String, dynamic>> fetchWaterLogs(String email) async {
    final response = await _get('/api/water/logs');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw Exception('Unexpected water logs response format');
    }
    throw Exception(
      "Failed to load water logs: ${response.statusCode} - ${response.body}",
    );
  }

  /// POST /water/log — body must use wellness-server's field names:
  /// { amount_ml: int, timestamp?: ISO date-time }
  Future<Map<String, dynamic>> addWaterLog(
    String email,
    Map<String, dynamic> body,
  ) async {
    final response = await _post('/api/water/log', body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw Exception('Unexpected add water log response format');
    }
    throw Exception(
      "Failed to add water log: ${response.statusCode} - ${response.body}",
    );
  }

  /// PUT /water/log/{logId} — logId is a UUID string on wellness-server.
  Future<Map<String, dynamic>> updateWaterLog(
    String logId,
    Map<String, dynamic> body,
  ) async {
    final response = await _put('/api/water/log/$logId', body: body);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw Exception('Unexpected update water log response format');
    }
    throw Exception(
      "Failed to update water log: ${response.statusCode} - ${response.body}",
    );
  }

  /// DELETE /water/log/{logId} — logId is a UUID string on wellness-server.
  Future<void> deleteWaterLog(String logId) async {
    final response = await _delete('/api/water/log/$logId');

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete water log: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// GET /water/graph?period= (current member, via Bearer token)
  /// period: day | week | month
  Future<Map<String, dynamic>> fetchWaterGraph(
    String email,
    String period,
  ) async {
    final periodParam = switch (period.toLowerCase()) {
      'days' || 'daily' => 'day',
      'weeks' || 'weekly' => 'week',
      'months' || 'monthly' => 'month',
      _ => period.toLowerCase(),
    };

    final response = await _get(
      '/api/water/graph',
      queryParams: {'period': periodParam},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      if (decoded is List) {
        return {'period': periodParam, 'data': decoded};
      }
      throw Exception('Unexpected water graph response format');
    }
    throw Exception(
      "Failed to load water graph: ${response.statusCode} - ${response.body}",
    );
  }

  // ── Nutrition API ──────────────────────────────────────────────
  //
  // Same routing note as water above: member comes from the Bearer token,
  // not an email path segment; `email` param kept but unused so screen call
  // sites don't need to change.

  /// GET /nutrition/logs (current member). Response is a bare JSON array on
  /// wellness-server, not an object — wrapped here so callers built against
  /// the old object-shaped response keep working.
  Future<Map<String, dynamic>> fetchNutritionLogs(String email) async {
    final response = await _get('/api/nutrition/logs');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return {'logs': decoded};
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw Exception('Unexpected nutrition logs response format');
    } else {
      throw Exception(
        "Failed to load nutrition logs: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// POST /nutrition/log — body must use wellness-server's field names:
  /// { food: string, calories?: int, macros?: {protein, carbs, fats, fiber} }
  Future<Map<String, dynamic>> addNutritionLog(
    String email,
    Map<String, dynamic> body,
  ) async {
    final response = await _post('/api/nutrition/log', body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
        "Failed to add nutrition log: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// NOT IMPLEMENTED on wellness-server — there is no PUT endpoint for meal
  /// logs yet (see medifit-kb/MEDIFIT_KB.md §3). Left in place so callers
  /// compile, but this will always fail until that endpoint exists.
  Future<Map<String, dynamic>> updateNutritionLog(
    String logId,
    Map<String, dynamic> body,
  ) async {
    throw Exception(
      'Updating a nutrition log is not supported by the backend yet.',
    );
  }

  /// DELETE /nutrition/log/{logId} — logId is a UUID string on wellness-server.
  Future<void> deleteNutritionLog(String logId) async {
    final response = await _delete('/api/nutrition/log/$logId');

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete nutrition log: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// NOT IMPLEMENTED on wellness-server — there is no nutrition trend/graph
  /// endpoint yet (see medifit-kb/MEDIFIT_KB.md §3). Left in place so
  /// callers compile, but this will always fail until that endpoint exists.
  Future<Map<String, dynamic>> fetchNutritionGraph(
    String email,
    String period,
  ) async {
    throw Exception(
      'Nutrition trend graphs are not supported by the backend yet.',
    );
  }

  /// GET /api/profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await _get('/api/profile');
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load user profile: ${response.statusCode}");
    }
  }

  /// PUT /api/profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> body,
  ) async {
    final response = await _put('/api/profile', body: body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update user profile: ${response.statusCode}");
    }
  }

  /// wellness-server splits what the old prototype backend did in one call
  /// (`POST /api/dashboard/sync/{email}` — upload + return the scored
  /// dashboard) into two: `POST /health/sync` (ingest only, member from the
  /// Bearer token) and `GET /health/dashboard` (the actual score/summary/
  /// recommendations). Rather than touch every call site in
  /// dashboard_screen.dart, this method does both calls internally and
  /// returns the dashboard payload — so `syncDashboard(...)` still behaves
  /// like one combined "upload and get me the scored dashboard back" call.
  ///
  /// `dailyRecords` must already be shaped like wellness-server's
  /// DailyHealthRecordIn per entry: {date, steps, calories,
  /// sleep_duration_hours, workouts_count, heart_rate_bpm}. Extra fields
  /// (e.g. water_intake_ml, carried over from the old backend's per-day
  /// shape) are harmless — the server ignores unknown keys.
  Future<Map<String, dynamic>> syncDashboard(
    String email,
    List<Map<String, dynamic>> dailyRecords,
  ) async {
    final syncResponse = await _post(
      '/api/health/sync',
      body: {'records': dailyRecords},
    );
    if (syncResponse.statusCode != 200) {
      throw Exception(
        "Failed to sync dashboard: ${syncResponse.statusCode} - ${syncResponse.body}",
      );
    }
    return getDashboard(email);
  }

  /// GET /health/dashboard (current member, via Bearer token).
  Future<Map<String, dynamic>> getDashboard(String email) async {
    final response = await _get('/api/health/dashboard');
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
        "Failed to get dashboard: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // ── Mental Wellness API ────────────────────────────────────────

  /// POST /api/mind/checkin
  Future<Map<String, dynamic>> submitMoodCheckin({
    required int moodScore,
    required int stressScore,
    required bool anonymous,
  }) async {
    final response = await _post(
      '/api/mind/checkin',
      body: {
        'mood_score': moodScore,
        'stress_score': stressScore,
        'anonymous': anonymous,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception(
      "Failed to submit mood check-in: ${response.statusCode} - ${response.body}",
    );
  }

  // ── SOS & Emergency API ────────────────────────────────────────
  // wellness-server identifies the caller via the Bearer token, not an
  // {email} path segment (the old prototype backend's convention) — every
  // path below matches app/api/v1/sos.py exactly. Emergency numbers are
  // fixed India defaults server-side (no per-member override column
  // exists), so there is no update/reset call here — the old edit/reset UI
  // was removed from sos_screen.dart rather than left pointing at an
  // endpoint that was never real.

  /// Combines GET /api/sos/contacts + GET /api/sos/emergency-numbers into
  /// the {contacts, emergency_numbers} shape the SOS screen expects.
  Future<Map<String, dynamic>> getSos() async {
    final contactsRes = await _get('/api/sos/contacts');
    if (contactsRes.statusCode != 200) {
      throw Exception(
        "Failed to load SOS contacts: ${contactsRes.statusCode} - ${contactsRes.body}",
      );
    }
    final numbersRes = await _get('/api/sos/emergency-numbers');
    if (numbersRes.statusCode != 200) {
      throw Exception(
        "Failed to load emergency numbers: ${numbersRes.statusCode} - ${numbersRes.body}",
      );
    }
    return {
      'contacts': jsonDecode(contactsRes.body),
      'emergency_numbers': jsonDecode(numbersRes.body),
    };
  }

  /// POST /api/sos/contacts
  Future<Map<String, dynamic>> createSosContact(
    Map<String, dynamic> body,
  ) async {
    final response = await _post('/api/sos/contacts', body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
        "Failed to create SOS contact: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// PUT /api/sos/contacts/{contactId}
  Future<Map<String, dynamic>> updateSosContact(
    String contactId,
    Map<String, dynamic> body,
  ) async {
    final response = await _put('/api/sos/contacts/$contactId', body: body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
        "Failed to update SOS contact: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// DELETE /api/sos/contacts/{contactId}
  Future<void> deleteSosContact(String contactId) async {
    final response = await _delete('/api/sos/contacts/$contactId');

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete SOS contact: ${response.statusCode} - ${response.body}",
      );
    }
  }

  /// POST /api/sos/trigger — real GPS coordinates are captured in
  /// sos_screen.dart before calling this, so the Emergency Response Lead's
  /// dashboard can show exactly where the member is.
  Future<Map<String, dynamic>> triggerSos({
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
    final response = await _post('/api/sos/trigger', body: body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception(
        "Failed to trigger SOS: ${response.statusCode} - ${response.body}",
      );
    }
  }

  // ── AI (nutrition/workout plan generation, chat) ─────────────────
  //
  // Member is identified by the Bearer token throughout — no email path
  // segments. Errors surface the backend's real `detail` message (e.g. a
  // rate-limit cooldown or "AI features are not configured") instead of a
  // generic failure string, so the UI can show it directly.

  String _aiErrorDetail(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {
      // fall through to generic message below
    }
    return "Request failed (${response.statusCode})";
  }

  /// GET /api/ai/nutrition-plan/latest — null if none generated yet.
  Future<Map<String, dynamic>?> getLatestNutritionPlan() async {
    final response = await _get('/api/ai/nutrition-plan/latest');
    if (response.statusCode == 200) {
      if (response.body.trim() == 'null') return null;
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception(_aiErrorDetail(response));
  }

  /// POST /api/ai/nutrition-plan/generate — throws with the real backend
  /// message on 429 (cooldown) / 503 (not configured) / 502 (AI failure).
  Future<Map<String, dynamic>> generateNutritionPlan(
    Map<String, dynamic> body,
  ) async {
    final response = await _post('/api/ai/nutrition-plan/generate', body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception(_aiErrorDetail(response));
  }

  /// GET /api/ai/workout-plan/latest — null if none generated yet.
  Future<Map<String, dynamic>?> getLatestWorkoutPlan() async {
    final response = await _get('/api/ai/workout-plan/latest');
    if (response.statusCode == 200) {
      if (response.body.trim() == 'null') return null;
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception(_aiErrorDetail(response));
  }

  /// POST /api/ai/workout-plan/generate
  Future<Map<String, dynamic>> generateWorkoutPlan(
    Map<String, dynamic> body,
  ) async {
    final response = await _post('/api/ai/workout-plan/generate', body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception(_aiErrorDetail(response));
  }

  /// POST /api/ai/chat
  Future<Map<String, dynamic>> sendAiChatMessage({
    required String message,
    String? conversationId,
  }) async {
    final response = await _post(
      '/api/ai/chat',
      body: {
        'message': message,
        if (conversationId != null) 'conversation_id': conversationId,
      },
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception(_aiErrorDetail(response));
  }

  /// GET /api/ai/chat/conversations
  Future<List<dynamic>> listAiChatConversations() async {
    final response = await _get('/api/ai/chat/conversations');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception(_aiErrorDetail(response));
  }

  /// GET /api/ai/chat/conversations/{id}
  Future<List<dynamic>> getAiChatConversationMessages(
    String conversationId,
  ) async {
    final response = await _get('/api/ai/chat/conversations/$conversationId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception(_aiErrorDetail(response));
  }
}

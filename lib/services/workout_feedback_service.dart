import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// Server-owned checkout reflection. It is intentionally never cached: a
/// completed response immediately releases the next Gym Access server gate.
class WorkoutFeedbackService {
  WorkoutFeedbackService._();

  static final WorkoutFeedbackService instance = WorkoutFeedbackService._();

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
  }) async {
    final uri = AuthService.apiUrl(path);
    Future<http.Response> request(String? token) {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      return method == 'GET'
          ? http.get(uri, headers: headers)
          : http.put(uri, headers: headers, body: jsonEncode(body));
    }

    var token = await AuthService.instance.getAccessToken();
    var response = await request(token);
    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      token = await AuthService.instance.getAccessToken();
      response = await request(token);
    }
    return response;
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _message(dynamic body, int statusCode) {
    if (body is Map && body['detail'] != null) return body['detail'].toString();
    return 'Workout feedback request failed ($statusCode)';
  }

  Future<WorkoutFeedbackPrompt?> pending() async {
    final response = await _send('GET', '/api/v1/workout-feedback/pending');
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WorkoutFeedbackException(_message(body, response.statusCode));
    }
    return body == null ? null : WorkoutFeedbackPrompt.fromJson(body as Map);
  }

  Future<void> submit(
    WorkoutFeedbackPrompt prompt, {
    required int workoutQuality,
    required String postWorkoutFeeling,
    required bool painPresent,
    int? painSeverity,
    List<String> painBodyAreas = const [],
    String? painNote,
    required String perceivedProgress,
    String? note,
  }) async {
    final response = await _send(
      'PUT',
      '/api/v1/workout-feedback/${prompt.id}',
      body: {
        'workout_quality': workoutQuality,
        'post_workout_feeling': postWorkoutFeeling,
        'pain_present': painPresent,
        if (painPresent) 'pain_severity': painSeverity,
        'pain_body_areas': painPresent ? painBodyAreas : const [],
        if (painPresent && painNote != null && painNote.trim().isNotEmpty)
          'pain_note': painNote.trim(),
        'perceived_progress': perceivedProgress,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WorkoutFeedbackException(_message(body, response.statusCode));
    }
  }
}

class WorkoutFeedbackException implements Exception {
  WorkoutFeedbackException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WorkoutFeedbackPrompt {
  const WorkoutFeedbackPrompt({
    required this.id,
    required this.sourceSessionId,
    required this.facilityName,
  });

  final String id;
  final String sourceSessionId;
  final String facilityName;

  factory WorkoutFeedbackPrompt.fromJson(Map body) => WorkoutFeedbackPrompt(
    id: body['id'].toString(),
    sourceSessionId: body['source_session_id'].toString(),
    facilityName: body['facility_name']?.toString() ?? 'your workout',
  );
}

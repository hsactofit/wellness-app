import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// The one pending first-visit feedback item is server-owned.  This service
/// deliberately does not cache it: a completed submission must immediately
/// release the server-side facility gate on every device.
class FacilityRatingService {
  FacilityRatingService._();

  static final FacilityRatingService instance = FacilityRatingService._();

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

  Future<dynamic> _decode(http.Response response) async {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _message(dynamic body, int code) {
    if (body is Map && body['detail'] != null) return body['detail'].toString();
    return 'Facility feedback request failed ($code)';
  }

  Future<FacilityRatingPrompt?> pending() async {
    final response = await _send('GET', '/api/facility-ratings/pending');
    final body = await _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FacilityRatingException(_message(body, response.statusCode));
    }
    return body == null ? null : FacilityRatingPrompt.fromJson(body as Map);
  }

  Future<void> submit(
    FacilityRatingPrompt prompt, {
    required int overallRating,
    required int serviceRating,
    required int cleanlinessRating,
    required int equipmentRating,
    required int amenitiesRating,
    required String comment,
  }) async {
    final response = await _send(
      'PUT',
      '/api/facility-ratings/${prompt.id}',
      body: {
        'overall_rating': overallRating,
        'service_rating': serviceRating,
        'cleanliness_rating': cleanlinessRating,
        'equipment_rating': equipmentRating,
        'amenities_rating': amenitiesRating,
        'comment': comment.trim(),
      },
    );
    final body = await _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FacilityRatingException(_message(body, response.statusCode));
    }
  }
}

class FacilityRatingException implements Exception {
  FacilityRatingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FacilityRatingPrompt {
  const FacilityRatingPrompt({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.sourceSessionId,
  });

  final String id;
  final String facilityId;
  final String facilityName;
  final String sourceSessionId;

  factory FacilityRatingPrompt.fromJson(Map body) => FacilityRatingPrompt(
    id: body['id'].toString(),
    facilityId: body['facility_id'].toString(),
    facilityName: body['facility_name']?.toString() ?? 'this facility',
    sourceSessionId: body['source_session_id'].toString(),
  );
}

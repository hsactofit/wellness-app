import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/care_program.dart';
import 'auth_service.dart';

class CareProgramException implements Exception {
  const CareProgramException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CareProgramService {
  CareProgramService._();
  static final CareProgramService instance = CareProgramService._();

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(
    String method,
    String path, [
    Object? body,
  ]) async {
    Future<http.Response> send() async {
      final headers = await _headers();
      final encoded = body == null ? null : jsonEncode(body);
      final uri = AuthService.apiUrl(path);
      return method == 'GET'
          ? http.get(uri, headers: headers)
          : http.post(uri, headers: headers, body: encoded);
    }

    var response = await send();
    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      response = await send();
    }
    return response;
  }

  dynamic _expect(http.Response response) {
    final dynamic body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CareProgramException(
        body is Map && body['detail'] != null
            ? body['detail'].toString()
            : 'Care Programs request failed',
      );
    }
    return body;
  }

  Future<CareProgramSummary> fetchMine() async {
    final response = await _send('GET', '/api/care-programs/me');
    return CareProgramSummary.fromJson(
      Map<String, dynamic>.from(_expect(response) as Map),
    );
  }

  Future<void> requestReview({String? reason}) async {
    _expect(
      await _send('POST', '/api/care-programs/me/requests', {'reason': reason}),
    );
  }

  Future<CareProgram> respond(
    String programId, {
    required bool accept,
    String? reason,
  }) async {
    final body = _expect(
      await _send('POST', '/api/care-programs/me/$programId/respond', {
        'response': accept ? 'accept' : 'decline',
        'reason': reason,
      }),
    );
    return CareProgram.fromJson(Map<String, dynamic>.from(body as Map));
  }

  Future<void> withdraw(String programId, {String? reason}) async {
    _expect(
      await _send('POST', '/api/care-programs/me/$programId/withdraw', {
        'reason': reason,
      }),
    );
  }

  Future<void> completeAction(
    String programId,
    String actionKey,
    DateTime day,
  ) async {
    final date =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    _expect(
      await _send(
        'POST',
        '/api/care-programs/me/$programId/actions/$actionKey/complete',
        {'occurrence_date': date},
      ),
    );
  }
}

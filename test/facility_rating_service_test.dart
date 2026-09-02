import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/facility_rating_service.dart';

void main() {
  test('parses the server-owned first-visit rating prompt', () {
    final prompt = FacilityRatingPrompt.fromJson({
      'id': 'rating-1',
      'facility_id': 'facility-1',
      'facility_name': 'Indiranagar Fitness Centre',
      'source_session_id': 'session-1',
    });

    expect(prompt.id, 'rating-1');
    expect(prompt.facilityId, 'facility-1');
    expect(prompt.facilityName, 'Indiranagar Fitness Centre');
    expect(prompt.sourceSessionId, 'session-1');
  });
}

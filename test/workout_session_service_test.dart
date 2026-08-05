import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellnessconnect/services/workout_session_service.dart';

void main() {
  test(
    'new local check-in anchors the hourly reminder instead of an old server time',
    () async {
      SharedPreferences.setMockInitialValues({});
      final beforeCheckIn = DateTime.now();

      await WorkoutSessionService.instance.saveCheckIn(
        session: {
          'id': 'session-1',
          // This represents an already-open server attendance record.
          'check_in_at': '2020-01-01T00:00:00.000Z',
          'facility_name': 'Medifit Gym',
        },
        fallbackFacilityName: 'Medifit Gym',
        fallbackFacilityPlace: 'Bengaluru',
      );

      final prefs = await SharedPreferences.getInstance();
      final localAnchor = DateTime.parse(
        prefs.getString('gym_hourly_prompt_anchor_at')!,
      );

      expect(prefs.getString('gym_check_in_time'), '2020-01-01T00:00:00.000Z');
      expect(
        localAnchor.isAfter(beforeCheckIn.subtract(const Duration(seconds: 1))),
        isTrue,
      );

      await WorkoutSessionService.instance.clearLocalSession();
      expect(prefs.containsKey('gym_hourly_prompt_anchor_at'), isFalse);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
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

  testWidgets(
    'passes the active-session geofence to the native iOS bridge and records its ownership',
    (tester) async {
      const channel = MethodChannel('com.medifit/workout_background');
      Map<dynamic, dynamic>? startArguments;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async {
            if (call.method == 'start') {
              startArguments = Map<dynamic, dynamic>.from(call.arguments as Map);
              return true;
            }
            return null;
        },
      );
      SharedPreferences.setMockInitialValues({});

      try {
        await WorkoutSessionService.instance.saveCheckIn(
          session: {
            'id': 'session-native-geofence',
            'check_in_at': '2026-09-03T10:00:00.000Z',
            'slot_end_at': '2026-09-03T11:00:00.000Z',
            'booking_id': 'booking-1',
            'facility_name': 'Medifit Indiranagar',
            'facility_latitude': 12.9716,
            'facility_longitude': 77.5946,
            'geofence_radius_m': 2000,
          },
          fallbackFacilityName: 'Medifit Indiranagar',
          fallbackFacilityPlace: 'Indiranagar, Bengaluru',
        );

        final prefs = await SharedPreferences.getInstance();
        expect(startArguments?['sessionId'], 'session-native-geofence');
        expect(startArguments?['bookingId'], 'booking-1');
        expect(startArguments?['latitude'], 12.9716);
        expect(startArguments?['longitude'], 77.5946);
        expect(startArguments?['geofenceRadiusMeters'], 2000);
        expect(startArguments?['slotEndAt'], isA<int>());
        expect(prefs.getBool('gym_native_geofence_registered'), isTrue);

        await WorkoutSessionService.instance.clearLocalSession();
        expect(prefs.containsKey('gym_native_geofence_registered'), isFalse);
      } finally {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
      }
    },
  );
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellnessconnect/services/auth_service.dart';
import 'package:wellnessconnect/services/background_workout_service.dart';
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
    'reports an unavailable native timer without blocking the workout bridge',
    (tester) async {
      const channel = MethodChannel('com.medifit/workout_background');
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        return null;
      });

      try {
        final status = await BackgroundWorkoutService.instance
            .showPersistentTimer(
              sessionId: 'session-timer',
              facilityName: 'Medifit Gym',
              checkInAt: DateTime.utc(2026, 9, 4, 9),
            );
        await BackgroundWorkoutService.instance.hidePersistentTimer();

        expect(calls.map((call) => call.method), ['showTimer', 'hideTimer']);
        expect(calls.first.arguments['sessionId'], 'session-timer');
        expect(calls.first.arguments['checkInAt'], isA<int>());
        expect(status, PersistentTimerStatus.active);
      } finally {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
      }
    },
  );

  testWidgets('returns disabled when iOS declines the Live Activity', (
    tester,
  ) async {
    const channel = MethodChannel('com.medifit/workout_background');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      if (call.method == 'showTimer') return 'disabled';
      return null;
    });

    try {
      final status = await BackgroundWorkoutService.instance
          .showPersistentTimer(
            sessionId: 'session-disabled',
            facilityName: 'Medifit Gym',
            checkInAt: DateTime.utc(2026, 9, 4, 9),
          );

      expect(status, PersistentTimerStatus.disabled);
    } finally {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    }
  });

  testWidgets(
    'returns unsupported when the platform has no Live Activity support',
    (tester) async {
      const channel = MethodChannel('com.medifit/workout_background');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'showTimer') return 'unsupported';
        return null;
      });

      try {
        final status = await BackgroundWorkoutService.instance
            .showPersistentTimer(
              sessionId: 'session-unsupported',
              facilityName: 'Medifit Gym',
              checkInAt: DateTime.utc(2026, 9, 4, 9),
            );

        expect(status, PersistentTimerStatus.unsupported);
      } finally {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
      }
    },
  );

  testWidgets(
    'retries an active cached workout timer while the app is foregrounded',
    (tester) async {
      const channel = MethodChannel('com.medifit/workout_background');
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        calls.add(call);
        if (call.method == 'showTimer') return 'failed';
        return null;
      });
      SharedPreferences.setMockInitialValues({
        'gym_checked_in': true,
        'gym_name': 'Medifit Indiranagar',
        'gym_place': 'Indiranagar',
        'gym_check_in_time': '2026-09-04T09:00:00.000Z',
        'gym_session_id': 'session-recovery',
      });

      try {
        final status = await WorkoutSessionService.instance
            .ensurePersistentTimerForActiveSession();

        expect(status, PersistentTimerStatus.failed);
        expect(calls.single.method, 'showTimer');
        expect(calls.single.arguments['sessionId'], 'session-recovery');
      } finally {
        await WorkoutSessionService.instance.clearLocalSession();
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        );
      }
    },
  );

  testWidgets('checkout failure retains the active session and timer', (
    tester,
  ) async {
    const channel = MethodChannel('com.medifit/workout_background');
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    SharedPreferences.setMockInitialValues({
      'gym_checked_in': true,
      'gym_name': 'Medifit Indiranagar',
      'gym_place': 'Indiranagar',
      'gym_check_in_time': '2026-09-04T09:00:00.000Z',
      'gym_session_id': 'session-checkout-failure',
    });
    WorkoutSessionService.instance.setAccessTokenProvider(
      () async => 'test-access-token',
    );
    WorkoutSessionService.instance.setHttpClient(
      MockClient(
        (request) async => http.Response(
          jsonEncode({'detail': 'Checkout is temporarily unavailable.'}),
          503,
        ),
      ),
    );

    try {
      await expectLater(
        WorkoutSessionService.instance.checkout(),
        throwsA(isA<WorkoutSessionException>()),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('gym_checked_in'), isTrue);
      expect(calls.where((call) => call.method == 'stop'), isEmpty);
    } finally {
      await WorkoutSessionService.instance.clearLocalSession();
      WorkoutSessionService.instance.setHttpClient(http.Client());
      WorkoutSessionService.instance.setAccessTokenProvider(
        () => AuthService.instance.getAccessToken(),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    }
  });

  testWidgets('successful checkout clears the session and ends the timer', (
    tester,
  ) async {
    const channel = MethodChannel('com.medifit/workout_background');
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    SharedPreferences.setMockInitialValues({
      'gym_checked_in': true,
      'gym_name': 'Medifit Indiranagar',
      'gym_place': 'Indiranagar',
      'gym_check_in_time': '2026-09-04T09:00:00.000Z',
      'gym_session_id': 'session-checkout-success',
    });
    WorkoutSessionService.instance.setAccessTokenProvider(
      () async => 'test-access-token',
    );
    WorkoutSessionService.instance.setHttpClient(
      MockClient(
        (request) async => http.Response(
          jsonEncode({'check_out_at': '2026-09-04T10:30:00.000Z'}),
          200,
        ),
      ),
    );

    try {
      final result = await WorkoutSessionService.instance.checkout();

      final prefs = await SharedPreferences.getInstance();
      expect(result.checkOutAt, DateTime.utc(2026, 9, 4, 10, 30));
      expect(prefs.getBool('gym_checked_in'), isNull);
      expect(calls.where((call) => call.method == 'stop'), hasLength(1));
    } finally {
      await WorkoutSessionService.instance.clearLocalSession();
      WorkoutSessionService.instance.setHttpClient(http.Client());
      WorkoutSessionService.instance.setAccessTokenProvider(
        () => AuthService.instance.getAccessToken(),
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    }
  });

  testWidgets(
    'passes the active-session geofence to the native iOS bridge and records its ownership',
    (tester) async {
      const channel = MethodChannel('com.medifit/workout_background');
      Map<dynamic, dynamic>? startArguments;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        if (call.method == 'start') {
          startArguments = Map<dynamic, dynamic>.from(call.arguments as Map);
          return true;
        }
        return null;
      });
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
        expect(startArguments?['showPersistentTimer'], isTrue);
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

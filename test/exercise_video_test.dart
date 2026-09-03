import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellnessconnect/services/exercise_video_service.dart';
import 'package:wellnessconnect/services/workout_session_service.dart';
import 'package:wellnessconnect/widgets/exercise_video_tile.dart';

void main() {
  test('exerciseVideoId only returns trainer-linked catalog ids', () {
    expect(exerciseVideoId({'name': 'Push Up'}), isNull);
    expect(exerciseVideoId({'name': 'Push Up', 'video_id': ''}), isNull);
    expect(
      exerciseVideoId({
        'name': 'Push Up',
        'video_id': '7e2c9f10-4b6a-4d31-9c55-0f3a8d21e6b7',
      }),
      '7e2c9f10-4b6a-4d31-9c55-0f3a8d21e6b7',
    );
  });

  test('only exposes trainer-linked exercises in the video list', () {
    final exercises = exercisesWithDemonstrationVideos([
      {'name': 'Warm-up'},
      {'name': 'Push Up', 'video_id': '7e2c9f10-4b6a-4d31-9c55-0f3a8d21e6b7'},
      {'name': 'Cool-down', 'video_id': ''},
    ]);

    expect(exercises, hasLength(1));
    expect(exercises.single['name'], 'Push Up');
  });

  testWidgets('exercise video tile is tappable and shows a play control', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExerciseVideoTile(
            name: 'Push Up',
            details: '3 sets · 12 reps',
            onOpen: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Push Up'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    await tester.tap(find.text('Push Up'));
    expect(opened, isTrue);
  });

  test(
    'active session recovery keeps the frozen demonstration video id',
    () async {
      SharedPreferences.setMockInitialValues({});
      await WorkoutSessionService.instance.saveCheckIn(
        session: {
          'id': 'session-video',
          'check_in_at': '2026-09-03T10:00:00.000Z',
          'facility_name': 'Medifit Indiranagar',
          'plan_snapshot': [
            {
              'id': 'exercise-1',
              'name': 'Push Up',
              'sets': 3,
              'video_id': '11111111-1111-1111-1111-111111111111',
              'video_title': 'Push Up',
            },
          ],
        },
        fallbackFacilityName: 'Medifit Indiranagar',
        fallbackFacilityPlace: 'Bengaluru',
      );

      final session = await WorkoutSessionService.instance.loadActiveSession();
      expect(session, isNotNull);
      expect(session!.planSnapshot, isNotEmpty);
      expect(
        exerciseVideoId(session.planSnapshot.first),
        '11111111-1111-1111-1111-111111111111',
      );
      await WorkoutSessionService.instance.clearLocalSession();
    },
  );

  test(
    'temporary video cache evicts older files when over the size cap',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'medifit_video_cache',
      );
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });
      final cache = ExerciseVideoCache(directory: directory, maxBytes: 12);
      await cache.store('old', List<int>.filled(8, 1));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await cache.store('keep', List<int>.filled(8, 2));

      expect(await cache.cachedFile('old'), isNull);
      expect(await cache.cachedFile('keep'), isNotNull);
    },
  );
}

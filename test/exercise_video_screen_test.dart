import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/exercise_video_screen.dart';

void main() {
  group('exercise video seeking', () {
    test('rewind is clamped to the beginning', () {
      expect(
        exerciseVideoSeekTarget(
          position: const Duration(seconds: 4),
          duration: const Duration(minutes: 1),
          offset: const Duration(seconds: -10),
        ),
        Duration.zero,
      );
    });

    test('forward is clamped to the end', () {
      expect(
        exerciseVideoSeekTarget(
          position: const Duration(seconds: 56),
          duration: const Duration(minutes: 1),
          offset: const Duration(seconds: 10),
        ),
        const Duration(minutes: 1),
      );
    });

    test('seek moves ten seconds within the video bounds', () {
      expect(
        exerciseVideoSeekTarget(
          position: const Duration(seconds: 25),
          duration: const Duration(minutes: 1),
          offset: const Duration(seconds: 10),
        ),
        const Duration(seconds: 35),
      );
    });
  });

  testWidgets('playback controls expose rewind, pause, and forward actions', (
    tester,
  ) async {
    var rewindCount = 0;
    var toggleCount = 0;
    var forwardCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ExerciseVideoPlaybackControls(
              isPlaying: true,
              isComplete: false,
              onRewind: () => rewindCount += 1,
              onTogglePlayback: () => toggleCount += 1,
              onForward: () => forwardCount += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle), findsOneWidget);
    expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);

    await tester.tap(find.byTooltip('Rewind 10 seconds'));
    await tester.tap(find.byTooltip('Pause'));
    await tester.tap(find.byTooltip('Forward 10 seconds'));

    expect(rewindCount, 1);
    expect(toggleCount, 1);
    expect(forwardCount, 1);
  });
}

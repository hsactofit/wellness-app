import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellnessconnect/screens/exercise_library_screen.dart';
import 'package:wellnessconnect/services/exercise_video_service.dart';

const _videos = [
  ExerciseVideoLibraryItem(
    id: 'push-up',
    title: 'Push Up',
    topics: ['Upper Body', 'Chest', 'Arms'],
    durationSec: 75,
    sortOrder: 1,
  ),
  ExerciseVideoLibraryItem(
    id: 'plank',
    title: 'Plank',
    topics: ['Core'],
    durationSec: null,
    sortOrder: 2,
  ),
];

void main() {
  test('library search matches titles, topics, and casing', () {
    expect(filterExerciseVideoLibrary(_videos, query: 'push'), hasLength(1));
    expect(filterExerciseVideoLibrary(_videos, query: 'CHEST'), hasLength(1));
    expect(filterExerciseVideoLibrary(_videos, topic: 'Core'), [_videos[1]]);
  });

  test('catalog metadata is available after a successful local save', () async {
    SharedPreferences.setMockInitialValues({});

    await ExerciseVideoLibraryStore.save(_videos);

    expect(await ExerciseVideoLibraryStore.load(), hasLength(2));
  });

  testWidgets('library filters and opens the selected video', (tester) async {
    SharedPreferences.setMockInitialValues({});
    String? openedVideoId;
    await tester.pumpWidget(
      MaterialApp(
        home: ExerciseLibraryScreen(
          libraryLoader: () async => _videos,
          onOpenVideo: (video) => openedVideoId = video.id,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exercise Library'), findsOneWidget);
    expect(find.text('2 videos'), findsOneWidget);
    expect(find.text('Push Up'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'core');
    await tester.pump();
    expect(find.text('Push Up'), findsNothing);
    expect(find.text('Plank'), findsOneWidget);

    await tester.tap(find.text('Plank'));
    expect(openedVideoId, 'plank');
  });

  testWidgets('library clears a selected topic filter', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: ExerciseLibraryScreen(libraryLoader: () async => _videos),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Core'));
    await tester.pump();
    expect(find.text('Push Up'), findsNothing);
    expect(find.text('Plank'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All topics'));
    await tester.pump();
    expect(find.text('Push Up'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/workout_muscle_map.dart';

void main() {
  testWidgets('renders only the requested muscle group in Medifit red', (
    tester,
  ) async {
    const mapKey = Key('core-muscle-map');
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6D55),
            onPrimary: Color(0xFF0A0D10),
            surface: Color(0xFF0F1318),
            onSurface: Color(0xFFF8F7F5),
            onSurfaceVariant: Color(0xFFC9C2BE),
            outlineVariant: Color(0xFF5A5050),
          ),
        ),
        home: Scaffold(
          body: ColoredBox(
            color: Color(0xFF0A0D10),
            child: SingleChildScrollView(
              child: SizedBox(
                width: 390,
                child: RepaintBoundary(
                  key: mapKey,
                  child: WorkoutMuscleMapCard(targetMuscles: ['core']),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    await expectLater(
      find.byKey(mapKey),
      matchesGoldenFile('goldens/workout_muscle_map_core_dark.png'),
    );
  });

  testWidgets('switches to the detailed back view for a triceps target', (
    tester,
  ) async {
    const mapKey = Key('triceps-muscle-map');
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6D55),
            onPrimary: Color(0xFF0A0D10),
            surface: Color(0xFF0F1318),
            onSurface: Color(0xFFF8F7F5),
            onSurfaceVariant: Color(0xFFC9C2BE),
            outlineVariant: Color(0xFF5A5050),
          ),
        ),
        home: Scaffold(
          body: ColoredBox(
            color: Color(0xFF0A0D10),
            child: SingleChildScrollView(
              child: SizedBox(
                width: 390,
                child: RepaintBoundary(
                  key: mapKey,
                  child: WorkoutMuscleMapCard(
                    targetMuscles: ['biceps', 'triceps'],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Triceps'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('Triceps · back upper arms'), findsOneWidget);

    await expectLater(
      find.byKey(mapKey),
      matchesGoldenFile('goldens/workout_muscle_map_triceps_dark.png'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/workout_muscle_map.dart';

void main() {
  testWidgets('renders only the requested muscle group in Medifit red', (
    tester,
  ) async {
    const mapKey = Key('core-muscle-map');
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
        home: const Scaffold(
          body: ColoredBox(
            color: Color(0xFF0A0D10),
            child: Center(
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

    await expectLater(
      find.byKey(mapKey),
      matchesGoldenFile('goldens/workout_muscle_map_core_dark.png'),
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/blood_pressure_tracker_screen.dart';

void main() {
  testWidgets('shows a dedicated manual blood-pressure tracker', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BloodPressureTrackerScreen(loadReadings: () async => []),
      ),
    );

    expect(find.text('Blood Pressure Tracker'), findsOneWidget);
    expect(find.text('Systolic'), findsOneWidget);
    expect(find.text('Diastolic'), findsOneWidget);
    expect(find.text('Save reading'), findsOneWidget);
    expect(find.textContaining('Start 30-second scan'), findsNothing);
  });

  testWidgets('validates and saves the entered cuff reading', (tester) async {
    double? savedSystolic;
    double? savedDiastolic;
    await tester.pumpWidget(
      MaterialApp(
        home: BloodPressureTrackerScreen(
          loadReadings: () async => [],
          saveReading: (systolic, diastolic) async {
            savedSystolic = systolic;
            savedDiastolic = diastolic;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), '120');
    await tester.enterText(find.byType(TextFormField).at(1), '80');
    await tester.tap(find.text('Save reading'));
    await tester.pump();

    expect(savedSystolic, 120);
    expect(savedDiastolic, 80);
    expect(find.text('Blood pressure reading saved.'), findsOneWidget);
  });
}

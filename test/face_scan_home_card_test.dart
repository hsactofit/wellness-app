import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/widgets/face_scan_home_card.dart';

void main() {
  testWidgets('offers a full Face Scan action instead of a quick-access tile', (
    tester,
  ) async {
    var started = false;
    var openedReports = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FaceScanHomeCard(
            onStartScan: () => started = true,
            onViewReports: () => openedReports = true,
          ),
        ),
      ),
    );

    expect(find.text('QUICK ACCESS'), findsNothing);
    expect(find.text('Check your vitals'), findsOneWidget);
    expect(find.text('Start Face Scan'), findsOneWidget);
    expect(find.text('View past reports'), findsOneWidget);
    expect(find.text('Heart rate'), findsOneWidget);
    expect(find.text('Breathing'), findsOneWidget);

    await tester.tap(find.text('Start Face Scan'));
    await tester.tap(find.text('View past reports'));
    expect(started, isTrue);
    expect(openedReports, isTrue);
  });
}

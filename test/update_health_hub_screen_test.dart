import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/app_brand.dart';
import 'package:wellnessconnect/screens/body_composition_reports_screen.dart';
import 'package:wellnessconnect/screens/update_health_hub_screen.dart';

void main() {
  testWidgets(
    'shows the four approved import and comparison actions plus the report library',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: UpdateHealthHubScreen()));

      expect(find.text('Scan Report'), findsOneWidget);
      expect(find.text('Import PDF'), findsOneWidget);
      expect(find.text('Import Screenshot'), findsOneWidget);
      expect(find.text('Compare Reports'), findsOneWidget);
      expect(
        find.byType(ListTile),
        findsNWidgets(AppBrand.faceScanEnabled ? 6 : 4),
      );
      expect(
        find.text('Face Scan'),
        AppBrand.faceScanEnabled ? findsOneWidget : findsNothing,
      );
      expect(find.byTooltip('Report Library'), findsOneWidget);
    },
  );

  testWidgets('adds Face Scan Reports to the Mednovations report library', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BodyCompositionReportsScreen(
          loadReports: () async => [],
          loadComparisons: () async => [],
        ),
      ),
    );

    expect(
      find.text('Face Scan Reports'),
      AppBrand.faceScanEnabled ? findsOneWidget : findsNothing,
    );
    expect(find.byType(Tab), findsNWidgets(AppBrand.faceScanEnabled ? 3 : 2));
  });
}

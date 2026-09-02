import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/screens/update_health_hub_screen.dart';

void main() {
  testWidgets(
    'shows the four approved import and comparison actions plus the report library',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: UpdateHealthHubScreen()),
      );

      expect(find.text('Scan Report'), findsOneWidget);
      expect(find.text('Import PDF'), findsOneWidget);
      expect(find.text('Import Screenshot'), findsOneWidget);
      expect(find.text('Compare Reports'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(4));
      expect(find.byTooltip('Report Library'), findsOneWidget);
    },
  );
}

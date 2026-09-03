import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/body_composition_report.dart';
import 'package:wellnessconnect/screens/body_composition_comparison_screen.dart';
import 'package:wellnessconnect/services/body_composition_pdf_service.dart';
import 'package:wellnessconnect/theme/app_theme.dart';

void main() {
  final comparison = BodyCompositionComparison(
    id: 'comparison-1',
    memberId: 'member-1',
    olderReportId: 'older',
    newerReportId: 'newer',
    olderReport: _report(
      id: 'older',
      measuredAt: DateTime(2026, 8, 27),
      reportedBmi: 25,
      calculatedBmi: 24.5,
      bmiBand: 'Healthy',
    ),
    newerReport: _report(
      id: 'newer',
      measuredAt: DateTime(2026, 9, 2),
      reportedBmi: 24.5,
      calculatedBmi: 24.2,
      bmiBand: 'Healthy',
    ),
    elapsedDays: 6,
    createdAt: DateTime(2026, 9, 2),
    metrics: const [
      BodyCompositionComparisonMetric(
        label: 'Weight',
        unit: 'kg',
        olderValue: 80,
        newerValue: 78,
        absoluteChange: -2,
        percentageChange: -2.5,
      ),
      BodyCompositionComparisonMetric(
        label: 'Body water',
        unit: '%',
        olderValue: 51,
        newerValue: 51,
        absoluteChange: 0,
        percentageChange: 0,
      ),
      BodyCompositionComparisonMetric(
        label: 'Waist',
        unit: 'cm',
        newerValue: 87,
      ),
    ],
  );

  testWidgets(
    'shows understandable before-and-after cards instead of a compressed table',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: BodyCompositionComparisonDetailScreen(comparison: comparison),
        ),
      );

      expect(find.text('Comparison period'), findsOneWidget);
      expect(find.text('At a glance'), findsOneWidget);
      expect(find.text('2 compared'), findsOneWidget);
      expect(find.text('1 changed'), findsOneWidget);
      expect(find.text('1 unchanged'), findsOneWidget);
      expect(find.text('1 recorded once'), findsOneWidget);
      expect(find.text('BMI context'), findsOneWidget);
      expect(find.text('Measurements compared'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('2 kg lower than earlier'),
        240,
      );
      expect(find.text('2 kg lower than earlier'), findsOneWidget);
      expect(find.text('2.5% lower than earlier'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Recorded in one report only'),
        240,
      );
      expect(find.text('Recorded in one report only'), findsOneWidget);
      expect(find.text('Recorded only in the latest report'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('builds a member-readable comparison PDF', () async {
    final bytes = await BodyCompositionPdfService.buildComparisonPdf(
      comparison,
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(900));
  });
}

BodyCompositionReport _report({
  required String id,
  required DateTime measuredAt,
  required double reportedBmi,
  required double calculatedBmi,
  required String bmiBand,
}) => BodyCompositionReport(
  id: id,
  memberId: 'member-1',
  measuredAt: measuredAt,
  clientSubmissionId: '$id-submission',
  ocrTranscript: 'Member-approved report',
  measurements: BodyCompositionMeasurements(reportedBmi: reportedBmi),
  memberCorrected: false,
  calculatedBmi: calculatedBmi,
  bmiBand: bmiBand,
  createdAt: measuredAt,
);

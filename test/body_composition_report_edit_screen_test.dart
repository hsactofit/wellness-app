import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/body_composition_report.dart';
import 'package:wellnessconnect/screens/body_composition_report_review_screen.dart';

void main() {
  testWidgets('saved report opens directly in edit mode', (tester) async {
    final now = DateTime(2026, 8, 25, 10);
    final measurements = BodyCompositionMeasurements(
      weightKg: 73,
      bodyFatPct: 21,
    );
    final report = BodyCompositionReport(
      id: 'report-1',
      memberId: 'member-1',
      measuredAt: now,
      clientSubmissionId: 'submission-1',
      ocrTranscript: 'Weight 73 kg',
      measurements: measurements,
      memberCorrected: false,
      createdAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BodyCompositionReportReviewScreen(
          draft: BodyCompositionDraft(
            clientSubmissionId: report.clientSubmissionId,
            measuredAt: report.measuredAt,
            ocrTranscript: report.ocrTranscript,
            measurements: report.measurements,
            inputMethod: report.inputMethod,
          ),
          existingReport: report,
        ),
      ),
    );

    expect(find.text('Edit health report'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Approve & Save'), findsNothing);
  });
}

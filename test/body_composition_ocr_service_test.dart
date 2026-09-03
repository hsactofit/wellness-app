import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellnessconnect/models/body_composition_report.dart';
import 'package:wellnessconnect/services/body_composition_ocr_service.dart';

void main() {
  test(
    'extracts common English body-composition metrics and converts pounds',
    () {
      const transcript = '''
      Body Composition Report
      Weight: 154.3 lb
      BMI 23.8
      Body Fat 21.5 %
      Subcutaneous Fat 18.0 %
      Visceral Fat 8
      Body Water 55.2 %
      Skeletal Muscle 42.1 %
      Muscle Mass 62.4 kg
      BMR 1650 kcal
      Metabolic Age 34
      Custom Score 87 pts
    ''';

      final values = BodyCompositionOcrService.instance.extractMeasurements(
        transcript,
      );

      expect(values.weightKg, closeTo(70.0, 0.1));
      expect(values.reportedBmi, 23.8);
      expect(values.bodyFatPct, 21.5);
      expect(values.subcutaneousFatPct, 18.0);
      expect(values.visceralFatLevel, 8);
      expect(values.bodyWaterPct, 55.2);
      expect(values.skeletalMusclePct, 42.1);
      expect(values.muscleMassKg, 62.4);
      expect(values.bmrKcal, 1650);
      expect(values.metabolicAgeYears, 34);
      expect(
        values.additionalMetrics.any((item) => item.label == 'Custom Score'),
        isTrue,
      );
    },
  );

  test('leaves missing metrics empty instead of inventing a value', () {
    final values = BodyCompositionOcrService.instance.extractMeasurements(
      'Weight: 72.4 kg\nBMI: 24.1',
    );

    expect(values.weightKg, 72.4);
    expect(values.reportedBmi, 24.1);
    expect(values.bodyFatPct, isNull);
    expect(values.additionalMetrics, isEmpty);
  });

  test(
    'reads table-style OCR labels, values, and a named measurement date',
    () {
      const transcript = '''
      BODY COMPOSITION REPORT
      Measurement Date: 25 Aug 2026
      Weight
      72.4 kg
      BMI
      24.1
      Body Fat
      21.5 %
      Scale Score
      87 pts
    ''';

      final draft = BodyCompositionOcrService.instance.readReportFromText(
        transcript,
      );

      expect(draft, isNotNull);
      expect(draft!.measuredAt, DateTime(2026, 8, 25));
      expect(draft.measurements.weightKg, 72.4);
      expect(draft.measurements.reportedBmi, 24.1);
      expect(draft.measurements.bodyFatPct, 21.5);
      expect(
        draft.measurements.additionalMetrics,
        contains(
          isA<AdditionalMeasurement>()
              .having((metric) => metric.label, 'label', 'Scale Score')
              .having((metric) => metric.value, 'value', 87)
              .having((metric) => metric.unit, 'unit', 'pts'),
        ),
      );
    },
  );

  test('flags OCR without a report measurement for retake', () {
    final values = BodyCompositionOcrService.instance.extractMeasurements(
      'Welcome to the gym\nPlease wipe the screen after use',
    );

    expect(
      BodyCompositionOcrService.instance.hasRecognizedMeasurements(values),
      isFalse,
    );
  });

  test(
    'removes an abandoned temporary capture on the next app launch',
    () async {
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp(
        'body-composition-test-',
      );
      final image = File('${directory.path}/capture.jpg');
      await image.writeAsBytes([1, 2, 3]);
      addTearDown(() async {
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      await BodyCompositionOcrService.instance.trackTemporaryCapture(
        image.path,
      );
      await BodyCompositionOcrService.instance.clearAbandonedTemporaryCapture();

      expect(await image.exists(), isFalse);
    },
  );
}

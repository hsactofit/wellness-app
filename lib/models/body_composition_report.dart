class AdditionalMeasurement {
  const AdditionalMeasurement({
    required this.label,
    required this.value,
    this.unit = '',
  });

  final String label;
  final double value;
  final String unit;

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'unit': unit,
  };

  factory AdditionalMeasurement.fromJson(Map<String, dynamic> json) {
    return AdditionalMeasurement(
      label: json['label'] as String? ?? 'Measurement',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
    );
  }
}

/// How a member supplied the report.  Keep these values stable because they
/// are persisted by the API and are used for audit/reporting.
class BodyCompositionInputMethod {
  const BodyCompositionInputMethod._();

  static const cameraScan = 'camera_scan';
  static const pdfImport = 'pdf_import';
  static const screenshotImport = 'screenshot_import';

  static String normalize(String? value) {
    switch (value) {
      case pdfImport:
        return pdfImport;
      case screenshotImport:
        return screenshotImport;
      default:
        return cameraScan;
    }
  }
}

class BodyCompositionMeasurements {
  const BodyCompositionMeasurements({
    this.weightKg,
    this.reportedBmi,
    this.bodyFatPct,
    this.subcutaneousFatPct,
    this.visceralFatLevel,
    this.bodyWaterPct,
    this.skeletalMusclePct,
    this.muscleMassKg,
    this.fatFreeBodyWeightKg,
    this.boneMassKg,
    this.proteinPct,
    this.bmrKcal,
    this.metabolicAgeYears,
    this.additionalMetrics = const [],
  });

  final double? weightKg;
  final double? reportedBmi;
  final double? bodyFatPct;
  final double? subcutaneousFatPct;
  final double? visceralFatLevel;
  final double? bodyWaterPct;
  final double? skeletalMusclePct;
  final double? muscleMassKg;
  final double? fatFreeBodyWeightKg;
  final double? boneMassKg;
  final double? proteinPct;
  final double? bmrKcal;
  final double? metabolicAgeYears;
  final List<AdditionalMeasurement> additionalMetrics;

  BodyCompositionMeasurements copyWith({
    double? weightKg,
    double? reportedBmi,
    double? bodyFatPct,
    double? subcutaneousFatPct,
    double? visceralFatLevel,
    double? bodyWaterPct,
    double? skeletalMusclePct,
    double? muscleMassKg,
    double? fatFreeBodyWeightKg,
    double? boneMassKg,
    double? proteinPct,
    double? bmrKcal,
    double? metabolicAgeYears,
    List<AdditionalMeasurement>? additionalMetrics,
  }) {
    return BodyCompositionMeasurements(
      weightKg: weightKg ?? this.weightKg,
      reportedBmi: reportedBmi ?? this.reportedBmi,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      subcutaneousFatPct: subcutaneousFatPct ?? this.subcutaneousFatPct,
      visceralFatLevel: visceralFatLevel ?? this.visceralFatLevel,
      bodyWaterPct: bodyWaterPct ?? this.bodyWaterPct,
      skeletalMusclePct: skeletalMusclePct ?? this.skeletalMusclePct,
      muscleMassKg: muscleMassKg ?? this.muscleMassKg,
      fatFreeBodyWeightKg: fatFreeBodyWeightKg ?? this.fatFreeBodyWeightKg,
      boneMassKg: boneMassKg ?? this.boneMassKg,
      proteinPct: proteinPct ?? this.proteinPct,
      bmrKcal: bmrKcal ?? this.bmrKcal,
      metabolicAgeYears: metabolicAgeYears ?? this.metabolicAgeYears,
      additionalMetrics: additionalMetrics ?? this.additionalMetrics,
    );
  }

  Map<String, dynamic> toJson() => {
    'weight_kg': weightKg,
    'reported_bmi': reportedBmi,
    'body_fat_pct': bodyFatPct,
    'subcutaneous_fat_pct': subcutaneousFatPct,
    'visceral_fat_level': visceralFatLevel,
    'body_water_pct': bodyWaterPct,
    'skeletal_muscle_pct': skeletalMusclePct,
    'muscle_mass_kg': muscleMassKg,
    'fat_free_body_weight_kg': fatFreeBodyWeightKg,
    'bone_mass_kg': boneMassKg,
    'protein_pct': proteinPct,
    'bmr_kcal': bmrKcal,
    'metabolic_age_years': metabolicAgeYears,
    'additional_metrics': additionalMetrics
        .map((item) => item.toJson())
        .toList(),
  };

  factory BodyCompositionMeasurements.fromJson(Map<String, dynamic> json) {
    double? number(String key) => (json[key] as num?)?.toDouble();
    final additional = (json['additional_metrics'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(AdditionalMeasurement.fromJson)
        .toList();
    return BodyCompositionMeasurements(
      weightKg: number('weight_kg'),
      reportedBmi: number('reported_bmi'),
      bodyFatPct: number('body_fat_pct'),
      subcutaneousFatPct: number('subcutaneous_fat_pct'),
      visceralFatLevel: number('visceral_fat_level'),
      bodyWaterPct: number('body_water_pct'),
      skeletalMusclePct: number('skeletal_muscle_pct'),
      muscleMassKg: number('muscle_mass_kg'),
      fatFreeBodyWeightKg: number('fat_free_body_weight_kg'),
      boneMassKg: number('bone_mass_kg'),
      proteinPct: number('protein_pct'),
      bmrKcal: number('bmr_kcal'),
      metabolicAgeYears: number('metabolic_age_years'),
      additionalMetrics: additional,
    );
  }
}

class BodyCompositionDraft {
  const BodyCompositionDraft({
    required this.clientSubmissionId,
    required this.measuredAt,
    required this.ocrTranscript,
    required this.measurements,
    this.inputMethod = BodyCompositionInputMethod.cameraScan,
  });

  final String clientSubmissionId;
  final DateTime measuredAt;
  final String ocrTranscript;
  final BodyCompositionMeasurements measurements;
  final String inputMethod;
}

class BodyCompositionReport {
  const BodyCompositionReport({
    required this.id,
    required this.memberId,
    required this.measuredAt,
    required this.clientSubmissionId,
    required this.ocrTranscript,
    required this.measurements,
    required this.memberCorrected,
    required this.createdAt,
    this.calculatedBmi,
    this.bmiBand,
    this.inputMethod = BodyCompositionInputMethod.cameraScan,
  });

  final String id;
  final String memberId;
  final DateTime measuredAt;
  final String clientSubmissionId;
  final String ocrTranscript;
  final BodyCompositionMeasurements measurements;
  final bool memberCorrected;
  final double? calculatedBmi;
  final String? bmiBand;
  final DateTime createdAt;
  final String inputMethod;

  factory BodyCompositionReport.fromJson(Map<String, dynamic> json) {
    return BodyCompositionReport(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      clientSubmissionId: json['client_submission_id'] as String,
      ocrTranscript: json['ocr_transcript'] as String,
      measurements: BodyCompositionMeasurements.fromJson(
        Map<String, dynamic>.from(json['measurements'] as Map),
      ),
      memberCorrected: json['member_corrected'] as bool? ?? false,
      calculatedBmi: (json['calculated_bmi'] as num?)?.toDouble(),
      bmiBand: json['bmi_band'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      inputMethod: BodyCompositionInputMethod.normalize(
        json['input_method'] as String?,
      ),
    );
  }
}

class BodyCompositionComparisonMetric {
  const BodyCompositionComparisonMetric({
    required this.label,
    required this.unit,
    this.olderValue,
    this.newerValue,
    this.absoluteChange,
    this.percentageChange,
  });

  final String label;
  final String unit;
  final double? olderValue;
  final double? newerValue;
  final double? absoluteChange;
  final double? percentageChange;

  factory BodyCompositionComparisonMetric.fromJson(Map<String, dynamic> json) {
    double? number(String key) => (json[key] as num?)?.toDouble();
    return BodyCompositionComparisonMetric(
      label: json['label'] as String? ?? 'Measurement',
      unit: json['unit'] as String? ?? '',
      olderValue: number('older_value'),
      newerValue: number('newer_value'),
      absoluteChange: number('absolute_change'),
      percentageChange: number('percentage_change'),
    );
  }
}

class BodyCompositionComparison {
  const BodyCompositionComparison({
    required this.id,
    required this.memberId,
    required this.olderReportId,
    required this.newerReportId,
    required this.olderReport,
    required this.newerReport,
    required this.metrics,
    required this.elapsedDays,
    required this.createdAt,
  });

  final String id;
  final String memberId;
  final String olderReportId;
  final String newerReportId;
  final BodyCompositionReport olderReport;
  final BodyCompositionReport newerReport;
  final List<BodyCompositionComparisonMetric> metrics;
  final int elapsedDays;
  final DateTime createdAt;

  factory BodyCompositionComparison.fromJson(Map<String, dynamic> json) {
    final older = Map<String, dynamic>.from(json['older_report'] as Map);
    final newer = Map<String, dynamic>.from(json['newer_report'] as Map);
    return BodyCompositionComparison(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      olderReportId: json['older_report_id'] as String,
      newerReportId: json['newer_report_id'] as String,
      olderReport: BodyCompositionReport.fromJson(older),
      newerReport: BodyCompositionReport.fromJson(newer),
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (item) => BodyCompositionComparisonMetric.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      elapsedDays: (json['elapsed_days'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

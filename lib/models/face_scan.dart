class FaceScanValues {
  const FaceScanValues({
    this.heartRate,
    this.respiratoryRate,
    this.spo2,
    this.systolicBp,
    this.diastolicBp,
  });

  final double? heartRate;
  final double? respiratoryRate;
  final double? spo2;
  final double? systolicBp;
  final double? diastolicBp;

  factory FaceScanValues.fromJson(Map<String, dynamic> json) => FaceScanValues(
    heartRate: _number(json['heart_rate_bpm']),
    respiratoryRate: _number(json['respiratory_rate_bpm']),
    spo2: _number(json['spo2_pct']),
    systolicBp: _number(json['systolic_bp_mmhg']),
    diastolicBp: _number(json['diastolic_bp_mmhg']),
  );

  Map<String, dynamic> toJson() => {
    'heart_rate_bpm': heartRate,
    'respiratory_rate_bpm': respiratoryRate,
    'spo2_pct': spo2,
    'systolic_bp_mmhg': systolicBp,
    'diastolic_bp_mmhg': diastolicBp,
  };

  static double? _number(dynamic value) =>
      value is num ? value.toDouble() : null;
}

class FaceScanJob {
  const FaceScanJob({
    required this.id,
    required this.status,
    required this.createdAt,
    this.reportId,
    this.errorCode,
    this.errorMessage,
  });

  final String id;
  final String status;
  final String? reportId;
  final String? errorCode;
  final String? errorMessage;
  final DateTime createdAt;

  bool get terminal =>
      const {'completed', 'failed', 'cancelled'}.contains(status);

  factory FaceScanJob.fromJson(Map<String, dynamic> json) => FaceScanJob(
    id: json['id'].toString(),
    status: json['status'].toString(),
    reportId: json['report_id']?.toString(),
    errorCode: json['error_code']?.toString(),
    errorMessage: json['error_message']?.toString(),
    createdAt: DateTime.parse(json['created_at'].toString()).toLocal(),
  );
}

class FaceScanConsent {
  const FaceScanConsent({
    required this.processingGranted,
    required this.sharingGranted,
    this.clinicId,
    this.clinicName,
  });

  final bool processingGranted;
  final bool sharingGranted;
  final String? clinicId;
  final String? clinicName;

  factory FaceScanConsent.fromJson(Map<String, dynamic> json) =>
      FaceScanConsent(
        processingGranted: json['processing_granted'] == true,
        sharingGranted: json['sharing_granted'] == true,
        clinicId: json['sharing_clinic_id']?.toString(),
        clinicName: json['sharing_clinic_name']?.toString(),
      );
}

class FaceScanReport {
  const FaceScanReport({
    required this.id,
    required this.capturedAt,
    required this.title,
    required this.originalValues,
    required this.correctedValues,
    required this.effectiveValues,
    required this.revision,
    required this.quality,
    this.notes,
    this.correctedAt,
  });

  final String id;
  final DateTime capturedAt;
  final String title;
  final String? notes;
  final FaceScanValues originalValues;
  final FaceScanValues correctedValues;
  final FaceScanValues effectiveValues;
  final int revision;
  final DateTime? correctedAt;
  final Map<String, dynamic> quality;

  bool get memberEdited =>
      correctedValues.toJson().values.any((value) => value != null);

  factory FaceScanReport.fromJson(Map<String, dynamic> json) => FaceScanReport(
    id: json['id'].toString(),
    capturedAt: DateTime.parse(json['captured_at'].toString()).toLocal(),
    title: json['title'].toString(),
    notes: json['notes']?.toString(),
    originalValues: FaceScanValues.fromJson(
      Map<String, dynamic>.from(json['original_values'] as Map),
    ),
    correctedValues: FaceScanValues.fromJson(
      Map<String, dynamic>.from(json['corrected_values'] as Map),
    ),
    effectiveValues: FaceScanValues.fromJson(
      Map<String, dynamic>.from(json['effective_values'] as Map),
    ),
    revision: json['revision'] as int,
    correctedAt: json['corrected_at'] == null
        ? null
        : DateTime.parse(json['corrected_at'].toString()).toLocal(),
    quality: Map<String, dynamic>.from(json['quality'] as Map? ?? const {}),
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/face_scan.dart';

void main() {
  test('parses unavailable and member-corrected Face Scan values', () {
    final report = FaceScanReport.fromJson({
      'id': 'report-1',
      'captured_at': '2026-09-18T08:00:00Z',
      'title': 'Morning scan',
      'notes': 'Seated before breakfast',
      'original_values': {
        'heart_rate_bpm': 70,
        'respiratory_rate_bpm': null,
        'spo2_pct': 98,
        'systolic_bp_mmhg': 118,
        'diastolic_bp_mmhg': 76,
      },
      'corrected_values': {'heart_rate_bpm': 72},
      'effective_values': {
        'heart_rate_bpm': 72,
        'respiratory_rate_bpm': null,
        'spo2_pct': 98,
        'systolic_bp_mmhg': 118,
        'diastolic_bp_mmhg': 76,
      },
      'quality': {'summary': 'Good'},
      'revision': 2,
      'corrected_at': '2026-09-18T08:05:00Z',
    });

    expect(report.memberEdited, isTrue);
    expect(report.originalValues.heartRate, 70);
    expect(report.effectiveValues.heartRate, 72);
    expect(report.effectiveValues.respiratoryRate, isNull);
    expect(report.revision, 2);
  });

  test('recognizes terminal processing states', () {
    final job = FaceScanJob.fromJson({
      'id': 'job-1',
      'status': 'cancelled',
      'created_at': '2026-09-18T08:00:00Z',
    });

    expect(job.terminal, isTrue);
  });
}

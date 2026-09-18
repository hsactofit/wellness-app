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

  test('failed jobs stay off the Face Scan reports library', () {
    final jobs = [
      FaceScanJob.fromJson({
        'id': 'failed',
        'status': 'failed',
        'error_message':
            'Processing is temporarily unavailable. Please try the scan again.',
        'created_at': '2026-09-18T08:00:00Z',
      }),
      FaceScanJob.fromJson({
        'id': 'processing',
        'status': 'processing',
        'created_at': '2026-09-18T08:01:00Z',
      }),
    ];
    final listed = jobs.where((job) => !job.terminal).toList();

    expect(listed, hasLength(1));
    expect(listed.single.id, 'processing');
    expect(jobs.any((job) => job.status == 'failed' && !job.terminal), isFalse);
  });
}

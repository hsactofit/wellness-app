import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/care_program.dart';
import 'package:wellnessconnect/services/care_program_pdf_service.dart';

void main() {
  test('builds a member-safe care program progress PDF', () async {
    final program = CareProgram.fromJson({
      'id': 'program-1',
      'title': 'Cardiometabolic Foundation',
      'status': 'active',
      'revision': 3,
      'member_summary': 'A steady eight-week foundation.',
      'objectives': ['Build a sustainable daily routine'],
      'actions': <Object>[],
      'guidance': [
        {
          'text': 'Continue the current hydration target.',
          'author_id': 'physician-1',
          'author_name': 'Dr Asha Rao',
          'published_at': '2026-09-10T10:00:00Z',
        },
      ],
      'review_due': false,
      'starts_on': '2026-09-01',
      'ends_on': '2026-10-27',
    });
    final summary = CareProgramSummary.fromJson({
      'review_requested': false,
      'current': null,
      'history': <Object>[],
      'progress': {
        'expected_actions': 10,
        'completed_actions': 7,
        'measurement_changes': {
          'available': true,
          'items': [
            {
              'label': 'Weight',
              'unit': 'kg',
              'first': 82.0,
              'latest': 80.5,
              'change': -1.5,
            },
          ],
        },
      },
    });

    final bytes = await CareProgramPdfService.buildProgress(
      program: program,
      summary: summary,
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(800));
  });
}

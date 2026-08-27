import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/plan_models.dart';
import 'package:wellnessconnect/services/reviewed_plan_pdf_service.dart';

void main() {
  test('builds a readable nutrition plan PDF from an approved plan', () async {
    final bytes = await ReviewedPlanPdfService.buildApprovedPlanPdf(
      kind: PlanKind.nutrition,
      plan: {
        'title': 'Balanced Energy Plan',
        'summary': 'A practical seven-day meal plan.',
        'duration_weeks': 4,
        'valid_from': '2026-08-25T10:00:00Z',
        'valid_until': '2026-09-22T10:00:00Z',
        'approved_at': '2026-08-25T10:00:00Z',
        'timeline': [
          {
            'week': 1,
            'focus': 'Build a steady meal rhythm',
            'checkpoints': ['Eat breakfast', 'Drink water'],
          },
        ],
        'content': [
          {
            'day': 'Monday',
            'total_calories': 2000,
            'meals': [
              {
                'name': 'Breakfast',
                'items': 'Oats and fruit',
                'calories': 420,
                'protein_g': 18,
                'carbs_g': 60,
                'fat_g': 12,
              },
            ],
          },
        ],
      },
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(800));
  });

  test('builds a workout plan PDF with rest-day guidance', () async {
    final bytes = await ReviewedPlanPdfService.buildApprovedPlanPdf(
      kind: PlanKind.workout,
      plan: {
        'title': 'Foundation Strength Plan',
        'duration_weeks': 4,
        'timeline': const [],
        'content': [
          {'day': 'Sunday', 'is_rest_day': true, 'exercises': const []},
        ],
      },
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(700));
  });
}

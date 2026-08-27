import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/plan_models.dart';

/// Creates a member-owned copy of an approved reviewed plan.
///
/// The plan response is already scoped to the authenticated member by the API.
/// The PDF is created on the member's device and only passed to the platform
/// share sheet when they explicitly tap Download PDF report.
class ReviewedPlanPdfService {
  const ReviewedPlanPdfService._();

  static Future<void> shareApprovedPlan({
    required PlanKind kind,
    required Map<String, dynamic> plan,
  }) async {
    final bytes = await buildApprovedPlanPdf(kind: kind, plan: plan);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _filename(kind, plan),
      subject: '${_planLabel(kind)} - Medifit',
      body: 'Your specialist-approved Medifit plan.',
    );
  }

  static Future<Uint8List> buildApprovedPlanPdf({
    required PlanKind kind,
    required Map<String, dynamic> plan,
  }) async {
    final document = pw.Document();
    final accent = kind == PlanKind.workout
        ? PdfColor.fromInt(0xFF355DDB)
        : PdfColor.fromInt(0xFFD97706);
    final planLabel = _planLabel(kind);
    final title = _text(plan['title'], fallback: planLabel);
    final summary = _text(plan['summary']);
    final durationWeeks = _text(plan['duration_weeks'], fallback: '4');
    final validFrom = _formatDate(plan['valid_from']);
    final validUntil = _formatDate(plan['valid_until']);
    final approvedAt = _formatDate(plan['approved_at']);
    final timeline = _maps(plan['timeline']);
    final days = _maps(plan['content']);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 34, 36, 42),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Medifit Wellness360',
                style: pw.TextStyle(
                  color: accent,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.Text(
                'Specialist-approved member plan',
                style: const pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'For the signed-in Medifit member',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 8,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  planLabel.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.SizedBox(height: 7),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 21,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Reviewed and approved by your company ${kind == PlanKind.workout ? 'trainer' : 'dietitian'}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Plan details', accent),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _detailCard('Status', 'Approved', accent),
              _detailCard('Duration', '$durationWeeks weeks', accent),
              _detailCard('Starts', validFrom, accent),
              _detailCard('Ends', validUntil, accent),
              if (approvedAt != 'Not recorded')
                _detailCard('Approved', approvedAt, accent),
            ],
          ),
          if (summary.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle('Plan summary', accent),
            pw.SizedBox(height: 7),
            pw.Text(
              summary,
              style: const pw.TextStyle(
                color: PdfColors.grey800,
                fontSize: 10,
                lineSpacing: 3,
              ),
            ),
          ],
          if (timeline.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle('Progress timeline', accent),
            pw.SizedBox(height: 8),
            ...timeline.map((week) => _timelineItem(week, accent)),
          ],
          pw.NewPage(freeSpace: 220),
          _sectionTitle('Seven-day schedule', accent),
          pw.SizedBox(height: 8),
          if (days.isEmpty)
            pw.Text(
              'No daily schedule entries are available for this plan.',
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
            )
          else
            ...days.expand(
              (day) => [
                pw.NewPage(freeSpace: 170),
                _dayCard(day: day, kind: kind, accent: accent),
              ],
            ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _sectionTitle(String text, PdfColor accent) => pw.Text(
    text.toUpperCase(),
    style: pw.TextStyle(
      color: accent,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 0.8,
    ),
  );

  static pw.Widget _detailCard(String label, String value, PdfColor accent) =>
      pw.Container(
        width: 115,
        padding: const pw.EdgeInsets.all(9),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 7),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: accent,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  static pw.Widget _timelineItem(Map<String, dynamic> week, PdfColor accent) {
    final checkpoints = _strings(week['checkpoints']);
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 7),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Week ${_text(week['week'], fallback: '-')} - ${_text(week['focus'], fallback: 'Plan focus')}',
            style: pw.TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (checkpoints.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              checkpoints.join(' | '),
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _dayCard({
    required Map<String, dynamic> day,
    required PlanKind kind,
    required PdfColor accent,
  }) {
    final dayLabel = _text(day['day'], fallback: 'Day');
    final isRestDay = day['is_rest_day'] == true;
    final subtitle = kind == PlanKind.nutrition
        ? _text(day['total_calories']).isNotEmpty
              ? '${_text(day['total_calories'])} kcal'
              : ''
        : isRestDay
        ? 'Rest day'
        : _text(day['focus']);
    final entries = kind == PlanKind.nutrition
        ? _maps(day['meals'])
        : _maps(day['exercises']);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 7),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  dayLabel,
                  style: pw.TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  pw.Text(
                    subtitle,
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: entries.isEmpty
                ? pw.Text(
                    kind == PlanKind.workout && isRestDay
                        ? 'Recovery and rest.'
                        : 'No items recorded.',
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 9,
                    ),
                  )
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: entries
                        .map(
                          (entry) => kind == PlanKind.nutrition
                              ? _mealItem(entry, accent)
                              : _exerciseItem(entry, accent),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _mealItem(Map<String, dynamic> meal, PdfColor accent) {
    final macros = <String>[
      if (_text(meal['calories']).isNotEmpty) '${_text(meal['calories'])} kcal',
      if (_text(meal['protein_g']).isNotEmpty)
        'Protein ${_text(meal['protein_g'])}g',
      if (_text(meal['carbs_g']).isNotEmpty) 'Carbs ${_text(meal['carbs_g'])}g',
      if (_text(meal['fat_g']).isNotEmpty) 'Fat ${_text(meal['fat_g'])}g',
    ];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _text(meal['name'], fallback: 'Meal'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5),
          ),
          if (_text(meal['items']).isNotEmpty)
            pw.Text(
              _text(meal['items']),
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
          if (macros.isNotEmpty)
            pw.Text(
              macros.join(' | '),
              style: pw.TextStyle(color: accent, fontSize: 8.5),
            ),
        ],
      ),
    );
  }

  static pw.Widget _exerciseItem(
    Map<String, dynamic> exercise,
    PdfColor accent,
  ) {
    final details = <String>[
      if (_text(exercise['sets']).isNotEmpty) '${_text(exercise['sets'])} sets',
      if (_text(exercise['reps']).isNotEmpty) '${_text(exercise['reps'])} reps',
      if (_text(exercise['rest_sec']).isNotEmpty)
        '${_text(exercise['rest_sec'])} sec rest',
    ];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _text(exercise['name'], fallback: 'Exercise'),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5),
          ),
          if (details.isNotEmpty)
            pw.Text(
              details.join(' | '),
              style: pw.TextStyle(color: accent, fontSize: 8.5),
            ),
          if (_text(exercise['notes']).isNotEmpty)
            pw.Text(
              _text(exercise['notes']),
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
        ],
      ),
    );
  }

  static String _planLabel(PlanKind kind) =>
      kind == PlanKind.workout ? 'Workout Plan' : 'Nutrition Plan';

  static String _filename(PlanKind kind, Map<String, dynamic> plan) {
    final type = kind == PlanKind.workout ? 'workout' : 'nutrition';
    final rawTitle = _text(plan['title'], fallback: type).toLowerCase();
    final slug = rawTitle
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'medifit-${slug.isEmpty ? type : slug}-report.pdf';
  }

  static String _formatDate(dynamic value) {
    final parsed = DateTime.tryParse(_text(value));
    if (parsed == null) return 'Not recorded';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = parsed.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static List<Map<String, dynamic>> _maps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: false);
  }

  static List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(_text)
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result == 'null' ? fallback : result;
  }
}

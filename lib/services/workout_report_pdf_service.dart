import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'facility_booking_service.dart';
import 'workout_report_presentation.dart';

/// Builds a member-owned, static copy of a completed workout report locally.
/// The generated file only leaves the device when the member explicitly opens
/// the platform save/share sheet.
class WorkoutReportPdfService {
  const WorkoutReportPdfService._();

  static Future<void> shareReport(WorkoutReport report) async {
    final bytes = await buildReportPdf(report);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _filename(report),
      subject: 'Workout report - Medifit',
      body: 'Your completed Medifit workout report.',
    );
  }

  static Future<Uint8List> buildReportPdf(WorkoutReport report) async {
    final facts = WorkoutReportPresentation.factsFor(report);
    final document = pw.Document();
    const accent = PdfColor.fromInt(0xFF355DDB);
    const success = PdfColor.fromInt(0xFF168562);
    const incomplete = PdfColor.fromInt(0xFFCBD5E1);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(34, 32, 34, 42),
        header: (context) => _header('Workout report'),
        footer: (context) => _footer(context),
        build: (context) => [
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
                  'COMPLETED WORKOUT',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.SizedBox(height: 7),
                pw.Text(
                  _pdfText(report.facilityName),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 21,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '${_date(report.checkOutAt ?? report.checkInAt ?? report.generatedAt)} - ${_duration(report.durationMin)}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('At a glance', accent),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statCard('Duration', _duration(report.durationMin), accent),
              _statCard(
                'Estimated calories',
                report.calories == null ? 'Pending' : '${report.calories} kcal',
                accent,
              ),
              _statCard(
                'Intensity',
                _pdfText(report.intensity ?? 'Pending'),
                accent,
              ),
              _statCard(
                'Checklist completion',
                facts.completionPct == null
                    ? 'No checklist'
                    : '${facts.completionPct!.round()}%',
                accent,
              ),
            ],
          ),
          if (facts.hasChecklist) ...[
            pw.SizedBox(height: 20),
            _sectionTitle('Workout progress', accent),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(
                    width: 140,
                    height: 140,
                    child: pw.Chart(
                      grid: pw.PieGrid(startAngle: -math.pi / 2),
                      datasets: [
                        if (facts.completedCount > 0)
                          pw.PieDataSet(
                            value: facts.completedCount,
                            color: success,
                            innerRadius: 42,
                            legendPosition: pw.PieLegendPosition.none,
                            drawBorder: false,
                          ),
                        if (facts.notCompletedCount > 0)
                          pw.PieDataSet(
                            value: facts.notCompletedCount,
                            color: incomplete,
                            innerRadius: 42,
                            legendPosition: pw.PieLegendPosition.none,
                            drawBorder: false,
                          ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${facts.completedCount} of ${facts.items.length} exercises completed',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            if (facts.completedCount > 0)
                              pw.Expanded(
                                flex: facts.completedCount,
                                child: pw.Container(height: 14, color: success),
                              ),
                            if (facts.notCompletedCount > 0)
                              pw.Expanded(
                                flex: facts.notCompletedCount,
                                child: pw.Container(
                                  height: 14,
                                  color: incomplete,
                                ),
                              ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        _legend('Completed', facts.completedCount, success),
                        pw.SizedBox(height: 4),
                        _legend(
                          'Not completed',
                          facts.notCompletedCount,
                          incomplete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 20),
          _sectionTitle('Today\'s checklist', accent),
          pw.SizedBox(height: 8),
          if (!facts.hasChecklist)
            pw.Text(
              'No workout checklist was assigned for this session.',
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
            )
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey700,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              headers: const ['Status', 'Exercise', 'Plan details'],
              columnWidths: const {
                0: pw.FlexColumnWidth(0.75),
                1: pw.FlexColumnWidth(1.35),
                2: pw.FlexColumnWidth(2.3),
              },
              data: facts.items
                  .map(
                    (item) => [
                      item.completed ? 'Completed' : 'Not completed',
                      _pdfText(item.name),
                      _pdfText(item.details.isEmpty ? '-' : item.details),
                    ],
                  )
                  .toList(growable: false),
            ),
          if (_hasText(report.summary) || _hasText(report.recoveryNote)) ...[
            pw.SizedBox(height: 20),
            _sectionTitle('Tarqa workout insight', accent),
            pw.SizedBox(height: 8),
            if (_hasText(report.summary))
              _insightCard('Session summary', report.summary!),
            if (_hasText(report.recoveryNote)) ...[
              pw.SizedBox(height: 8),
              _insightCard('Recovery note', report.recoveryNote!),
            ],
          ],
          pw.SizedBox(height: 14),
          pw.Text(
            'Estimated calories, intensity, summary, and recovery guidance are generated from this session\'s duration and workout plan. They are not medical advice.',
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 8),
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _header(String title) => pw.Container(
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
            color: PdfColors.blue700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          title,
          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
        ),
      ],
    ),
  );

  static pw.Widget _footer(pw.Context context) => pw.Container(
    padding: const pw.EdgeInsets.only(top: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'For the signed-in Medifit member',
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
        ),
      ],
    ),
  );

  static pw.Widget _sectionTitle(String text, PdfColor accent) => pw.Text(
    text.toUpperCase(),
    style: pw.TextStyle(
      color: accent,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 0.8,
    ),
  );

  static pw.Widget _statCard(String label, String value, PdfColor accent) =>
      pw.Container(
        width: 118,
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
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: accent,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );

  static pw.Widget _legend(String label, int value, PdfColor color) => pw.Row(
    children: [
      pw.Container(width: 8, height: 8, color: color),
      pw.SizedBox(width: 6),
      pw.Text('$label: $value', style: const pw.TextStyle(fontSize: 9)),
    ],
  );

  static pw.Widget _insightCard(String label, String value) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.blueGrey50,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _pdfText(value),
          style: const pw.TextStyle(fontSize: 9, lineSpacing: 3),
        ),
      ],
    ),
  );

  static bool _hasText(String? value) => value?.trim().isNotEmpty == true;

  static String _filename(WorkoutReport report) {
    final day = report.checkOutAt ?? report.checkInAt ?? report.generatedAt;
    final date = day == null
        ? 'workout'
        : '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return 'medifit-workout-report-$date.pdf';
  }

  static String _date(DateTime? value) {
    if (value == null) return 'Date not recorded';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  static String _duration(int? minutes) =>
      minutes == null ? 'Not recorded' : '$minutes min';

  static String _pdfText(String value) => value
      .replaceAll('—', '-')
      .replaceAll('–', '-')
      .replaceAll('•', '-')
      .replaceAll('·', '-')
      .replaceAll('→', 'to');
}

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../app_brand.dart';
import '../models/care_program.dart';

/// Produces a member-controlled report from the member-safe Care Programs API.
/// Unpublished staff notes are filtered by the server and never reach this PDF.
class CareProgramPdfService {
  const CareProgramPdfService._();

  static Future<void> shareProgress({
    required CareProgram program,
    required CareProgramSummary summary,
  }) async {
    final bytes = await buildProgress(program: program, summary: summary);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'care-program-progress-${_slug(program.title)}.pdf',
      subject: '${program.title} progress - ${AppBrand.name}',
      body: 'Your ${AppBrand.name} Care Program progress report.',
    );
  }

  static Future<Uint8List> buildProgress({
    required CareProgram program,
    required CareProgramSummary summary,
  }) async {
    final document = pw.Document();
    final navy = PdfColor.fromInt(0xFF082F49);
    final green = PdfColor.fromInt(0xFF168B72);
    final elapsed = _elapsed(program);
    final completion = summary.expectedActions == 0
        ? null
        : summary.completedActions / summary.expectedActions;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 34, 38, 42),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${AppBrand.name} CARE PROGRAMS',
              style: pw.TextStyle(
                color: navy,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Progress report',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
            ),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Member copy - generated ${_date(DateTime.now())}',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
            ),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: navy,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  program.title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (program.summary.isNotEmpty) ...[
                  pw.SizedBox(height: 7),
                  pw.Text(
                    program.summary,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          _heading('Reporting period', navy),
          pw.SizedBox(height: 7),
          pw.Text(
            '${_date(program.startsOn)} to ${_date(program.endsOn)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          if (program.completionSummary != null) ...[
            pw.SizedBox(height: 18),
            _heading('Physician completion summary', navy),
            pw.SizedBox(height: 7),
            pw.Text(
              program.completionSummary!,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 3),
            ),
          ],
          pw.SizedBox(height: 18),
          _heading('Program objectives', navy),
          pw.SizedBox(height: 7),
          if (program.objectives.isEmpty)
            pw.Text('No objectives recorded.')
          else
            ...program.objectives.map(
              (objective) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text('- $objective'),
              ),
            ),
          pw.SizedBox(height: 18),
          _heading('Progress', navy),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metric(
                'Action completion',
                completion == null
                    ? 'Unavailable'
                    : '${(completion * 100).round()}%',
                '${summary.completedActions} of ${summary.expectedActions} expected actions',
                green,
              ),
              _metric(
                'Program time elapsed',
                '${(elapsed * 100).round()}%',
                'Shown separately from participation',
                navy,
              ),
              if (summary.measurementChanges.isEmpty)
                _metric(
                  'Measurement changes',
                  'Unavailable',
                  'Two qualifying readings are needed',
                  navy,
                )
              else
                ...summary.measurementChanges.map(
                  (metric) => _metric(
                    metric.label,
                    '${metric.change >= 0 ? '+' : ''}${metric.change} ${metric.unit}',
                    '${metric.first} to ${metric.latest} ${metric.unit}',
                    navy,
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 20),
          _heading('Published care-team guidance', navy),
          pw.SizedBox(height: 8),
          if (program.guidance.isEmpty)
            pw.Text('No published guidance is available for this period.')
          else
            ...program.guidance.map(
              (item) => pw.Container(
                width: double.infinity,
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.text),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${item.authorName} - ${_date(item.publishedAt)}',
                      style: const pw.TextStyle(
                        color: PdfColors.grey600,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          pw.SizedBox(height: 14),
          pw.Text(
            'This report separates participation, elapsed time and recorded measurements. It does not make an automated claim of clinical improvement.',
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8),
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _heading(String text, PdfColor color) => pw.Text(
    text.toUpperCase(),
    style: pw.TextStyle(
      color: color,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: .8,
    ),
  );

  static pw.Widget _metric(
    String label,
    String value,
    String detail,
    PdfColor color,
  ) => pw.Container(
    width: 158,
    padding: const pw.EdgeInsets.all(11),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(7),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          detail,
          style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 7),
        ),
      ],
    ),
  );

  static double _elapsed(CareProgram program) {
    if (program.startsOn == null) return 0;
    final total = (program.endsOn?.difference(program.startsOn!).inDays ?? 1)
        .clamp(1, 999);
    return (DateTime.now().difference(program.startsOn!).inDays / total).clamp(
      0,
      1,
    );
  }

  static String _date(DateTime? date) => date == null
      ? 'Not recorded'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String _slug(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

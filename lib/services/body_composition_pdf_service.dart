import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/body_composition_report.dart';

class BodyCompositionPdfService {
  const BodyCompositionPdfService._();

  static Future<void> shareReport(BodyCompositionReport report) async {
    await Printing.sharePdf(
      bytes: await buildReportPdf(report),
      filename: 'medifit-health-report-${_date(report.measuredAt)}.pdf',
      subject: 'Medifit health report',
    );
  }

  static Future<void> shareComparison(
    BodyCompositionComparison comparison,
  ) async {
    await Printing.sharePdf(
      bytes: await buildComparisonPdf(comparison),
      filename:
          'medifit-report-comparison-${_date(comparison.newerReport.measuredAt)}.pdf',
      subject: 'Medifit report comparison',
    );
  }

  static Future<Uint8List> buildReportPdf(BodyCompositionReport report) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _header('Health report'),
        build: (_) => [
          pw.Text(
            'Measured ${_date(report.measuredAt)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Source: ${_source(report.inputMethod)}${report.memberCorrected ? ' · Member corrected' : ''}',
          ),
          pw.SizedBox(height: 16),
          _metricTable(report),
          pw.SizedBox(height: 18),
          pw.Text(
            'OCR transcript',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            report.ocrTranscript,
            style: const pw.TextStyle(fontSize: 8, lineSpacing: 2),
          ),
        ],
      ),
    );
    return document.save();
  }

  static Future<Uint8List> buildComparisonPdf(
    BodyCompositionComparison comparison,
  ) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _header('Report comparison'),
        build: (_) => [
          pw.Text('Older report: ${_date(comparison.olderReport.measuredAt)}'),
          pw.Text(
            'Newer report: ${_date(comparison.newerReport.measuredAt)} · ${comparison.elapsedDays} days elapsed',
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Reported BMI: ${_number(comparison.olderReport.measurements.reportedBmi)} → ${_number(comparison.newerReport.measurements.reportedBmi)}',
          ),
          pw.Text(
            'App BMI: ${_number(comparison.olderReport.calculatedBmi)} (${comparison.olderReport.bmiBand ?? '—'}) → ${_number(comparison.newerReport.calculatedBmi)} (${comparison.newerReport.bmiBand ?? '—'})',
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey700,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: const [
              'Metric',
              'Unit',
              'Older',
              'Newer',
              'Change',
              '% change',
            ],
            data: comparison.metrics
                .map(
                  (metric) => [
                    metric.label,
                    metric.unit,
                    _number(metric.olderValue),
                    _number(metric.newerValue),
                    _number(metric.absoluteChange),
                    metric.percentageChange == null
                        ? '—'
                        : '${_number(metric.percentageChange)}%',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _header(String title) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    padding: const pw.EdgeInsets.only(bottom: 8),
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

  static pw.Widget _metricTable(BodyCompositionReport report) {
    final m = report.measurements;
    final rows = <List<String>>[
      if (m.weightKg != null) ['Weight', 'kg', _number(m.weightKg)],
      if (m.reportedBmi != null) ['Reported BMI', '', _number(m.reportedBmi)],
      if (report.calculatedBmi != null)
        [
          'App BMI (${report.bmiBand ?? 'band not recorded'})',
          '',
          _number(report.calculatedBmi),
        ],
      if (m.bodyFatPct != null) ['Body fat', '%', _number(m.bodyFatPct)],
      if (m.subcutaneousFatPct != null)
        ['Subcutaneous fat', '%', _number(m.subcutaneousFatPct)],
      if (m.visceralFatLevel != null)
        ['Visceral fat', 'level', _number(m.visceralFatLevel)],
      if (m.bodyWaterPct != null) ['Body water', '%', _number(m.bodyWaterPct)],
      if (m.skeletalMusclePct != null)
        ['Skeletal muscle', '%', _number(m.skeletalMusclePct)],
      if (m.muscleMassKg != null)
        ['Muscle mass', 'kg', _number(m.muscleMassKg)],
      if (m.fatFreeBodyWeightKg != null)
        ['Fat-free weight', 'kg', _number(m.fatFreeBodyWeightKg)],
      if (m.boneMassKg != null) ['Bone mass', 'kg', _number(m.boneMassKg)],
      if (m.proteinPct != null) ['Protein', '%', _number(m.proteinPct)],
      if (m.bmrKcal != null) ['BMR', 'kcal/day', _number(m.bmrKcal)],
      if (m.metabolicAgeYears != null)
        ['Metabolic age', 'years', _number(m.metabolicAgeYears)],
      ...m.additionalMetrics.map(
        (item) => [item.label, item.unit, _number(item.value)],
      ),
    ];
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: const ['Metric', 'Unit', 'Confirmed value'],
      data: rows,
    );
  }

  static String _source(String method) => switch (method) {
    BodyCompositionInputMethod.pdfImport => 'PDF import',
    BodyCompositionInputMethod.screenshotImport => 'Screenshot import',
    _ => 'Camera scan',
  };

  static String _number(double? value) => value == null
      ? '—'
      : (value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2));

  static String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/body_composition_report.dart';
import 'body_composition_comparison_presentation.dart';

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
          pw.Text(
            'Earlier ${_date(comparison.olderReport.measuredAt)} to latest ${_date(comparison.newerReport.measuredAt)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${comparison.elapsedDays} ${comparison.elapsedDays == 1 ? 'day' : 'days'} between measurements',
          ),
          pw.SizedBox(height: 14),
          _comparisonSummary(comparison),
          pw.SizedBox(height: 16),
          pw.Text(
            'BMI context',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Reported and app-calculated BMI use different sources and are kept separate.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey700,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headers: const ['BMI type', 'Earlier', 'Latest'],
            data: [
              [
                'Reported BMI',
                _comparisonPdfText(
                  _number(comparison.olderReport.measurements.reportedBmi),
                ),
                _comparisonPdfText(
                  _number(comparison.newerReport.measurements.reportedBmi),
                ),
              ],
              [
                'App-calculated BMI',
                _comparisonPdfText(
                  '${_number(comparison.olderReport.calculatedBmi)}${comparison.olderReport.bmiBand == null ? '' : ' · ${comparison.olderReport.bmiBand}'}',
                ),
                _comparisonPdfText(
                  '${_number(comparison.newerReport.calculatedBmi)}${comparison.newerReport.bmiBand == null ? '' : ' · ${comparison.newerReport.bmiBand}'}',
                ),
              ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Measurements',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
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
              'Measurement',
              'Earlier',
              'Latest',
              'Change from earlier',
            ],
            columnWidths: const {
              0: pw.FlexColumnWidth(1.7),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1.8),
            },
            data: comparison.metrics
                .map(
                  (metric) => [
                    '${metric.label}${metric.unit.trim().isEmpty ? '' : ' (${metric.unit})'}',
                    _comparisonPdfText(
                      BodyCompositionComparisonPresentation.formatValue(
                        metric.olderValue,
                        metric.unit,
                      ),
                    ),
                    _comparisonPdfText(
                      BodyCompositionComparisonPresentation.formatValue(
                        metric.newerValue,
                        metric.unit,
                      ),
                    ),
                    _comparisonPdfText(
                      BodyCompositionComparisonPresentation.changeForTable(
                        metric,
                      ),
                    ),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'This comparison describes recorded changes only. It does not assess what is healthy or unhealthy for the member.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
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

  static pw.Widget _comparisonSummary(BodyCompositionComparison comparison) {
    final comparable = BodyCompositionComparisonPresentation.comparableCount(
      comparison,
    );
    final changed = BodyCompositionComparisonPresentation.changedCount(
      comparison,
    );
    final unchanged = BodyCompositionComparisonPresentation.unchangedCount(
      comparison,
    );
    final recordedOnce =
        BodyCompositionComparisonPresentation.recordedOnceCount(comparison);
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        '$comparable measurements compared · $changed changed · $unchanged unchanged${recordedOnce == 0 ? '' : ' · $recordedOnce recorded in one report only'}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      ),
    );
  }

  /// The built-in PDF font has a limited character set. The app view can use
  /// typographic arrows and dashes, while the exported report keeps an ASCII
  /// equivalent so every value stays visible in the generated file.
  static String _comparisonPdfText(String value) => value
      .replaceAll('—', '-')
      .replaceAll('→', 'to')
      .replaceAll('·', '/')
      .replaceAll('–', '-');

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

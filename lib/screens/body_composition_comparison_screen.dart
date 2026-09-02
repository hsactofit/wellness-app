import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/body_composition_report.dart';
import '../services/api_service.dart';
import '../services/body_composition_pdf_service.dart';

class BodyCompositionComparisonScreen extends StatefulWidget {
  const BodyCompositionComparisonScreen({super.key});

  @override
  State<BodyCompositionComparisonScreen> createState() =>
      _BodyCompositionComparisonScreenState();
}

class _BodyCompositionComparisonScreenState
    extends State<BodyCompositionComparisonScreen> {
  late Future<List<BodyCompositionReport>> _reportsFuture;
  String? _olderId;
  String? _newerId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ApiService.instance.fetchBodyCompositionReports();
  }

  Future<void> _compare(List<BodyCompositionReport> reports) async {
    if (_olderId == null || _newerId == null || _olderId == _newerId) return;
    setState(() => _submitting = true);
    try {
      final comparison = await ApiService.instance
          .createBodyCompositionComparison(
            olderReportId: _olderId!,
            newerReportId: _newerId!,
            clientSubmissionId: const Uuid().v4(),
          );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BodyCompositionComparisonDetailScreen(comparison: comparison),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not compare reports: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare Reports')),
      body: FutureBuilder<List<BodyCompositionReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load reports: ${snapshot.error}'),
            );
          }
          final reports = snapshot.data ?? [];
          if (reports.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Save at least two health reports to compare them.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          _olderId ??= reports[1].id;
          _newerId ??= reports[0].id;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Choose any two distinct saved reports. Reports from the same date are allowed.',
              ),
              const SizedBox(height: 18),
              _selector(
                label: 'Older report',
                value: _olderId,
                reports: reports,
                onChanged: (value) => setState(() => _olderId = value),
              ),
              const SizedBox(height: 14),
              _selector(
                label: 'Newer report',
                value: _newerId,
                reports: reports,
                onChanged: (value) => setState(() => _newerId = value),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _submitting ? null : () => _compare(reports),
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.compare_arrows_outlined),
                label: const Text('Compare Reports'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _selector({
    required String label,
    required String? value,
    required List<BodyCompositionReport> reports,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: reports
          .map(
            (report) => DropdownMenuItem(
              value: report.id,
              child: Text('${_date(report.measuredAt)} · ${_summary(report)}'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _summary(BodyCompositionReport report) {
    final weight = report.measurements.weightKg;
    return weight == null
        ? 'body-composition report'
        : '${weight.toStringAsFixed(1)} kg';
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class BodyCompositionComparisonDetailScreen extends StatelessWidget {
  const BodyCompositionComparisonDetailScreen({
    super.key,
    required this.comparison,
  });

  final BodyCompositionComparison comparison;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Comparison'),
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            onPressed: () async {
              try {
                await BodyCompositionPdfService.shareComparison(comparison);
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not create PDF: $error')),
                  );
                }
              }
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_date(comparison.olderReport.measuredAt)} → ${_date(comparison.newerReport.measuredAt)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text('${comparison.elapsedDays} days elapsed'),
          const SizedBox(height: 10),
          Text(
            'Reported BMI: ${_number(comparison.olderReport.measurements.reportedBmi)} → ${_number(comparison.newerReport.measurements.reportedBmi)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            'App BMI: ${_number(comparison.olderReport.calculatedBmi)} (${comparison.olderReport.bmiBand ?? '—'}) → ${_number(comparison.newerReport.calculatedBmi)} (${comparison.newerReport.bmiBand ?? '—'})',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Theme.of(context).dividerColor),
            columnWidths: const {
              0: FlexColumnWidth(2.3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.2),
            },
            children: [
              _row([
                'Metric',
                'Unit',
                'Older',
                'Newer',
                'Change',
                '% change',
              ], header: true),
              ...comparison.metrics.map(
                (metric) => _row([
                  metric.label,
                  metric.unit,
                  _number(metric.olderValue),
                  _number(metric.newerValue),
                  _change(metric.absoluteChange),
                  metric.percentageChange == null
                      ? '—'
                      : '${_number(metric.percentageChange)}%',
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Changes are shown as up, down, or unchanged only and are not medical judgments.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  TableRow _row(List<String> values, {bool header = false}) => TableRow(
    decoration: header
        ? const BoxDecoration(color: Color(0xFFE9EEF5))
        : values.first.toLowerCase().contains('bmi')
        ? const BoxDecoration(color: Color(0xFFFFF3CD))
        : null,
    children: values
        .map(
          (value) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: header ? FontWeight.w800 : FontWeight.normal,
              ),
            ),
          ),
        )
        .toList(),
  );

  String _number(double? value) => value == null
      ? '—'
      : (value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(1));

  String _change(double? value) {
    if (value == null) return '—';
    final direction = value > 0
        ? 'up'
        : value < 0
        ? 'down'
        : 'unchanged';
    return '${_number(value.abs())} ($direction)';
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

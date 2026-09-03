import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/body_composition_report.dart';
import '../services/api_service.dart';
import '../services/body_composition_comparison_presentation.dart';
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
    final comparedMetrics = comparison.metrics
        .where(BodyCompositionComparisonPresentation.isComparable)
        .toList(growable: false);
    final recordedOnceMetrics = comparison.metrics
        .where(
          (metric) =>
              !BodyCompositionComparisonPresentation.isComparable(metric),
        )
        .toList(growable: false);
    final olderDate = _date(comparison.olderReport.measuredAt);
    final newerDate = _date(comparison.newerReport.measuredAt);

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
          _periodCard(context, olderDate, newerDate),
          const SizedBox(height: 12),
          _atAGlanceCard(context),
          const SizedBox(height: 12),
          _bmiContextCard(context, olderDate, newerDate),
          const SizedBox(height: 24),
          _sectionHeading(
            context,
            'Measurements compared',
            comparedMetrics.isEmpty
                ? 'There are no measurements with values in both reports.'
                : 'Each card shows the earlier value, latest value, and exact change.',
          ),
          const SizedBox(height: 10),
          ...comparedMetrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _metricCard(
                context,
                metric: metric,
                olderDate: olderDate,
                newerDate: newerDate,
              ),
            ),
          ),
          if (recordedOnceMetrics.isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionHeading(
              context,
              'Recorded in one report only',
              'A change cannot be calculated until this measurement appears in both reports.',
            ),
            const SizedBox(height: 10),
            ...recordedOnceMetrics.map(
              (metric) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _metricCard(
                  context,
                  metric: metric,
                  olderDate: olderDate,
                  newerDate: newerDate,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'This comparison describes recorded changes only. It does not assess what is healthy or unhealthy for you.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _periodCard(BuildContext context, String olderDate, String newerDate) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison period',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.primary),
            ),
            const SizedBox(height: 6),
            Text(
              '$olderDate → $newerDate',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${comparison.elapsedDays} ${comparison.elapsedDays == 1 ? 'day' : 'days'} between measurements',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _atAGlanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'At a glance',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _summaryChip(
                  context,
                  '${BodyCompositionComparisonPresentation.comparableCount(comparison)} compared',
                ),
                _summaryChip(
                  context,
                  '${BodyCompositionComparisonPresentation.changedCount(comparison)} changed',
                ),
                if (BodyCompositionComparisonPresentation.unchangedCount(
                      comparison,
                    ) >
                    0)
                  _summaryChip(
                    context,
                    '${BodyCompositionComparisonPresentation.unchangedCount(comparison)} unchanged',
                  ),
                if (BodyCompositionComparisonPresentation.recordedOnceCount(
                      comparison,
                    ) >
                    0)
                  _summaryChip(
                    context,
                    '${BodyCompositionComparisonPresentation.recordedOnceCount(comparison)} recorded once',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _bmiContextCard(
    BuildContext context,
    String olderDate,
    String newerDate,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BMI context',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Reported and app-calculated BMI are shown separately so their sources stay clear.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            _bmiRow(
              context,
              label: 'Reported BMI',
              earlier: BodyCompositionComparisonPresentation.formatNumber(
                comparison.olderReport.measurements.reportedBmi,
              ),
              latest: BodyCompositionComparisonPresentation.formatNumber(
                comparison.newerReport.measurements.reportedBmi,
              ),
              olderDate: olderDate,
              newerDate: newerDate,
            ),
            const Divider(height: 24),
            _bmiRow(
              context,
              label: 'App-calculated BMI',
              earlier:
                  '${BodyCompositionComparisonPresentation.formatNumber(comparison.olderReport.calculatedBmi)}${comparison.olderReport.bmiBand == null ? '' : ' · ${comparison.olderReport.bmiBand}'}',
              latest:
                  '${BodyCompositionComparisonPresentation.formatNumber(comparison.newerReport.calculatedBmi)}${comparison.newerReport.bmiBand == null ? '' : ' · ${comparison.newerReport.bmiBand}'}',
              olderDate: olderDate,
              newerDate: newerDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bmiRow(
    BuildContext context, {
    required String label,
    required String earlier,
    required String latest,
    required String olderDate,
    required String newerDate,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _valueBlock(context, 'Earlier · $olderDate', earlier),
          ),
          const Icon(Icons.arrow_forward, size: 18),
          Expanded(child: _valueBlock(context, 'Latest · $newerDate', latest)),
        ],
      ),
    ],
  );

  Widget _sectionHeading(BuildContext context, String title, String detail) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      );

  Widget _metricCard(
    BuildContext context, {
    required BodyCompositionComparisonMetric metric,
    required String olderDate,
    required String newerDate,
  }) {
    final comparable = BodyCompositionComparisonPresentation.isComparable(
      metric,
    );
    final scheme = Theme.of(context).colorScheme;
    final relative =
        BodyCompositionComparisonPresentation.relativeChangeDescription(metric);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  comparable
                      ? Icons.compare_arrows_outlined
                      : Icons.info_outline,
                  size: 19,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metric.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (metric.unit.trim().isNotEmpty)
                  Text(
                    metric.unit,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _valueBlock(
                    context,
                    'Earlier · $olderDate',
                    BodyCompositionComparisonPresentation.formatValue(
                      metric.olderValue,
                      metric.unit,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _valueBlock(
                    context,
                    'Latest · $newerDate',
                    BodyCompositionComparisonPresentation.formatValue(
                      metric.newerValue,
                      metric.unit,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comparable ? 'Change from earlier' : 'Comparison status',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    BodyCompositionComparisonPresentation.changeDescription(
                      metric,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (relative != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      relative,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueBlock(BuildContext context, String label, String value) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );

  String _date(DateTime value) {
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
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }
}

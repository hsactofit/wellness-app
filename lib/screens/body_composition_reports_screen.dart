import 'package:flutter/material.dart';

import '../models/body_composition_report.dart';
import '../services/api_service.dart';
import '../services/body_composition_pdf_service.dart';
import 'body_composition_comparison_screen.dart';

/// Report Library: member-approved reports and persistent comparisons are
/// deliberately separate tabs so the source transcript is never confused
/// with a derived comparison.
class BodyCompositionReportsScreen extends StatefulWidget {
  const BodyCompositionReportsScreen({super.key});

  @override
  State<BodyCompositionReportsScreen> createState() =>
      _BodyCompositionReportsScreenState();
}

class _BodyCompositionReportsScreenState
    extends State<BodyCompositionReportsScreen> {
  late Future<List<BodyCompositionReport>> _reportsFuture;
  late Future<List<BodyCompositionComparison>> _comparisonsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _reportsFuture = ApiService.instance.fetchBodyCompositionReports();
    _comparisonsFuture = ApiService.instance.fetchBodyCompositionComparisons();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_reportsFuture, _comparisonsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report Library'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Health Reports'),
              Tab(text: 'Comparisons'),
            ],
          ),
        ),
        body: TabBarView(children: [_reportsTab(), _comparisonsTab()]),
      ),
    );
  }

  Widget _reportsTab() => FutureBuilder<List<BodyCompositionReport>>(
    future: _reportsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _message('Could not load your health reports', _refresh);
      }
      final reports = snapshot.data ?? [];
      if (reports.isEmpty) {
        return _message(
          'No health reports yet. Add one from Update Your Health.',
          null,
        );
      }
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _reportCard(reports[index]),
        ),
      );
    },
  );

  Widget _comparisonsTab() => FutureBuilder<List<BodyCompositionComparison>>(
    future: _comparisonsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _message('Could not load your comparisons', _refresh);
      }
      final comparisons = snapshot.data ?? [];
      if (comparisons.isEmpty) {
        return _message(
          'No comparisons yet. Choose Compare Reports to create one.',
          null,
        );
      }
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: comparisons.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final comparison = comparisons[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.compare_arrows_outlined),
                ),
                title: Text(
                  '${_date(comparison.olderReport.measuredAt)} → ${_date(comparison.newerReport.measuredAt)}',
                ),
                subtitle: Text(
                  '${comparison.metrics.length} metrics · ${comparison.elapsedDays} days elapsed',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BodyCompositionComparisonDetailScreen(
                      comparison: comparison,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );

  Widget _reportCard(BodyCompositionReport report) {
    final weight = report.measurements.weightKg;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
        title: Text(_date(report.measuredAt)),
        subtitle: Text(
          [
            _source(report.inputMethod),
            if (weight != null) '${_number(weight)} kg',
            if (report.calculatedBmi != null)
              'App BMI ${_number(report.calculatedBmi)}',
            if (report.memberCorrected) 'Member corrected',
          ].join(' · '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Download PDF',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await BodyCompositionPdfService.shareReport(report);
                } catch (error) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Could not create PDF: $error')),
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showDetail(report),
      ),
    );
  }

  void _showDetail(BodyCompositionReport report) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Health report · ${_date(report.measuredAt)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Download PDF',
                    onPressed: () =>
                        BodyCompositionPdfService.shareReport(report),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                ],
              ),
              Text(
                'Source: ${_source(report.inputMethod)}${report.memberCorrected ? ' · Values corrected before saving' : ''}',
              ),
              const SizedBox(height: 16),
              ..._metrics(report).map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.$1),
                  trailing: Text(
                    entry.$2,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const Divider(height: 32),
              const Text(
                'OCR transcript',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              SelectableText(
                report.ocrTranscript,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<(String, String)> _metrics(BodyCompositionReport report) {
    final m = report.measurements;
    return [
      if (m.weightKg != null) ('Weight', '${_number(m.weightKg)} kg'),
      if (m.reportedBmi != null) ('Reported BMI', _number(m.reportedBmi)),
      if (report.calculatedBmi != null)
        (
          'App BMI',
          '${_number(report.calculatedBmi)}${report.bmiBand == null ? '' : ' · ${report.bmiBand}'}',
        ),
      if (m.bodyFatPct != null) ('Body fat', '${_number(m.bodyFatPct)}%'),
      if (m.subcutaneousFatPct != null)
        ('Subcutaneous fat', '${_number(m.subcutaneousFatPct)}%'),
      if (m.visceralFatLevel != null)
        ('Visceral fat', _number(m.visceralFatLevel)),
      if (m.bodyWaterPct != null) ('Body water', '${_number(m.bodyWaterPct)}%'),
      if (m.skeletalMusclePct != null)
        ('Skeletal muscle', '${_number(m.skeletalMusclePct)}%'),
      if (m.muscleMassKg != null)
        ('Muscle mass', '${_number(m.muscleMassKg)} kg'),
      if (m.fatFreeBodyWeightKg != null)
        ('Fat-free weight', '${_number(m.fatFreeBodyWeightKg)} kg'),
      if (m.boneMassKg != null) ('Bone mass', '${_number(m.boneMassKg)} kg'),
      if (m.proteinPct != null) ('Protein', '${_number(m.proteinPct)}%'),
      if (m.bmrKcal != null) ('BMR', '${_number(m.bmrKcal)} kcal/day'),
      if (m.metabolicAgeYears != null)
        ('Metabolic age', '${_number(m.metabolicAgeYears)} years'),
      ...m.additionalMetrics.map(
        (entry) =>
            (entry.label, '${_number(entry.value)} ${entry.unit}'.trim()),
      ),
    ];
  }

  Widget _message(String text, Future<void> Function()? action) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monitor_weight_outlined, size: 52),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: action, child: const Text('Try Again')),
          ],
        ],
      ),
    ),
  );

  String _source(String method) => switch (method) {
    BodyCompositionInputMethod.pdfImport => 'PDF import',
    BodyCompositionInputMethod.screenshotImport => 'Screenshot import',
    _ => 'Camera scan',
  };

  String _number(double? value) => value == null
      ? '—'
      : (value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(1));
  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][value.month - 1]} ${value.year}';
}

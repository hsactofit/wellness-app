import 'package:flutter/material.dart';

import '../models/body_composition_report.dart';
import '../services/api_service.dart';

class BodyCompositionReportsScreen extends StatefulWidget {
  const BodyCompositionReportsScreen({super.key});

  @override
  State<BodyCompositionReportsScreen> createState() =>
      _BodyCompositionReportsScreenState();
}

class _BodyCompositionReportsScreenState
    extends State<BodyCompositionReportsScreen> {
  late Future<List<BodyCompositionReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = ApiService.instance.fetchBodyCompositionReports();
  }

  Future<void> _refresh() async {
    final future = ApiService.instance.fetchBodyCompositionReports();
    setState(() => _reportsFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Reports')),
      body: FutureBuilder<List<BodyCompositionReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _message(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load your reports',
              action: _refresh,
              actionLabel: 'Try Again',
            );
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return _message(
              icon: Icons.monitor_weight_outlined,
              title: 'No health reports yet',
              body:
                  'Scan a gym BMI or body-composition report from Update Your Health to save it here.',
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
      ),
    );
  }

  Widget _reportCard(BodyCompositionReport report) {
    final weight = report.measurements.weightKg;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
        title: Text(_dateLabel(report.measuredAt)),
        subtitle: Text(
          [
            if (weight != null) '${_format(weight)} kg',
            if (report.calculatedBmi != null)
              'BMI ${_format(report.calculatedBmi!)}',
            if (report.memberCorrected) 'Member corrected',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
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
          initialChildSize: 0.78,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Health report · ${_dateLabel(report.measuredAt)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (report.memberCorrected) ...[
                const SizedBox(height: 8),
                const Chip(label: Text('Values corrected before upload')),
              ],
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
    final items = <(String, String)>[
      if (m.weightKg != null) ('Weight', '${_format(m.weightKg!)} kg'),
      if (m.reportedBmi != null) ('Reported BMI', _format(m.reportedBmi!)),
      if (report.calculatedBmi != null)
        (
          'App BMI',
          '${_format(report.calculatedBmi!)}${report.bmiBand == null ? '' : ' · ${report.bmiBand}'}',
        ),
      if (m.bodyFatPct != null) ('Body fat', '${_format(m.bodyFatPct!)}%'),
      if (m.subcutaneousFatPct != null)
        ('Subcutaneous fat', '${_format(m.subcutaneousFatPct!)}%'),
      if (m.visceralFatLevel != null)
        ('Visceral fat', _format(m.visceralFatLevel!)),
      if (m.bodyWaterPct != null)
        ('Body water', '${_format(m.bodyWaterPct!)}%'),
      if (m.skeletalMusclePct != null)
        ('Skeletal muscle', '${_format(m.skeletalMusclePct!)}%'),
      if (m.muscleMassKg != null)
        ('Muscle mass', '${_format(m.muscleMassKg!)} kg'),
      if (m.fatFreeBodyWeightKg != null)
        ('Fat-free weight', '${_format(m.fatFreeBodyWeightKg!)} kg'),
      if (m.boneMassKg != null) ('Bone mass', '${_format(m.boneMassKg!)} kg'),
      if (m.proteinPct != null) ('Protein', '${_format(m.proteinPct!)}%'),
      if (m.bmrKcal != null) ('BMR', '${_format(m.bmrKcal!)} kcal/day'),
      if (m.metabolicAgeYears != null)
        ('Metabolic age', '${_format(m.metabolicAgeYears!)} years'),
    ];
    items.addAll(
      m.additionalMetrics.map(
        (entry) =>
            (entry.label, '${_format(entry.value)} ${entry.unit}'.trim()),
      ),
    );
    return items;
  }

  Widget _message({
    required IconData icon,
    required String title,
    String? body,
    Future<void> Function()? action,
    String? actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: action,
                child: Text(actionLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  String _dateLabel(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][value.month - 1]} ${value.year}';
}

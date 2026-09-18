import 'package:flutter/material.dart';

import '../models/body_composition_report.dart';
import '../services/api_service.dart';
import '../services/body_composition_pdf_service.dart';
import 'body_composition_comparison_screen.dart';
import 'body_composition_report_review_screen.dart';
import '../l10n/app_text.dart';
import '../app_brand.dart';
import 'face_scan_reports_screen.dart';

/// Report Library: member-approved reports and persistent comparisons are
/// deliberately separate tabs so the source transcript is never confused
/// with a derived comparison.
class BodyCompositionReportsScreen extends StatefulWidget {
  const BodyCompositionReportsScreen({
    super.key,
    this.loadReports,
    this.loadComparisons,
  });

  final Future<List<BodyCompositionReport>> Function()? loadReports;
  final Future<List<BodyCompositionComparison>> Function()? loadComparisons;

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
    _reportsFuture =
        widget.loadReports?.call() ??
        ApiService.instance.fetchBodyCompositionReports();
    _comparisonsFuture =
        widget.loadComparisons?.call() ??
        ApiService.instance.fetchBodyCompositionComparisons();
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_reportsFuture, _comparisonsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: AppBrand.faceScanEnabled ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: const AppText('Report Library'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Health Reports'),
              if (AppBrand.faceScanEnabled)
                const Tab(text: 'Face Scan Reports'),
              const Tab(text: 'Comparisons'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _reportsTab(),
            if (AppBrand.faceScanEnabled) _faceScanTab(),
            _comparisonsTab(),
          ],
        ),
      ),
    );
  }

  Widget _faceScanTab() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.face_retouching_natural, size: 52),
              const SizedBox(height: 12),
              const AppText(
                'View saved camera-derived vital estimates, processing status, corrections, PDFs, and clinic sharing.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FaceScanReportsScreen(),
                  ),
                ),
                icon: const Icon(Icons.folder_copy_outlined),
                label: const AppText('Open Face Scan Reports'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

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
                title: AppText(
                  '${_date(comparison.olderReport.measuredAt)} → ${_date(comparison.newerReport.measuredAt)}',
                ),
                subtitle: AppText(
                  '${comparison.metrics.length} metrics · ${comparison.elapsedDays} days elapsed',
                ),
                trailing: PopupMenuButton<_ComparisonAction>(
                  tooltip: 'Comparison actions'.localized(context),
                  onSelected: (action) {
                    switch (action) {
                      case _ComparisonAction.edit:
                        _editComparison(comparison);
                      case _ComparisonAction.delete:
                        _deleteComparison(comparison);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _ComparisonAction.edit,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: AppText('Edit comparison'),
                      ),
                    ),
                    PopupMenuItem(
                      value: _ComparisonAction.delete,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: AppText('Delete comparison'),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BodyCompositionComparisonDetailScreen(
                        comparison: comparison,
                      ),
                    ),
                  );
                  if (mounted) await _refresh();
                },
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
        title: AppText(_date(report.measuredAt)),
        subtitle: AppText(
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
              tooltip: 'Download PDF'.localized(context),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await BodyCompositionPdfService.shareReport(report);
                } catch (error) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: AppText('Could not create PDF: $error')),
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

  Future<void> _showDetail(BodyCompositionReport report) async {
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
                    child: AppText(
                      'Health report · ${_date(report.measuredAt)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit report'.localized(context),
                    onPressed: () => _editReport(context, report),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete report'.localized(context),
                    onPressed: () => _deleteReport(context, report),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    tooltip: 'Download PDF'.localized(context),
                    onPressed: () =>
                        BodyCompositionPdfService.shareReport(report),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                ],
              ),
              AppText(
                'Source: ${_source(report.inputMethod)}${report.memberCorrected ? ' · Values corrected before saving' : ''}',
              ),
              const SizedBox(height: 16),
              ..._metrics(report).map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: AppText(entry.$1),
                  trailing: AppText(
                    entry.$2,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const Divider(height: 32),
              const AppText(
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

  Future<void> _editReport(
    BuildContext sheetContext,
    BodyCompositionReport report,
  ) async {
    Navigator.of(sheetContext).pop();
    final updated = await Navigator.of(context).push<BodyCompositionReport>(
      MaterialPageRoute(
        builder: (_) => BodyCompositionReportReviewScreen(
          draft: BodyCompositionDraft(
            clientSubmissionId: report.clientSubmissionId,
            measuredAt: report.measuredAt,
            ocrTranscript: report.ocrTranscript,
            measurements: report.measurements,
            inputMethod: report.inputMethod,
          ),
          existingReport: report,
        ),
      ),
    );
    if (updated == null || !mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: AppText('Health report updated.')));
  }

  Future<void> _deleteReport(
    BuildContext sheetContext,
    BodyCompositionReport report,
  ) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Delete health report?'),
        content: const AppText(
          'This permanently deletes the report and any comparisons that use it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const AppText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const AppText('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.instance.deleteBodyCompositionReport(report.id);
      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AppText('Health report deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText('Could not delete the report: $error')),
      );
    }
  }

  Future<void> _editComparison(BodyCompositionComparison comparison) async {
    final updated = await editBodyCompositionComparisonReports(
      context,
      comparison,
    );
    if (updated == null || !mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: AppText('Comparison updated.')));
  }

  Future<void> _deleteComparison(BodyCompositionComparison comparison) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppText('Delete comparison?'),
        content: const AppText(
          'This permanently deletes the saved comparison. Your health reports will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const AppText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const AppText('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ApiService.instance.deleteBodyCompositionComparison(comparison.id);
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: AppText('Comparison deleted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText('Could not delete the comparison: $error')),
      );
    }
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
          AppText(text, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: action, child: const AppText('Try Again')),
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

enum _ComparisonAction { edit, delete }

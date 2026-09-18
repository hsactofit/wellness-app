import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../l10n/app_text.dart';
import '../models/face_scan.dart';
import '../services/api_service.dart';

class FaceScanReportsScreen extends StatefulWidget {
  const FaceScanReportsScreen({super.key});

  @override
  State<FaceScanReportsScreen> createState() => _FaceScanReportsScreenState();
}

class _FaceScanReportsScreenState extends State<FaceScanReportsScreen> {
  bool _loading = true;
  bool _sharing = false;
  String? _clinicName;
  String? _error;
  List<FaceScanReport> _reports = const [];
  List<FaceScanJob> _jobs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        ApiService.instance.fetchFaceScanConsent(),
        ApiService.instance.fetchFaceScanReports(),
        ApiService.instance.fetchFaceScanJobs(),
      ]);
      if (!mounted) return;
      final consent = results[0] as FaceScanConsent;
      setState(() {
        _sharing = consent.sharingGranted;
        _clinicName = consent.clinicName;
        _reports = results[1] as List<FaceScanReport>;
        _jobs = results[2] as List<FaceScanJob>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleSharing(bool value) async {
    final previous = _sharing;
    setState(() => _sharing = value);
    try {
      final consent = await ApiService.instance.updateFaceScanConsent(
        'clinic_sharing',
        value,
      );
      if (!mounted) return;
      setState(() {
        _sharing = consent.sharingGranted;
        _clinicName = consent.clinicName;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _sharing = previous);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText(error.toString())));
    }
  }

  Future<void> _download(FaceScanReport report) async {
    try {
      final bytes = await ApiService.instance.downloadFaceScanPdf(report.id);
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'mednovations-face-scan-${report.capturedAt.toIso8601String().substring(0, 10)}.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText(error.toString())));
    }
  }

  Future<void> _delete(FaceScanReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('Delete Face Scan report?'),
        content: const AppText(
          'This removes the report and its edit history from the app and clinic dashboard. PDFs already downloaded by you or your clinic cannot be recalled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const AppText('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const AppText('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ApiService.instance.deleteFaceScanReport(report.id);
    await _load();
  }

  Future<void> _edit(FaceScanReport report) async {
    final updated = await showDialog<FaceScanReport>(
      context: context,
      builder: (_) => _FaceScanEditDialog(report: report),
    );
    if (updated != null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final activeJobs = _jobs.where((job) => !job.terminal).toList();
    return Scaffold(
      appBar: AppBar(title: const AppText('Face Scan Reports')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Card(
              child: SwitchListTile(
                value: _sharing,
                onChanged: _toggleSharing,
                title: const AppText('Share Face Scan reports with my clinic'),
                subtitle: AppText(
                  _sharing
                      ? 'Existing and future reports, notes, and corrections are shared with ${_clinicName ?? 'your assigned clinic'}. You can revoke access anytime.'
                      : 'Optional. Your assigned Clinic Manager will not see these reports until you enable sharing.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const AppText(
              'Camera-derived estimates are for wellness screening and are not a medical diagnosis.',
              style: TextStyle(fontSize: 12),
            ),
            if (_loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: AppText(_error!),
                ),
              ),
            ],
            for (final _ in activeJobs) ...[
              const SizedBox(height: 12),
              const Card(
                child: ListTile(
                  leading: CircularProgressIndicator(),
                  title: AppText('Creating your Face Scan report…'),
                  subtitle: AppText(
                    'Processing continues securely. Pull down to refresh.',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            for (final report in _reports)
              _ReportCard(
                report: report,
                onEdit: () => _edit(report),
                onDownload: () => _download(report),
                onDelete: () => _delete(report),
              ),
            if (!_loading && _reports.isEmpty && activeJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.face_retouching_natural, size: 52),
                    SizedBox(height: 12),
                    AppText('No Face Scan reports yet.'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onEdit,
    required this.onDownload,
    required this.onDelete,
  });

  final FaceScanReport report;
  final VoidCallback onEdit;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final values = report.effectiveValues;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.monitor_heart_outlined)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        report.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        report.capturedAt.toString().substring(0, 16),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (report.memberEdited)
                  const Chip(label: AppText('Edited by member')),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metric(
                  context,
                  'Heart rate',
                  values.heartRate,
                  report.originalValues.heartRate,
                  report.correctedValues.heartRate != null,
                  'bpm',
                ),
                _metric(
                  context,
                  'Breathing',
                  values.respiratoryRate,
                  report.originalValues.respiratoryRate,
                  report.correctedValues.respiratoryRate != null,
                  'breaths/min',
                ),
                _metric(
                  context,
                  'SpO₂',
                  values.spo2,
                  report.originalValues.spo2,
                  report.correctedValues.spo2 != null,
                  '%',
                ),
                _metric(
                  context,
                  'Systolic BP',
                  values.systolicBp,
                  report.originalValues.systolicBp,
                  report.correctedValues.systolicBp != null,
                  'mmHg',
                ),
                _metric(
                  context,
                  'Diastolic BP',
                  values.diastolicBp,
                  report.originalValues.diastolicBp,
                  report.correctedValues.diastolicBp != null,
                  'mmHg',
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppText(
              'Signal quality: ${report.quality['summary'] ?? 'Not supplied'}',
              style: const TextStyle(fontSize: 12),
            ),
            if (report.correctedAt != null)
              AppText(
                'Corrected ${report.correctedAt.toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 12),
              ),
            if (report.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              AppText(report.notes!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const AppText('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const AppText('PDF'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete'.localized(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    String label,
    double? value,
    double? original,
    bool edited,
    String unit,
  ) => Container(
    width: 145,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.blueGrey.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value == null
              ? 'Unavailable'.localized(context)
              : '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        if (edited)
          AppText(
            'Original: ${original == null ? 'Unavailable' : '${original.toStringAsFixed(1)} $unit'}',
            style: const TextStyle(fontSize: 10),
          ),
      ],
    ),
  );
}

class _FaceScanEditDialog extends StatefulWidget {
  const _FaceScanEditDialog({required this.report});

  final FaceScanReport report;

  @override
  State<_FaceScanEditDialog> createState() => _FaceScanEditDialogState();
}

class _FaceScanEditDialogState extends State<_FaceScanEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _reason;
  late final Map<String, TextEditingController> _values;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final corrected = widget.report.correctedValues;
    _title = TextEditingController(text: widget.report.title);
    _notes = TextEditingController(text: widget.report.notes ?? '');
    _reason = TextEditingController();
    _values = {
      'heart': TextEditingController(text: _text(corrected.heartRate)),
      'respiratory': TextEditingController(
        text: _text(corrected.respiratoryRate),
      ),
      'spo2': TextEditingController(text: _text(corrected.spo2)),
      'systolic': TextEditingController(text: _text(corrected.systolicBp)),
      'diastolic': TextEditingController(text: _text(corrected.diastolicBp)),
    };
  }

  String _text(double? value) => value?.toString() ?? '';
  double? _number(String key) => double.tryParse(_values[key]!.text.trim());

  Future<void> _save() async {
    final corrected = FaceScanValues(
      heartRate: _number('heart'),
      respiratoryRate: _number('respiratory'),
      spo2: _number('spo2'),
      systolicBp: _number('systolic'),
      diastolicBp: _number('diastolic'),
    );
    final changed =
        corrected.toJson().toString() !=
        widget.report.correctedValues.toJson().toString();
    if (changed && _reason.text.trim().isEmpty) {
      setState(() => _error = 'Explain why you corrected the scan values.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await ApiService.instance.updateFaceScanReport(
        report: widget.report,
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        correctedValues: corrected,
        correctionReason: changed ? _reason.text.trim() : null,
      );
      if (mounted) Navigator.pop(context, updated);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _reason.dispose();
    for (final controller in _values.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const AppText('Edit Face Scan report'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: 'Report title'.localized(context),
                ),
              ),
              TextField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes'.localized(context),
                ),
              ),
              const SizedBox(height: 12),
              const AppText(
                'Leave a correction blank to use the original scan estimate.',
              ),
              for (final entry in const [
                ('heart', 'Heart rate correction (bpm)'),
                ('respiratory', 'Respiratory rate correction'),
                ('spo2', 'SpO₂ correction (%)'),
                ('systolic', 'Systolic BP correction (mmHg)'),
                ('diastolic', 'Diastolic BP correction (mmHg)'),
              ])
                TextField(
                  controller: _values[entry.$1],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(labelText: entry.$2),
                ),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Reason for value corrections'.localized(context),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const AppText('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: AppText(_saving ? 'Saving…' : 'Save'),
        ),
      ],
    );
  }
}

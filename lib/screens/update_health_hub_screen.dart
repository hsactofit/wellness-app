import 'package:flutter/material.dart';

import '../models/body_composition_report.dart';
import '../services/body_composition_import_service.dart';
import '../services/camera_permission_gate.dart';
import 'body_composition_reports_screen.dart';
import 'body_composition_report_review_screen.dart';
import 'body_composition_comparison_screen.dart';
import 'update_health_camera_screen.dart';

/// The single entry point for report updates. Every source ends at the same
/// member review screen before anything is saved.
class UpdateHealthHubScreen extends StatefulWidget {
  const UpdateHealthHubScreen({super.key});

  @override
  State<UpdateHealthHubScreen> createState() => _UpdateHealthHubScreenState();
}

class _UpdateHealthHubScreenState extends State<UpdateHealthHubScreen> {
  bool _busy = false;

  Future<void> _scan() async {
    final gate = CameraPermissionGate();
    final permission = await gate.ensure();
    if (!mounted) return;
    if (permission != CameraPermissionResult.granted) {
      if (permission == CameraPermissionResult.permanentlyDenied) {
        await gate.openSettings();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera access is required to scan a body-composition report.',
          ),
        ),
      );
      return;
    }
    final draft = await Navigator.of(context).push<BodyCompositionDraft>(
      MaterialPageRoute(builder: (_) => const UpdateHealthCameraScreen()),
    );
    await _review(draft);
  }

  Future<void> _importScreenshot() async {
    await _runImport(BodyCompositionImportService.instance.pickScreenshot);
  }

  Future<void> _importPdf() async {
    await _runImport(BodyCompositionImportService.instance.pickPdf);
  }

  Future<void> _runImport(
    Future<BodyCompositionDraft?> Function() importer,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final draft = await importer();
      if (mounted) await _review(draft);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(BodyCompositionDraft? draft) async {
    if (draft == null || !mounted) return;
    final report = await Navigator.of(context).push<BodyCompositionReport>(
      MaterialPageRoute(
        builder: (_) => BodyCompositionReportReviewScreen(draft: draft),
      ),
    );
    if (report != null && mounted) Navigator.of(context).pop(report);
  }

  Future<void> _compare() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BodyCompositionComparisonScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Your Health'),
        actions: [
          IconButton(
            tooltip: 'Report Library',
            icon: const Icon(Icons.folder_copy_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BodyCompositionReportsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text(
              'Choose how you want to add a body-composition report.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Text is read securely on this device. You can edit every value before approving and saving it.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            _Option(
              icon: Icons.document_scanner_outlined,
              title: 'Scan Report',
              subtitle: 'Use the camera to scan a gym report.',
              onTap: _busy ? null : _scan,
            ),
            _Option(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Import PDF',
              subtitle: 'Read a PDF up to 10 MB and five pages.',
              onTap: _busy ? null : _importPdf,
            ),
            _Option(
              icon: Icons.image_outlined,
              title: 'Import Screenshot',
              subtitle: 'Choose a WhatsApp or gallery screenshot.',
              onTap: _busy ? null : _importScreenshot,
            ),
            _Option(
              icon: Icons.compare_arrows_outlined,
              title: 'Compare Reports',
              subtitle: 'Compare any two saved body-composition reports.',
              onTap: _busy ? null : _compare,
            ),
            if (_busy) ...[
              const SizedBox(height: 18),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

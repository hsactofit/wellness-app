import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/facility_booking_service.dart';
import '../services/workout_report_pdf_service.dart';
import '../services/workout_report_presentation.dart';
import '../widgets/glass_card.dart';

class WorkoutReportsScreen extends StatefulWidget {
  const WorkoutReportsScreen({super.key, this.loadReports});

  final Future<List<WorkoutReport>> Function()? loadReports;

  @override
  State<WorkoutReportsScreen> createState() => _WorkoutReportsScreenState();
}

class _WorkoutReportsScreenState extends State<WorkoutReportsScreen> {
  List<WorkoutReport> _reports = const [];
  Object? _error;
  bool _loading = true;
  Timer? _refreshTimer;

  Future<List<WorkoutReport>> _load() =>
      widget.loadReports?.call() ??
      FacilityBookingService.instance.workoutReports();

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _loading = true);
    try {
      final reports = await _load();
      reports.sort(_newestFirst);
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _error = null;
        _loading = false;
      });
      _configureAutoRefresh(reports);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
      _refreshTimer?.cancel();
    }
  }

  int _newestFirst(WorkoutReport a, WorkoutReport b) {
    final aDate =
        a.checkOutAt ??
        a.checkInAt ??
        a.generatedAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final bDate =
        b.checkOutAt ??
        b.checkInAt ??
        b.generatedAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  }

  void _configureAutoRefresh(List<WorkoutReport> reports) {
    _refreshTimer?.cancel();
    if (!reports.any((report) => report.isPreparing)) return;
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => unawaited(_refresh(showLoading: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorState()
          : RefreshIndicator(
              onRefresh: () => _refresh(showLoading: false),
              child: _reports.isEmpty ? _emptyState() : _reportsList(),
            ),
    );
  }

  Widget _emptyState() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(24),
    children: const [
      SizedBox(height: 90),
      Icon(Icons.insights_outlined, size: 54),
      SizedBox(height: 16),
      Text(
        'No workout reports yet',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 8),
      Text(
        'Complete a Gym Access workout to see your checklist, session facts, and estimated workout insights here.',
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _errorState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Could not load workout reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );

  Widget _reportsList() => ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
    itemCount: _reports.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) => _reportCard(_reports[index]),
  );

  Widget _reportCard(WorkoutReport report) {
    final facts = WorkoutReportPresentation.factsFor(report);
    final ready = report.isComplete;
    final statusColor = ready
        ? Colors.green
        : report.isPreparing
        ? Colors.orange
        : Colors.redAccent;
    return GlassCard(
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.14),
            foregroundColor: statusColor,
            child: Icon(
              ready ? Icons.insights_outlined : Icons.hourglass_top_outlined,
            ),
          ),
          title: Text(
            report.facilityName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_date(report.checkOutAt ?? report.checkInAt ?? report.generatedAt)} - ${_duration(report.durationMin)}\n${ready ? _readySummary(report, facts) : WorkoutReportPresentation.statusDescription(report)}',
            ),
          ),
          isThreeLine: true,
          trailing: ready
              ? const Icon(Icons.chevron_right)
              : Chip(
                  label: Text(WorkoutReportPresentation.statusLabel(report)),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  backgroundColor: statusColor.withValues(alpha: 0.10),
                  side: BorderSide.none,
                ),
          onTap: ready
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutReportDetailScreen(report: report),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _readySummary(WorkoutReport report, WorkoutReportFacts facts) {
    final progress = facts.completionPct == null
        ? 'No checklist'
        : '${facts.completionPct!.round()}% complete';
    final calories = report.calories == null
        ? 'estimate pending'
        : '${report.calories} kcal estimated';
    return '$progress - $calories';
  }

  String _duration(int? minutes) =>
      minutes == null ? 'Not recorded' : '$minutes min';

  String _date(DateTime? value) {
    if (value == null) return 'Date not recorded';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class WorkoutReportDetailScreen extends StatelessWidget {
  const WorkoutReportDetailScreen({super.key, required this.report});

  final WorkoutReport report;

  @override
  Widget build(BuildContext context) {
    final facts = WorkoutReportPresentation.factsFor(report);
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Report')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          _hero(context),
          const SizedBox(height: 16),
          _sectionTitle(context, 'At a glance'),
          const SizedBox(height: 8),
          _stats(context, facts),
          if (facts.hasChecklist) ...[
            const SizedBox(height: 20),
            _sectionTitle(context, 'Workout progress'),
            const SizedBox(height: 8),
            _progress(context, facts),
          ],
          const SizedBox(height: 20),
          _sectionTitle(context, 'Today\'s checklist'),
          const SizedBox(height: 8),
          if (!facts.hasChecklist)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No workout checklist was assigned for this session.',
                ),
              ),
            )
          else
            ...facts.items.map((item) => _checklistItem(context, item)),
          if (_hasText(report.summary) || _hasText(report.recoveryNote)) ...[
            const SizedBox(height: 20),
            _sectionTitle(context, 'Tarqa workout insight'),
            const SizedBox(height: 8),
            if (_hasText(report.summary))
              _insight(context, 'Session summary', report.summary!),
            if (_hasText(report.recoveryNote)) ...[
              const SizedBox(height: 8),
              _insight(context, 'Recovery note', report.recoveryNote!),
            ],
          ],
          const SizedBox(height: 18),
          const Text(
            'Estimated calories, intensity, summary, and recovery guidance are AI-generated estimates from this session\'s duration and workout plan. They are not medical advice.',
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _download(context),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPLETED WORKOUT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          report.facilityName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          '${_date(report.checkOutAt ?? report.checkInAt ?? report.generatedAt)} - ${_duration(report.durationMin)}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );

  Widget _stats(BuildContext context, WorkoutReportFacts facts) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      _stat(
        context,
        Icons.timer_outlined,
        'Duration',
        _duration(report.durationMin),
      ),
      _stat(
        context,
        Icons.local_fire_department_outlined,
        'Estimated calories',
        report.calories == null ? 'Pending' : '${report.calories} kcal',
      ),
      _stat(
        context,
        Icons.speed_outlined,
        'Intensity',
        report.intensity ?? 'Pending',
      ),
      _stat(
        context,
        Icons.task_alt_outlined,
        'Completion',
        facts.completionPct == null
            ? 'No checklist'
            : '${facts.completionPct!.round()}%',
      ),
    ],
  );

  Widget _stat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 42) / 2,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ),
  );

  Widget _progress(BuildContext context, WorkoutReportFacts facts) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 126,
            height: 126,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(126),
                  painter: _CompletionRingPainter(facts.completionPct! / 100),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${facts.completionPct!.round()}%',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'complete',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${facts.completedCount} of ${facts.items.length} exercises completed',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _progressBar(facts),
                const SizedBox(height: 9),
                _legend(
                  context,
                  Colors.green,
                  'Completed',
                  facts.completedCount,
                ),
                const SizedBox(height: 5),
                _legend(
                  context,
                  Colors.blueGrey.shade200,
                  'Not completed',
                  facts.notCompletedCount,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _progressBar(WorkoutReportFacts facts) => LayoutBuilder(
    builder: (context, constraints) => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          if (facts.completedCount > 0)
            SizedBox(
              width:
                  constraints.maxWidth *
                  facts.completedCount /
                  facts.items.length,
              height: 14,
              child: const ColoredBox(color: Colors.green),
            ),
          if (facts.notCompletedCount > 0)
            SizedBox(
              width:
                  constraints.maxWidth *
                  facts.notCompletedCount /
                  facts.items.length,
              height: 14,
              child: ColoredBox(color: Colors.blueGrey.shade200),
            ),
        ],
      ),
    ),
  );

  Widget _legend(BuildContext context, Color color, String label, int count) =>
      Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text('$label: $count', style: Theme.of(context).textTheme.bodySmall),
        ],
      );

  Widget _checklistItem(
    BuildContext context,
    WorkoutReportChecklistItem item,
  ) => Card(
    child: ListTile(
      leading: Icon(
        item.completed ? Icons.check_circle : Icons.radio_button_unchecked,
        color: item.completed ? Colors.green : Colors.grey,
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: item.details.isEmpty
          ? Text(item.completed ? 'Completed' : 'Not completed')
          : Text(
              '${item.completed ? 'Completed' : 'Not completed'} - ${item.details}',
            ),
    ),
  );

  Widget _insight(BuildContext context, String label, String value) => Card(
    color: Theme.of(
      context,
    ).colorScheme.primaryContainer.withValues(alpha: 0.35),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(height: 1.35)),
        ],
      ),
    ),
  );

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
  );

  Future<void> _download(BuildContext context) async {
    try {
      await WorkoutReportPdfService.shareReport(report);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not create PDF: $error')));
      }
    }
  }

  static bool _hasText(String? value) => value?.trim().isNotEmpty == true;
  static String _duration(int? minutes) =>
      minutes == null ? 'Not recorded' : '$minutes min';
  static String _date(DateTime? value) {
    if (value == null) return 'Date not recorded';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _CompletionRingPainter extends CustomPainter {
  const _CompletionRingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.blueGrey.shade200;
    final value = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.green;
    canvas.drawCircle(center, radius, track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0, 1),
        false,
        value,
      );
    }
  }

  @override
  bool shouldRepaint(_CompletionRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

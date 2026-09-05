import 'package:flutter/material.dart';

import '../models/weekly_training.dart';
import '../services/api_service.dart';
import 'glass_card.dart';

const _trainingTypes = <String>[
  'strength',
  'cardio',
  'mobility',
  'yoga',
  'hiit',
  'sports',
  'recovery',
  'other',
];
const _reasons = <String, String>{
  'device_sync_error': 'Device sync error',
  'manual_measurement': 'Manual measurement',
  'missed_check_in': 'Missed check-in',
  'wrong_workout_type': 'Wrong workout type',
  'duplicate_or_incorrect_session': 'Duplicate or incorrect session',
  'other': 'Other',
};

class WeeklyTrainingSummarySection extends StatelessWidget {
  const WeeklyTrainingSummarySection({
    super.key,
    required this.summary,
    required this.loading,
    required this.onRefresh,
  });

  final WeeklyTrainingSummary? summary;
  final bool loading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final data = summary;
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: GlassCard(
          child: Semantics(
            liveRegion: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly training',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  loading
                      ? 'Loading your plan-aware weekly summary…'
                      : 'Weekly training is unavailable. Your existing health data is still safe.',
                ),
                if (!loading)
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          _ConsistencyCard(summary: data, onRefresh: onRefresh),
          const SizedBox(height: 12),
          _TrainingTypeCard(summary: data, onRefresh: onRefresh),
          const SizedBox(height: 12),
          _RecoveryCard(summary: data, onRefresh: onRefresh),
        ],
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.title,
    required this.subtitle,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      Semantics(
        button: true,
        label: 'Edit $title',
        child: TextButton(onPressed: onEdit, child: const Text('Edit')),
      ),
    ],
  );
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard({required this.summary, required this.onRefresh});

  final WeeklyTrainingSummary summary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            title: 'Consistency',
            subtitle: _consistencySubtitle(summary),
            onEdit: () => _showWorkoutEditor(context, summary, onRefresh),
          ),
          const SizedBox(height: 4),
          Row(
            children: summary.days
                .map((day) => Expanded(child: _DayTile(day: day)))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day});

  final WeeklyTrainingDay day;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (day.state) {
      'completed' => (const Color(0xFF1976D2), Icons.check_rounded),
      'missed' => (const Color(0xFFC75A5A), Icons.close_rounded),
      'future' => (const Color(0xFF77839A), Icons.more_horiz_rounded),
      'extra' => (const Color(0xFF139B70), Icons.add_rounded),
      _ => (const Color(0xFF596273), Icons.bedtime_outlined),
    };
    final label = day.state.replaceAll('_', ' ');
    return Semantics(
      label:
          '${day.weekday}: $label${day.memberEntered ? ', member-entered' : ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 20)),
            ),
            const SizedBox(height: 5),
            Text(
              day.weekday.isEmpty ? '?' : day.weekday.substring(0, 1),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (day.memberEntered)
              const Icon(
                Icons.edit_note_rounded,
                size: 13,
                semanticLabel: 'Member-entered',
              ),
          ],
        ),
      ),
    );
  }
}

class _TrainingTypeCard extends StatelessWidget {
  const _TrainingTypeCard({required this.summary, required this.onRefresh});

  final WeeklyTrainingSummary summary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final largest = summary.trainingTypes.fold<int>(
      1,
      (max, item) => item.count > max ? item.count : max,
    );
    return GlassCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CardHeading(
                  title: 'How you trained',
                  subtitle: 'Included sessions by type',
                  onEdit: () => _showWorkoutEditor(context, summary, onRefresh),
                ),
              ),
              Text(
                '${summary.totalIncludedSessions}',
                style: TextStyle(
                  fontSize: 26,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (summary.trainingTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('No completed sessions yet this week.'),
            )
          else
            ...summary.trainingTypes.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: Text(
                        _title(item.type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        label: '${_title(item.type)}, ${item.count} sessions',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: item.count / largest,
                            minHeight: 13,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.count}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.summary, required this.onRefresh});

  final WeeklyTrainingSummary summary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => GlassCard(
    margin: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeading(
          title: 'Body & recovery',
          subtitle: 'Synced device data and your corrections',
          onEdit: () => _showHealthEditor(context, summary, onRefresh),
        ),
        const SizedBox(height: 8),
        _MetricRow(
          label: 'Weight',
          metric: summary.weight,
          valueFormatter: (value) => '${value.toStringAsFixed(1)} kg',
        ),
        const Divider(height: 28),
        _MetricRow(
          label: 'Resting heart rate',
          metric: summary.restingHeartRate,
          valueFormatter: (value) => '${value.round()} bpm',
        ),
        const Divider(height: 28),
        _MetricRow(
          label: 'Sleep',
          metric: summary.sleep,
          valueFormatter: _sleepLabel,
        ),
      ],
    ),
  );
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.metric,
    required this.valueFormatter,
  });

  final String label;
  final WeeklyMetric metric;
  final String Function(double value) valueFormatter;

  @override
  Widget build(BuildContext context) {
    final delta = metric.delta;
    final deltaLabel = delta == null
        ? 'No comparison yet'
        : '${delta > 0 ? '+' : ''}${_delta(delta, metric.unit)} vs previous 7 days';
    return Semantics(
      label:
          '$label: ${metric.value == null ? 'No synced data' : valueFormatter(metric.value!)}. $deltaLabel.',
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.value == null ? 'No synced data' : metric.displayBasis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (metric.activeCorrectionId != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: _MemberEnteredBadge(),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            height: 35,
            child: CustomPaint(
              painter: _SparklinePainter(
                metric.sparkline,
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  metric.value == null ? '—' : valueFormatter(metric.value!),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  deltaLabel,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberEnteredBadge extends StatelessWidget {
  const _MemberEnteredBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      'Member-entered',
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.points, this.color);

  final List<WeeklyMetricPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final values = points.map((point) => point.value).toList();
    final minimum = values.reduce((a, b) => a < b ? a : b);
    final maximum = values.reduce((a, b) => a > b ? a : b);
    final span = maximum - minimum == 0 ? 1 : maximum - minimum;
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final y =
          size.height -
          ((values[index] - minimum) / span * (size.height - 4)) -
          2;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

Future<void> _showWorkoutEditor(
  BuildContext context,
  WeeklyTrainingSummary summary,
  Future<void> Function() onRefresh,
) async {
  var selectedDate = summary.asOf;
  var selectedType = 'strength';
  var selectedReason = 'missed_check_in';
  var otherExplanation = '';
  final duration = TextEditingController();
  var saving = false;
  String? error;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit weekly workouts',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'These changes affect only your personal summary. They never change facility attendance, your approved plan, reports, rewards, challenges, or staff metrics.',
                ),
                const SizedBox(height: 16),
                _DateButton(
                  date: selectedDate,
                  first: summary.weekStart,
                  last: summary.asOf,
                  onSelected: (value) =>
                      setSheetState(() => selectedDate = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Training type'),
                  items: _trainingTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_title(type)),
                        ),
                      )
                      .toList(),
                  onChanged: saving
                      ? null
                      : (value) => setSheetState(
                          () => selectedType = value ?? 'other',
                        ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: duration,
                  enabled: !saving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration in minutes (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                _ReasonFields(
                  reason: selectedReason,
                  explanation: otherExplanation,
                  enabled: !saving,
                  onReason: (value) =>
                      setSheetState(() => selectedReason = value),
                  onExplanation: (value) => otherExplanation = value,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          if (selectedReason == 'other' &&
                              otherExplanation.trim().isEmpty) {
                            setSheetState(
                              () =>
                                  error = 'Add a short explanation for Other.',
                            );
                            return;
                          }
                          setSheetState(() {
                            saving = true;
                            error = null;
                          });
                          try {
                            await ApiService.instance
                                .createWeeklyTrainingCorrection({
                                  'kind': 'manual_workout',
                                  'effective_date': _dateText(selectedDate),
                                  'training_type': selectedType,
                                  'duration_minutes': int.tryParse(
                                    duration.text.trim(),
                                  ),
                                  'reason': selectedReason,
                                  'explanation': selectedReason == 'other'
                                      ? otherExplanation.trim()
                                      : null,
                                  'expected_correction_id': null,
                                });
                            if (context.mounted) Navigator.pop(context);
                            await onRefresh();
                          } catch (exception) {
                            setSheetState(() {
                              saving = false;
                              error = _friendlyError(exception);
                            });
                          }
                        },
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: const Text('Add missing workout'),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (summary.includedSessions.isNotEmpty) ...[
                  const Divider(height: 30),
                  const Text(
                    'Edit a completed session',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  ...summary.includedSessions.map(
                    (session) => _SessionCorrectionRow(
                      session: session,
                      summary: summary,
                      onRefresh: onRefresh,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
  duration.dispose();
}

class _SessionCorrectionRow extends StatelessWidget {
  const _SessionCorrectionRow({
    required this.session,
    required this.summary,
    required this.onRefresh,
  });

  final IncludedTrainingSession session;
  final WeeklyTrainingSummary summary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 8),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_title(session.type)} · ${_dateText(session.date)}'),
                if (session.memberEntered)
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: _MemberEnteredBadge(),
                  ),
              ],
            ),
          ),
          if (session.id != null)
            PopupMenuButton<String>(
              onSelected: (action) => _correctOfficialSession(
                context,
                action,
                session,
                summary,
                onRefresh,
              ),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'reclassify', child: Text('Change type')),
                PopupMenuItem(
                  value: 'exclude',
                  child: Text('Hide from my summary'),
                ),
              ],
            )
          else if (session.correctionId != null)
            PopupMenuButton<String>(
              onSelected: (action) => action == 'edit'
                  ? _editMemberWorkout(context, session, summary, onRefresh)
                  : _undo(context, session.correctionId!, onRefresh),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit workout')),
                PopupMenuItem(value: 'remove', child: Text('Remove')),
              ],
            ),
        ],
      ),
    ),
  );
}

Future<void> _correctOfficialSession(
  BuildContext context,
  String action,
  IncludedTrainingSession session,
  WeeklyTrainingSummary summary,
  Future<void> Function() onRefresh,
) async {
  var type = session.type;
  var reason = action == 'exclude'
      ? 'duplicate_or_incorrect_session'
      : 'wrong_workout_type';
  var explanation = '';
  var saving = false;
  String? error;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(
          action == 'exclude' ? 'Hide this session?' : 'Change session type',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This affects only your personal weekly summary; the official facility session stays unchanged.',
              ),
              if (action == 'reclassify') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: _trainingTypes
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry,
                          child: Text(_title(entry)),
                        ),
                      )
                      .toList(),
                  onChanged: saving
                      ? null
                      : (value) =>
                            setDialogState(() => type = value ?? 'other'),
                ),
              ],
              const SizedBox(height: 12),
              _ReasonFields(
                reason: reason,
                explanation: explanation,
                enabled: !saving,
                onReason: (value) => setDialogState(() => reason = value),
                onExplanation: (value) => explanation = value,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (reason == 'other' && explanation.trim().isEmpty) {
                      setDialogState(
                        () => error = 'Add a short explanation for Other.',
                      );
                      return;
                    }
                    setDialogState(() {
                      saving = true;
                      error = null;
                    });
                    final key = action == 'exclude'
                        ? 'session_exclusion:${session.id}'
                        : 'session_type:${session.id}';
                    try {
                      await ApiService.instance.createWeeklyTrainingCorrection({
                        'kind': action == 'exclude'
                            ? 'session_exclusion'
                            : 'session_reclassification',
                        'effective_date': _dateText(session.date),
                        'session_id': session.id,
                        if (action == 'reclassify') 'training_type': type,
                        'reason': reason,
                        'explanation': reason == 'other'
                            ? explanation.trim()
                            : null,
                        'expected_correction_id':
                            summary.activeCorrectionIds[key],
                      });
                      if (context.mounted) Navigator.pop(context);
                      await onRefresh();
                    } catch (exception) {
                      setDialogState(() {
                        saving = false;
                        error = _friendlyError(exception);
                      });
                    }
                  },
            child: Text(
              action == 'exclude' ? 'Hide from summary' : 'Save type',
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _editMemberWorkout(
  BuildContext context,
  IncludedTrainingSession session,
  WeeklyTrainingSummary summary,
  Future<void> Function() onRefresh,
) async {
  var type = session.type;
  var reason = 'manual_measurement';
  var explanation = '';
  final duration = TextEditingController(
    text: session.durationMinutes?.toString() ?? '',
  );
  var saving = false;
  String? error;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit member-entered workout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This replaces only your personal-summary entry. Official attendance remains unchanged.',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Training type'),
                items: _trainingTypes
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry,
                        child: Text(_title(entry)),
                      ),
                    )
                    .toList(),
                onChanged: saving
                    ? null
                    : (value) => setDialogState(() => type = value ?? 'other'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: duration,
                enabled: !saving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration in minutes (optional)',
                ),
              ),
              const SizedBox(height: 10),
              _ReasonFields(
                reason: reason,
                explanation: explanation,
                enabled: !saving,
                onReason: (value) => setDialogState(() => reason = value),
                onExplanation: (value) => explanation = value,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (reason == 'other' && explanation.trim().isEmpty) {
                      setDialogState(
                        () => error = 'Add a short explanation for Other.',
                      );
                      return;
                    }
                    setDialogState(() {
                      saving = true;
                      error = null;
                    });
                    try {
                      await ApiService.instance.createWeeklyTrainingCorrection({
                        'kind': 'manual_workout',
                        'effective_date': _dateText(session.date),
                        'training_type': type,
                        'duration_minutes': int.tryParse(duration.text.trim()),
                        'reason': reason,
                        'explanation': reason == 'other'
                            ? explanation.trim()
                            : null,
                        'expected_correction_id': session.correctionId,
                      });
                      if (context.mounted) Navigator.pop(context);
                      await onRefresh();
                    } catch (exception) {
                      setDialogState(() {
                        saving = false;
                        error = _friendlyError(exception);
                      });
                    }
                  },
            child: const Text('Save workout'),
          ),
        ],
      ),
    ),
  );
  duration.dispose();
}

Future<void> _showHealthEditor(
  BuildContext context,
  WeeklyTrainingSummary summary,
  Future<void> Function() onRefresh,
) async {
  var metric = 'weight';
  var selectedDate = summary.asOf;
  var reason = 'manual_measurement';
  var explanation = '';
  final value = TextEditingController();
  var saving = false;
  String? error;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        final selectedMetric = _metricFor(metric, summary);
        final sourcePoint = selectedMetric.sparkline
            .where((point) => _sameDay(point.date, selectedDate))
            .firstOrNull;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Correct body & recovery data',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your correction changes this member-facing display and preserves the original synced reading.',
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: metric,
                    decoration: const InputDecoration(labelText: 'Metric'),
                    items: const [
                      DropdownMenuItem(value: 'weight', child: Text('Weight')),
                      DropdownMenuItem(
                        value: 'resting_heart_rate',
                        child: Text('Resting heart rate'),
                      ),
                      DropdownMenuItem(value: 'sleep', child: Text('Sleep')),
                    ],
                    onChanged: saving
                        ? null
                        : (entry) => setSheetState(() {
                            metric = entry ?? 'weight';
                            value.clear();
                          }),
                  ),
                  const SizedBox(height: 10),
                  _DateButton(
                    date: selectedDate,
                    first: summary.asOf.subtract(const Duration(days: 13)),
                    last: summary.asOf,
                    onSelected: (entry) =>
                        setSheetState(() => selectedDate = entry),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current source value: ${sourcePoint == null ? 'No value recorded for this date' : _metricValue(sourcePoint.value, selectedMetric.unit)}',
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: value,
                    enabled: !saving,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Replacement value (${selectedMetric.unit})',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ReasonFields(
                    reason: reason,
                    explanation: explanation,
                    enabled: !saving,
                    onReason: (entry) => setSheetState(() => reason = entry),
                    onExplanation: (entry) => explanation = entry,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final parsed = double.tryParse(value.text.trim());
                            final limits = metric == 'weight'
                                ? (10.0, 500.0)
                                : metric == 'resting_heart_rate'
                                ? (20.0, 260.0)
                                : (0.0, 24.0);
                            if (parsed == null ||
                                parsed < limits.$1 ||
                                parsed > limits.$2) {
                              setSheetState(
                                () => error =
                                    'Enter a value between ${limits.$1} and ${limits.$2}.',
                              );
                              return;
                            }
                            if (reason == 'other' &&
                                explanation.trim().isEmpty) {
                              setSheetState(
                                () => error =
                                    'Add a short explanation for Other.',
                              );
                              return;
                            }
                            setSheetState(() {
                              saving = true;
                              error = null;
                            });
                            final key =
                                'metric:${_dateText(selectedDate)}:$metric';
                            try {
                              await ApiService.instance
                                  .createWeeklyTrainingCorrection({
                                    'kind': 'health_metric',
                                    'effective_date': _dateText(selectedDate),
                                    'metric': metric,
                                    'value': parsed,
                                    'reason': reason,
                                    'explanation': reason == 'other'
                                        ? explanation.trim()
                                        : null,
                                    'expected_correction_id':
                                        summary.activeCorrectionIds[key],
                                  });
                              if (context.mounted) Navigator.pop(context);
                              await onRefresh();
                            } catch (exception) {
                              setSheetState(() {
                                saving = false;
                                error = _friendlyError(exception);
                              });
                            }
                          },
                    child: saving
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save correction'),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  value.dispose();
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.date,
    required this.first,
    required this.last,
    required this.onSelected,
  });
  final DateTime date;
  final DateTime first;
  final DateTime last;
  final ValueChanged<DateTime> onSelected;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: first,
        lastDate: last,
      );
      if (selected != null) onSelected(selected);
    },
    icon: const Icon(Icons.calendar_today_outlined),
    label: Text(_dateText(date)),
  );
}

class _ReasonFields extends StatelessWidget {
  const _ReasonFields({
    required this.reason,
    required this.explanation,
    required this.enabled,
    required this.onReason,
    required this.onExplanation,
  });
  final String reason;
  final String explanation;
  final bool enabled;
  final ValueChanged<String> onReason;
  final ValueChanged<String> onExplanation;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      DropdownButtonFormField<String>(
        initialValue: reason,
        decoration: const InputDecoration(labelText: 'Reason'),
        items: _reasons.entries
            .map(
              (entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            )
            .toList(),
        onChanged: enabled ? (value) => onReason(value ?? 'other') : null,
      ),
      if (reason == 'other')
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextFormField(
            initialValue: explanation,
            enabled: enabled,
            maxLength: 500,
            onChanged: onExplanation,
            decoration: const InputDecoration(labelText: 'Short explanation'),
          ),
        ),
    ],
  );
}

Future<void> _undo(
  BuildContext context,
  String correctionId,
  Future<void> Function() onRefresh,
) async {
  try {
    await ApiService.instance.reverseWeeklyTrainingCorrection(correctionId);
    if (context.mounted) Navigator.pop(context);
    await onRefresh();
  } catch (exception) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(exception))));
    }
  }
}

WeeklyMetric _metricFor(String metric, WeeklyTrainingSummary summary) =>
    metric == 'weight'
    ? summary.weight
    : metric == 'resting_heart_rate'
    ? summary.restingHeartRate
    : summary.sleep;
String _consistencySubtitle(WeeklyTrainingSummary summary) {
  if (!summary.planAvailable) {
    return summary.planMessage ?? 'Actual training days';
  }
  final due = summary.plannedDaysDue;
  if (due == 0) return 'No planned workout days are due yet';
  if (summary.completedPlannedDays == 0) {
    return '$due planned day${due == 1 ? '' : 's'} due · no workouts completed';
  }
  return '${summary.completedPlannedDays} of $due planned day${due == 1 ? '' : 's'} completed';
}

String _title(String value) => value
    .split('_')
    .map(
      (part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
    )
    .join(' ');
String _dateText(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
String _sleepLabel(double value) {
  final minutes = (value * 60).round();
  return '${minutes ~/ 60}h ${minutes % 60}m';
}

String _metricValue(double value, String unit) => unit == 'hours'
    ? _sleepLabel(value)
    : unit == 'bpm'
    ? '${value.round()} bpm'
    : '${value.toStringAsFixed(1)} kg';
String _delta(double value, String unit) => unit == 'hours'
    ? '${(value * 60).round()} min'
    : unit == 'bpm'
    ? '${value.round()} bpm'
    : '${value.toStringAsFixed(1)} kg';
bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
String _friendlyError(Object exception) {
  final message = exception.toString().replaceFirst('Exception: ', '');
  return message.contains('409')
      ? 'This was updated elsewhere. Refresh and review the latest correction.'
      : message;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

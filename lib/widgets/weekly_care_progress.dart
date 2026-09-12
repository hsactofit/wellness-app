import 'package:flutter/material.dart';

import '../models/care_program.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class WeeklyCareProgressSection extends StatelessWidget {
  const WeeklyCareProgressSection({
    super.key,
    required this.summary,
    required this.loading,
    required this.loadFailed,
    required this.onOpenProgram,
    required this.onRefresh,
  });

  final CareProgramSummary? summary;
  final bool loading;
  final bool loadFailed;
  final VoidCallback onOpenProgram;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : theme.colorScheme.onSurface;
    final muted = isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(20),
        child: loading
            ? const SizedBox(
                height: 116,
                child: Center(child: CircularProgressIndicator()),
              )
            : loadFailed
            ? _MessageState(
                icon: Icons.cloud_off_outlined,
                title: 'Care progress is unavailable',
                message: 'Your saved care information is still safe.',
                actionLabel: 'Retry',
                onAction: onRefresh,
              )
            : _content(context, summary!, ink, muted),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    CareProgramSummary value,
    Color ink,
    Color muted,
  ) {
    final program = value.current;
    if (program?.status == 'active') {
      return _ActiveProgress(
        program: program!,
        summary: value,
        ink: ink,
        muted: muted,
        onOpen: onOpenProgram,
      );
    }
    if (program?.status == 'paused') {
      return _MessageState(
        icon: Icons.pause_circle_outline_rounded,
        title: 'Care program paused',
        message:
            'Your guidance and progress are saved. New actions are paused.',
        actionLabel: 'View program',
        onAction: onOpenProgram,
      );
    }
    if (value.offer != null) {
      return _MessageState(
        icon: Icons.assignment_outlined,
        title: 'A care program is ready',
        message: '${value.offer!.title} is waiting for your review.',
        actionLabel: 'Review program',
        onAction: onOpenProgram,
      );
    }
    if (value.reviewRequested) {
      return _MessageState(
        icon: Icons.manage_search_rounded,
        title: 'Review in progress',
        message: 'Your care team is reviewing the right program for you.',
        actionLabel: 'View status',
        onAction: onOpenProgram,
      );
    }
    final completed = value.history.where((item) => item.status == 'completed');
    if (completed.isNotEmpty) {
      return _MessageState(
        icon: Icons.verified_outlined,
        title: 'Care program completed',
        message: '${completed.first.title} is available in your history.',
        actionLabel: 'View summary',
        onAction: onOpenProgram,
      );
    }
    return _MessageState(
      icon: Icons.favorite_outline_rounded,
      title: 'Start with a care review',
      message: 'Your care team can recommend a program for your goals.',
      actionLabel: 'Request a review',
      onAction: onOpenProgram,
    );
  }
}

class _ActiveProgress extends StatelessWidget {
  const _ActiveProgress({
    required this.program,
    required this.summary,
    required this.ink,
    required this.muted,
    required this.onOpen,
  });

  final CareProgram program;
  final CareProgramSummary summary;
  final Color ink;
  final Color muted;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final expected = summary.weeklyExpectedActions;
    final completed = summary.weeklyCompletedActions.clamp(0, expected);
    final progress = expected == 0 ? 0.0 : completed / expected;
    final week = _programWeek(program);
    final totalWeeks = _programWeeks(program);
    final next = summary.nextAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppTheme.mednovationsSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppTheme.mednovationsBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Care Progress',
                    style: TextStyle(
                      color: ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    totalWeeks == null
                        ? 'Week $week'
                        : 'Week $week of $totalWeeks',
                    style: TextStyle(color: muted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            _StatusPill(text: program.reviewDue ? 'REVIEW DUE' : 'ACTIVE'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Care actions completed',
              style: TextStyle(color: muted, fontWeight: FontWeight.w600),
            ),
            Text(
              '$completed of $expected',
              style: const TextStyle(
                color: AppTheme.mednovationsInk,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: AppTheme.mednovationsSoft,
            valueColor: const AlwaysStoppedAnimation(
              AppTheme.mednovationsGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppTheme.mednovationsBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.mednovationsBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_forward_rounded,
                size: 19,
                color: AppTheme.mednovationsBlue,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  next == null
                      ? 'You are up to date for this week.'
                      : 'Next: ${next.title} · ${_dayLabel(next.occurrenceDate)}',
                  style: TextStyle(color: ink, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('View my program'),
          ),
        ),
      ],
    );
  }

  int _programWeek(CareProgram value) {
    if (value.startsOn == null) return 1;
    final elapsed = DateUtils.dateOnly(
      DateTime.now(),
    ).difference(DateUtils.dateOnly(value.startsOn!));
    return (elapsed.inDays ~/ 7 + 1).clamp(1, _programWeeks(value) ?? 999);
  }

  int? _programWeeks(CareProgram value) {
    if (value.startsOn == null || value.endsOn == null) return null;
    return (value.endsOn!.difference(value.startsOn!).inDays / 7).ceil();
  }

  String _dayLabel(DateTime value) {
    final today = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(value);
    if (day == today) return 'Today';
    if (day == today.add(const Duration(days: 1))) return 'Tomorrow';
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday -
        1];
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.mednovationsGreenSoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF347A27),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppTheme.mednovationsSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.mednovationsBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Weekly Care Progress',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

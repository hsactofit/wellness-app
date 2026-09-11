import 'package:flutter/material.dart';

import '../models/care_program.dart';
import '../services/care_program_service.dart';
import '../services/care_program_pdf_service.dart';
import '../theme/app_theme.dart';
import 'nutrition_logging_screen.dart';
import 'update_health_hub_screen.dart';
import 'water_logging_screen.dart';

class CareProgramsScreen extends StatefulWidget {
  const CareProgramsScreen({super.key});

  @override
  State<CareProgramsScreen> createState() => _CareProgramsScreenState();
}

class _CareProgramsScreenState extends State<CareProgramsScreen> {
  late Future<CareProgramSummary> _summary;
  final Set<String> _savingActions = {};

  @override
  void initState() {
    super.initState();
    _summary = CareProgramService.instance.fetchMine();
  }

  void _refresh() =>
      setState(() => _summary = CareProgramService.instance.fetchMine());

  Future<void> _requestReview() async {
    try {
      await CareProgramService.instance.requestReview(
        reason:
            'I would like my care team to review a suitable program for me.',
      );
      _refresh();
    } on CareProgramException catch (error) {
      _message(error.message, error: true);
    }
  }

  Future<void> _respond(CareProgram program, bool accept) async {
    try {
      await CareProgramService.instance.respond(program.id, accept: accept);
      _refresh();
      _message(
        accept ? 'Your care program is now active.' : 'The offer was declined.',
      );
    } on CareProgramException catch (error) {
      _message(error.message, error: true);
    }
  }

  Future<void> _withdraw(CareProgram program) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw from this program?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your care team will retain the program history. You can request another review later.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reason,
              maxLength: 500,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep program'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (confirmed != true) return;
    try {
      await CareProgramService.instance.withdraw(
        program.id,
        reason: text.isEmpty ? null : text,
      );
      _refresh();
      _message('You have withdrawn from the program.');
    } on CareProgramException catch (error) {
      _message(error.message, error: true);
    }
  }

  Future<void> _complete(CareProgram program, CareProgramAction action) async {
    setState(() => _savingActions.add(action.key));
    try {
      await CareProgramService.instance.completeAction(
        program.id,
        action.key,
        DateTime.now(),
      );
      _refresh();
      _message('Action completed.');
    } on CareProgramException catch (error) {
      _message(error.message, error: true);
    } finally {
      if (mounted) setState(() => _savingActions.remove(action.key));
    }
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.redAccent : const Color(0xFF168B72),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Care Programs')),
      body: FutureBuilder<CareProgramSummary>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _ErrorState(onRetry: _refresh);
          final summary = snapshot.data!;
          final program = summary.offer ?? summary.current;
          if (program == null) {
            return _EmptyState(
              reviewRequested: summary.reviewRequested,
              onRequest: _requestReview,
              history: summary.history,
              summary: summary,
              onMessage: _message,
            );
          }
          return DefaultTabController(
            length: 5,
            child: Column(
              children: [
                _ProgramHero(program: program, isDark: isDark),
                const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'My Actions'),
                    Tab(text: 'Care Team'),
                    Tab(text: 'Progress'),
                    Tab(text: 'History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _Overview(
                        program: program,
                        currentProgram: summary.current,
                        onRespond: _respond,
                        onWithdraw: _withdraw,
                      ),
                      _Actions(
                        program: summary.current ?? program,
                        saving: _savingActions,
                        onComplete: _complete,
                        onOpenTracker: _openTracker,
                      ),
                      _CareTeam(program: program),
                      _Progress(
                        program: summary.current ?? program,
                        summary: summary,
                        onMessage: _message,
                      ),
                      _History(items: summary.history),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openTracker(CareProgramAction action) {
    Widget screen;
    switch (action.type) {
      case 'hydration':
        screen = const WaterLoggingScreen();
      case 'meal':
        screen = const NutritionLoggingScreen();
      default:
        screen = const UpdateHealthHubScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _ProgramHero extends StatelessWidget {
  const _ProgramHero({required this.program, required this.isDark});
  final CareProgram program;
  final bool isDark;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF082F49), Color(0xFF0B5E75)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                program.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (program.reviewDue) ...[
              const SizedBox(width: 8),
              const Text(
                'Review due',
                style: TextStyle(
                  color: Color(0xFF86EFAC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Text(
          program.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (program.summary.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            program.summary,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ],
    ),
  );
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.program,
    required this.currentProgram,
    required this.onRespond,
    required this.onWithdraw,
  });
  final CareProgram program;
  final CareProgram? currentProgram;
  final Future<void> Function(CareProgram, bool) onRespond;
  final Future<void> Function(CareProgram) onWithdraw;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const _Heading('Your objectives'),
      ...program.objectives.map(
        (objective) => _InfoTile(icon: Icons.flag_outlined, title: objective),
      ),
      const SizedBox(height: 18),
      const _Heading('Program timeline'),
      _InfoTile(
        icon: Icons.calendar_today_outlined,
        title: _range(program),
        subtitle: program.reviewOn == null
            ? 'Review date will be confirmed on activation'
            : 'Next review: ${_format(program.reviewOn!)}',
      ),
      if (program.status == 'offered') ...[
        if (currentProgram != null)
          _InfoTile(
            icon: Icons.verified_user_outlined,
            title: '${currentProgram!.title} remains active',
            subtitle:
                'Your current program continues until you accept this replacement offer.',
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onRespond(program, false),
                child: const Text('Decline'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => onRespond(program, true),
                child: const Text('Accept program'),
              ),
            ),
          ],
        ),
      ],
      if (program.status == 'paused')
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: _InfoTile(
            icon: Icons.pause_circle_outline,
            title: 'Program paused',
            subtitle:
                'Your guidance and history remain available. New daily actions are paused.',
          ),
        ),
      if (program.status == 'active' || program.status == 'paused') ...[
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => onWithdraw(program),
          child: const Text('Withdraw from this program'),
        ),
      ],
    ],
  );
  static String _range(CareProgram p) => p.startsOn == null
      ? 'Begins when you accept'
      : '${_format(p.startsOn!)} – ${p.endsOn == null ? 'Ongoing' : _format(p.endsOn!)}';
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.program,
    required this.saving,
    required this.onComplete,
    required this.onOpenTracker,
  });
  final CareProgram program;
  final Set<String> saving;
  final Future<void> Function(CareProgram, CareProgramAction) onComplete;
  final void Function(CareProgramAction) onOpenTracker;
  @override
  Widget build(BuildContext context) {
    if (program.status != 'active') {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Actions begin when the program is active.'),
        ),
      );
    }
    final today = DateTime.now();
    final actions = program.actions.where((action) {
      if (action.recurrence == 'daily') return true;
      if (action.recurrence == 'once') {
        final starts = program.startsOn;
        return starts != null &&
            starts.year == today.year &&
            starts.month == today.month &&
            starts.day == today.day;
      }
      return action.weekdays.contains(today.weekday);
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Heading("Today's actions"),
        if (actions.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'No actions are scheduled today.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ...actions.map((action) {
          final direct =
              action.type == 'checklist' || action.type == 'guidance';
          return Card(
            child: ListTile(
              leading: Icon(
                direct ? Icons.check_circle_outline : Icons.open_in_new,
                color: const Color(0xFF168B72),
              ),
              title: Text(action.title),
              subtitle: Text(
                '${_label(action.type)} · ${_label(action.recurrence)}',
              ),
              trailing: saving.contains(action.key)
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: () => direct
                          ? onComplete(program, action)
                          : onOpenTracker(action),
                      child: Text(direct ? 'Complete' : 'Open tracker'),
                    ),
            ),
          );
        }),
      ],
    );
  }
}

class _CareTeam extends StatelessWidget {
  const _CareTeam({required this.program});
  final CareProgram program;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const _Heading('Your care team'),
      _InfoTile(
        icon: Icons.medical_services_outlined,
        title: program.physicianName ?? 'Responsible Physician',
        subtitle: 'Owns your program and clinical review',
      ),
      if (program.dietitianName != null)
        _InfoTile(
          icon: Icons.restaurant_menu,
          title: program.dietitianName!,
          subtitle: 'Dietitian · Nutrition guidance',
        ),
      const SizedBox(height: 18),
      const _Heading('Published guidance'),
      if (program.guidance.isEmpty)
        const Text(
          'No new guidance has been published.',
          style: TextStyle(color: Colors.grey),
        ),
      ...program.guidance.map(
        (item) => _InfoTile(
          icon: Icons.notes,
          title: item.text,
          subtitle:
              '${item.authorName} · Published ${_format(item.publishedAt)}',
        ),
      ),
    ],
  );
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.program,
    required this.summary,
    required this.onMessage,
  });
  final CareProgram program;
  final CareProgramSummary summary;
  final void Function(String, {bool error}) onMessage;
  @override
  Widget build(BuildContext context) {
    final elapsed = program.startsOn == null
        ? 0.0
        : DateTime.now().difference(program.startsOn!).inDays /
              ((program.endsOn?.difference(program.startsOn!).inDays ?? 1)
                  .clamp(1, 999));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Heading('Program time elapsed'),
        LinearProgressIndicator(
          value: elapsed.clamp(0, 1),
          minHeight: 9,
          borderRadius: BorderRadius.circular(9),
        ),
        const SizedBox(height: 8),
        Text(
          '${(elapsed.clamp(0, 1) * 100).round()}%',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const _Heading('Action completion'),
        _InfoTile(
          icon: Icons.fact_check_outlined,
          title: summary.expectedActions == 0
              ? 'No expected actions have been generated yet'
              : '${summary.completedActions} of ${summary.expectedActions} expected actions completed',
          subtitle: 'Paused and future days are excluded from expected totals.',
        ),
        const SizedBox(height: 16),
        const _Heading('Measurement changes'),
        if (summary.measurementChanges.isEmpty)
          const _InfoTile(
            icon: Icons.monitor_heart_outlined,
            title: 'Unavailable until two qualifying measurements are recorded',
            subtitle:
                'Measurements are shown separately from participation and time elapsed.',
          )
        else
          ...summary.measurementChanges.map(
            (metric) => _InfoTile(
              icon: Icons.monitor_heart_outlined,
              title:
                  '${metric.label}: ${metric.first} to ${metric.latest} ${metric.unit}',
              subtitle:
                  'Change: ${metric.change >= 0 ? '+' : ''}${metric.change} ${metric.unit}',
            ),
          ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () async {
            try {
              await CareProgramPdfService.shareProgress(
                program: program,
                summary: summary,
              );
            } catch (_) {
              onMessage('The progress PDF could not be prepared.', error: true);
            }
          },
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Download progress PDF'),
        ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.items});
  final List<CareProgram> items;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const _Heading('Program history'),
      if (items.isEmpty)
        const Text(
          'No previous programs yet.',
          style: TextStyle(color: Colors.grey),
        ),
      ...items.map(
        (program) => _InfoTile(
          icon: Icons.history,
          title: program.title,
          subtitle:
              '${_label(program.status)}${program.completionSummary == null ? '' : ' · ${program.completionSummary}'}',
        ),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.reviewRequested,
    required this.onRequest,
    required this.history,
    required this.summary,
    required this.onMessage,
  });
  final bool reviewRequested;
  final Future<void> Function() onRequest;
  final List<CareProgram> history;
  final CareProgramSummary summary;
  final void Function(String, {bool error}) onMessage;
  @override
  Widget build(BuildContext context) {
    CareProgram? completed;
    for (final program in history) {
      if (program.status == 'completed') {
        completed = program;
        break;
      }
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 34,
                color: Color(0xFF075985),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              completed != null
                  ? 'Your care program is complete'
                  : reviewRequested
                  ? 'Your care team is reviewing your request'
                  : 'Your care team can recommend a program for you',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              completed != null
                  ? completed.completionSummary ??
                        'Your completion summary remains available here.'
                  : reviewRequested
                  ? 'We will notify you when a Physician has prepared an offer.'
                  : 'Request a review to begin a personalized program with clear actions and progress tracking.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (!reviewRequested)
              FilledButton.icon(
                onPressed: onRequest,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Request a review'),
              ),
            if (completed != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await CareProgramPdfService.shareProgress(
                      program: completed!,
                      summary: summary,
                    );
                  } catch (_) {
                    onMessage(
                      'The completion PDF could not be prepared.',
                      error: true,
                    );
                  }
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Download completion summary'),
              ),
            ],
            if (history.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _Heading('Program history'),
              ...history.map(
                (program) => _InfoTile(
                  icon: Icons.history,
                  title: program.title,
                  subtitle:
                      '${_label(program.status)}${program.completedAt == null ? '' : ' · ${_format(program.completedAt!)}'}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 42, color: Colors.grey),
        const SizedBox(height: 12),
        const Text('Care Programs could not be loaded.'),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(
        color: Theme.of(context).dividerColor.withValues(alpha: .45),
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.actionOf(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

String _format(DateTime value) =>
    '${value.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][value.month - 1]} ${value.year}';
String _label(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .map(
      (word) =>
          word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
    )
    .join(' ');

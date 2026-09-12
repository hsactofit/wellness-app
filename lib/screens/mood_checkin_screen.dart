import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mood_checkin.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

typedef MoodCheckinLoader = Future<List<MoodCheckin>> Function();
typedef MoodCheckinSubmitter =
    Future<MoodCheckin> Function({
      required int moodScore,
      required int stressScore,
      required bool anonymous,
    });

/// A member's daily mood/stress check-in — feeds the counsellor's real
/// mood-trend and high-stress queue on the staff panel (see
/// wellness-server's /mind/checkin + /staff/mind/*). Anonymous check-ins
/// never expose the member's identity to staff.
class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key, this.loadCheckins, this.submitCheckin});

  final MoodCheckinLoader? loadCheckins;
  final MoodCheckinSubmitter? submitCheckin;

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  static const Color _accent = Color(0xFF8F6BFF);
  static const Color _mint = Color(0xFF2EE5A3);

  double _mood = 6;
  double _stress = 4;
  bool _anonymous = false;
  bool _isSubmitting = false;
  bool _submitted = false;
  List<MoodCheckin>? _checkins;
  String? _historyError;

  final List<String> _moodLabels = const [
    'Very low',
    'Low',
    'Low',
    'Down',
    'Neutral',
    'Okay',
    'Good',
    'Good',
    'Great',
    'Excellent',
  ];

  String _labelFor(double value) => _moodLabels[value.round() - 1];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (mounted) setState(() => _historyError = null);
    try {
      final checkins =
          await (widget.loadCheckins?.call() ??
              ApiService.instance.fetchMoodCheckins());
      if (!mounted) return;
      setState(() => _checkins = checkins);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _historyError = 'Could not load your check-in history.';
        _checkins ??= [];
      });
      debugPrint('Mood check-in history error: $error');
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();
    try {
      final checkin =
          await (widget.submitCheckin?.call(
                moodScore: _mood.round(),
                stressScore: _stress.round(),
                anonymous: _anonymous,
              ) ??
              ApiService.instance.submitMoodCheckin(
                moodScore: _mood.round(),
                stressScore: _stress.round(),
                anonymous: _anonymous,
              ));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitted = true;
        _checkins = [
          checkin,
          ...?_checkins?.where((item) => item.id != checkin.id),
        ];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F12) : AppTheme.lightCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Check-in',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: _submitted
            ? _buildSuccess(textColor, secondaryText)
            : _buildForm(isDark, textColor, secondaryText),
      ),
    );
  }

  Widget _buildSuccess(Color textColor, Color? secondaryText) {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 72, 20, 40),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _mint.withValues(alpha: 0.14),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _mint,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Check-in logged',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thanks for sharing how you\'re doing today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: secondaryText),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildHistory(textColor, secondaryText),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark, Color textColor, Color? secondaryText) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A quick, private check-in — takes 10 seconds.',
            style: TextStyle(fontSize: 13, color: secondaryText),
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mood',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      _labelFor(_mood),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _mood,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _accent,
                  onChanged: (v) => setState(() => _mood = v),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stress level',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${_stress.round()}/10',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _stress,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.redAccent,
                  onChanged: (v) => setState(() => _stress = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _anonymous,
                activeThumbColor: _accent,
                title: Text(
                  'Submit anonymously',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Your name is hidden from the wellness team; only trends are shared.',
                  style: TextStyle(fontSize: 12, color: secondaryText),
                ),
                onChanged: (v) => setState(() => _anonymous = v),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Check-in',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
          const SizedBox(height: 32),
          _buildHistory(textColor, secondaryText),
        ],
      ),
    );
  }

  Widget _buildHistory(Color textColor, Color? secondaryText) {
    final checkins = _checkins;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent check-ins',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
            if (checkins != null)
              IconButton(
                tooltip: 'Refresh check-in history',
                onPressed: _loadHistory,
                icon: Icon(Icons.refresh_rounded, color: secondaryText),
              ),
          ],
        ),
        Text(
          'Your personal check-in history is visible only in your account.',
          style: TextStyle(fontSize: 12, color: secondaryText),
        ),
        const SizedBox(height: 10),
        if (checkins == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (checkins.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.insights_rounded, color: secondaryText, size: 32),
                const SizedBox(height: 10),
                Text(
                  _historyError ?? 'Your first check-in will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText),
                ),
                if (_historyError != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadHistory,
                    child: const Text('Try again'),
                  ),
                ],
              ],
            ),
          )
        else
          ...checkins.map(
            (checkin) => GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      '${checkin.moodScore}',
                      style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood ${checkin.moodScore}/10 · ${_labelFor(checkin.moodScore.toDouble())}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stress ${checkin.stressScore}/10 · ${_formatCheckedAt(checkin.checkedAt)}',
                          style: TextStyle(fontSize: 12, color: secondaryText),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          checkin.anonymous
                              ? 'Submitted anonymously'
                              : 'Shared with the wellness team',
                          style: TextStyle(fontSize: 11, color: secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatCheckedAt(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final date = DateTime(local.year, local.month, local.day);
    final today = DateTime(now.year, now.month, now.day);
    final dateLabel = date == today
        ? 'Today'
        : date == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : MaterialLocalizations.of(context).formatMediumDate(local);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$dateLabel · $time';
  }
}

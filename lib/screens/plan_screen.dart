import 'dart:async';

import 'package:flutter/material.dart';
import '../models/plan_models.dart';
import '../models/workout_muscles.dart';
import '../services/api_service.dart';
import '../services/reviewed_plan_pdf_service.dart';
import '../widgets/glass_card.dart';

String reviewedPlanConsentWarning(String planLabel) =>
    'Please confirm AI processing consent before requesting your $planLabel plan.';

class PlanConsentCheckbox extends StatelessWidget {
  final String planLabel;
  final bool value;
  final Color accent;
  final Color textColor;
  final ValueChanged<bool?> onChanged;
  final double fontSize;

  const PlanConsentCheckbox({
    super.key,
    required this.planLabel,
    required this.value,
    required this.accent,
    required this.textColor,
    required this.onChanged,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      activeColor: accent,
      onChanged: onChanged,
      title: Text(
        'I consent to AI processing for my $planLabel plan',
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Reviewed workout/nutrition plans. A member supplies preferences, then the
/// company specialist generates, reviews, and approves the AI-assisted plan.
class PlanScreen extends StatefulWidget {
  final PlanKind kind;
  final VoidCallback? onPlanChanged;

  const PlanScreen({super.key, required this.kind, this.onPlanChanged});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with WidgetsBindingObserver {
  bool _isWorkout(PlanKind k) => k == PlanKind.workout;
  bool get _isWorkoutKind => _isWorkout(widget.kind);
  Color get _accent =>
      _isWorkoutKind ? const Color(0xFF5B8CFF) : const Color(0xFFFF9F43);
  String get _title => _isWorkoutKind ? 'Workout Plan' : 'Nutrition Plan';
  String get _planType => _isWorkoutKind ? 'workout' : 'nutrition';
  String get _planLabel => _isWorkoutKind ? 'workout' : 'nutrition';
  String get _emoji => _isWorkoutKind ? '💪' : '🥗';

  bool _isLoading = true;
  bool _isGenerating = false;
  bool _isDownloadingReport = false;
  bool _isFetchingState = false;
  String? _loadError;
  String? _generateError;
  Map<String, dynamic>? _planState;
  bool _consentChecked = false;

  WorkoutPlan? _workoutPlan;
  NutritionPlan? _nutritionPlan;

  final Set<int> _expandedDays = {};
  Timer? _pendingPlanRefreshTimer;

  // Workout form state
  String _goal = 'General fitness';
  String _experience = 'Beginner';
  String _location = 'Home';
  final Set<String> _equipment = {'Bodyweight only'};
  double _sessionMinutes = 45;
  double _daysPerWeek = 4;

  // Nutrition form state
  String _dietary = 'No preference';
  final List<String> _allergies = [];
  final TextEditingController _allergyCtrl = TextEditingController();
  double _mealsPerDay = 3;
  bool _setCalorieTarget = false;
  double _calorieTarget = 2000;
  final TextEditingController _cuisineCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingPlanRefreshTimer?.cancel();
    _allergyCtrl.dispose();
    _cuisineCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(silent: true);
    }
  }

  Map<String, dynamic>? get _activePlan {
    final active = _planState?['active_plan'];
    return active is Map ? Map<String, dynamic>.from(active) : null;
  }

  bool get _hasPendingRequest {
    if (_activePlan != null) return false;
    final status = _request?['status']?.toString();
    return {
      'requested',
      'claimed',
      'generating',
      'review_ready',
    }.contains(status);
  }

  void _configurePendingPlanRefresh() {
    _pendingPlanRefreshTimer?.cancel();
    _pendingPlanRefreshTimer = null;
    if (!_hasPendingRequest) return;
    _pendingPlanRefreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _load(silent: true),
    );
  }

  Future<void> _load({bool silent = false}) async {
    if (_isFetchingState) return;
    _isFetchingState = true;
    final hadActivePlan = _activePlan != null;
    if (!silent) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final state = await ApiService.instance.getReviewedPlanState(
        _isWorkoutKind ? 'workout' : 'nutrition',
      );
      final active = state['active_plan'];
      if (!mounted) return;
      setState(() {
        _planState = state;
        _workoutPlan = _isWorkoutKind && active is Map
            ? WorkoutPlan.fromReviewedJson(Map<String, dynamic>.from(active))
            : null;
        _nutritionPlan = !_isWorkoutKind && active is Map
            ? NutritionPlan.fromReviewedJson(Map<String, dynamic>.from(active))
            : null;
        _isLoading = false;
      });
      _configurePendingPlanRefresh();
      if (!hadActivePlan && _activePlan != null) {
        widget.onPlanChanged?.call();
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _loadError = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    } finally {
      _isFetchingState = false;
    }
  }

  bool get _canRequest => _planState?['can_request'] == true;

  Map<String, dynamic>? get _request {
    final request = _planState?['request'];
    return request is Map ? Map<String, dynamic>.from(request) : null;
  }

  Future<void> _requestPlan() async {
    if (!_consentChecked) {
      _showConsentWarning();
      return;
    }
    setState(() {
      _isGenerating = true;
      _generateError = null;
    });
    try {
      await ApiService.instance.updateReviewedPlanConsent(_planType, true);
      final preferences = _isWorkoutKind
          ? <String, dynamic>{
              'goal': _goal,
              'experience': _experience,
              'location': _location,
              'equipment': _equipment.toList(),
              'session_minutes': _sessionMinutes.round(),
              'days_per_week': _daysPerWeek.round(),
            }
          : <String, dynamic>{
              'dietary': _dietary == 'No preference' ? null : _dietary,
              'allergies': _allergies,
              'meals_per_day': _mealsPerDay.round(),
              if (_setCalorieTarget) 'calorie_target': _calorieTarget.round(),
              if (_cuisineCtrl.text.trim().isNotEmpty)
                'cuisine': _cuisineCtrl.text.trim(),
            };
      final state = await ApiService.instance.requestReviewedPlan(_planType, {
        'preferences': preferences,
      });
      widget.onPlanChanged?.call();
      if (mounted) {
        setState(() {
          _planState = state;
          _isGenerating = false;
        });
        _configurePendingPlanRefresh();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generateError = e.toString().replaceFirst('Exception: ', '');
          _isGenerating = false;
        });
      }
    }
  }

  void _showConsentWarning() {
    final message = reviewedPlanConsentWarning(_planLabel);
    setState(() => _generateError = message);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange.shade800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    // Render only after the approved response has been parsed into the
    // member-facing model. This keeps the screen resilient if a malformed
    // response ever reaches the app.
    final hasPlan = _isWorkoutKind
        ? _workoutPlan != null
        : _nutritionPlan != null;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F0F12) : const Color(0xFFF6F8FC),
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accent.withValues(alpha: isDark ? 0.14 : 0.08),
                    _accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                        ),
                        color: isDark ? Colors.white70 : Colors.black87,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (hasPlan && !_isLoading)
                        IconButton(
                          tooltip: "Refresh",
                          onPressed: _load,
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: _accent))
                      : _loadError != null
                      ? _buildErrorState(isDark, textColor)
                      : hasPlan
                      ? _buildPlanView(isDark, textColor)
                      : _buildMemberState(isDark, textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("⚠️", style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
              ),
              onPressed: _load,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberState(bool isDark, Color textColor) {
    if (_canRequest) return _buildGenerateForm(isDark, textColor);

    final request = _request;
    if (request?['status'] == 'consent_required') {
      return _buildConsentRequiredState(isDark, textColor);
    }

    final status = request?['status']?.toString();
    final specialist = _isWorkoutKind ? 'trainer' : 'dietitian';
    final message = switch (status) {
      'requested' => 'Your request has been sent to your company $specialist.',
      'claimed' => 'Your company $specialist is preparing your plan.',
      'generating' =>
        'Your company $specialist is generating a draft for review.',
      'review_ready' =>
        'Your company $specialist is reviewing your plan before approval.',
      'generation_failed' =>
        'Your company $specialist has been notified to retry your plan.',
      _ => 'Your plan renewal is being prepared by your company $specialist.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(height: 14),
              Text(
                'Your ${_isWorkoutKind ? 'workout' : 'diet'} plan is in review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('Check status'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentRequiredState(bool isDark, Color textColor) {
    final disclosure = (_planState?['consent'] is Map)
        ? (_planState!['consent'] as Map)['disclosure_text']?.toString()
        : null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _emoji,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 38),
              ),
              const SizedBox(height: 12),
              Text(
                'Confirm AI processing consent',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                disclosure ??
                    'Your company specialist uses AI to prepare a plan from the health and preference information you provide. They review the plan before you can see it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              PlanConsentCheckbox(
                planLabel: _planLabel,
                value: _consentChecked,
                accent: _accent,
                textColor: textColor,
                onChanged: (value) => setState(() {
                  _consentChecked = value ?? false;
                  _generateError = null;
                }),
                fontSize: 12.5,
              ),
              if (_generateError != null) ...[
                Text(
                  _generateError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isGenerating ? null : _grantRenewalConsent,
                child: Text(_isGenerating ? 'Saving…' : 'Confirm consent'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _grantRenewalConsent() async {
    if (!_consentChecked) {
      _showConsentWarning();
      return;
    }
    setState(() {
      _isGenerating = true;
      _generateError = null;
    });
    try {
      await ApiService.instance.updateReviewedPlanConsent(_planType, true);
      await _load();
      if (mounted) setState(() => _isGenerating = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _generateError = e.toString().replaceFirst('Exception: ', '');
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _downloadPdfReport() async {
    final active = _activePlan;
    if (active == null || _isDownloadingReport) return;
    setState(() => _isDownloadingReport = true);
    try {
      await ReviewedPlanPdfService.shareApprovedPlan(
        kind: widget.kind,
        plan: active,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ready. Choose Save to Files or share it.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create the PDF report. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingReport = false);
    }
  }

  String _formatPlanDate(BuildContext context, dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'the end of the plan period';
    return MaterialLocalizations.of(context).formatMediumDate(date.toLocal());
  }

  Widget _buildPlanTiming(BuildContext context, Color? secondaryTextColor) {
    final active = _planState?['active_plan'];
    if (active is! Map) return const SizedBox.shrink();
    final duration = active['duration_weeks']?.toString() ?? '4';
    final upcoming = _planState?['upcoming_plan'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviewed and approved by your company ${_isWorkoutKind ? 'trainer' : 'dietitian'} · $duration-week plan · active until ${_formatPlanDate(context, active['valid_until'])}',
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
        if (upcoming is Map) ...[
          const SizedBox(height: 6),
          Text(
            'Your next reviewed plan is scheduled to begin ${_formatPlanDate(context, upcoming['valid_from'])}.',
            style: TextStyle(
              color: _accent,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeline(Color textColor, Color? secondaryTextColor) {
    final active = _planState?['active_plan'];
    final rawTimeline = active is Map ? active['timeline'] : null;
    if (rawTimeline is! List || rawTimeline.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLAN TIMELINE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        ...rawTimeline.map((entry) {
          final week = Map<String, dynamic>.from(entry as Map);
          final checkpoints =
              (week['checkpoints'] as List<dynamic>?)?.join(' · ') ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week ${week['week']}: ${week['focus']}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (checkpoints.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      checkpoints,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlanView(bool isDark, Color textColor) {
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final title = _isWorkoutKind ? _workoutPlan!.title : _nutritionPlan!.title;
    final summary = _isWorkoutKind
        ? _workoutPlan!.summary
        : _nutritionPlan!.summary;
    final days = _isWorkoutKind
        ? _workoutPlan!.days.length
        : _nutritionPlan!.days.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (summary != null && summary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _isWorkoutKind
                      ? _workoutBadges()
                      : _nutritionBadges(),
                ),
                const SizedBox(height: 12),
                _buildPlanTiming(context, secondaryTextColor),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isDownloadingReport ? null : _downloadPdfReport,
                    icon: _isDownloadingReport
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _accent,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(
                      _isDownloadingReport
                          ? 'Preparing PDF report...'
                          : 'Download PDF report',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeline(textColor, secondaryTextColor),
          const SizedBox(height: 16),
          Text(
            "$days-DAY SCHEDULE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          if (_isWorkoutKind)
            ..._workoutPlan!.days.asMap().entries.map(
              (e) => _buildWorkoutDayCard(e.key, e.value, isDark, textColor),
            )
          else
            ..._nutritionPlan!.days.asMap().entries.map(
              (e) => _buildNutritionDayCard(e.key, e.value, isDark, textColor),
            ),
        ],
      ),
    );
  }

  List<Widget> _workoutBadges() {
    final p = _workoutPlan!;
    return [
      if (p.daysPerWeek != null) _badge('${p.daysPerWeek} days/week'),
      if (p.sessionMinutes != null) _badge('${p.sessionMinutes} min/session'),
      if (p.experience != null) _badge(p.experience!),
      if (p.location != null) _badge(p.location!),
    ];
  }

  List<Widget> _nutritionBadges() {
    final p = _nutritionPlan!;
    return [
      _badge('${p.mealsPerDay} meals/day'),
      if (p.calorieTarget != null) _badge('${p.calorieTarget} kcal/day'),
      if (p.dietary != null) _badge(p.dietary!),
      if (p.cuisine != null) _badge(p.cuisine!),
    ];
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: _accent,
        ),
      ),
    );
  }

  Widget _buildWorkoutDayCard(
    int index,
    WorkoutPlanDay day,
    bool isDark,
    Color textColor,
  ) {
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final isExpanded = _expandedDays.contains(index);
    final isToday = day.day.toLowerCase() == currentWeekdayName().toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          if (isExpanded) {
            _expandedDays.remove(index);
          } else {
            _expandedDays.add(index);
          }
        }),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          border: isToday
              ? Border.all(color: _accent.withValues(alpha: 0.5), width: 1.5)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: textColor,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          _badge('TODAY'),
                        ],
                      ],
                    ),
                  ),
                  if (day.isRestDay)
                    Text(
                      "Rest day",
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    )
                  else
                    Text(
                      day.focus ?? '${day.exercises.length} exercises',
                      style: TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: secondaryTextColor,
                    size: 18,
                  ),
                ],
              ),
              if (isExpanded && !day.isRestDay) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                ...day.exercises.map(
                  (ex) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: textColor,
                          ),
                        ),
                        if (ex.dosageLabel.isNotEmpty)
                          Text(
                            ex.dosageLabel,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        if (ex.targetMuscles.isNotEmpty)
                          Text(
                            'Targets: ${workoutTargetMuscleSummary(ex.targetMuscles)}',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        if (ex.notes != null && ex.notes!.isNotEmpty)
                          Text(
                            ex.notes!,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionDayCard(
    int index,
    NutritionPlanDay day,
    bool isDark,
    Color textColor,
  ) {
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final isExpanded = _expandedDays.contains(index);
    final isToday = day.day.toLowerCase() == currentWeekdayName().toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          if (isExpanded) {
            _expandedDays.remove(index);
          } else {
            _expandedDays.add(index);
          }
        }),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          border: isToday
              ? Border.all(color: _accent.withValues(alpha: 0.5), width: 1.5)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: textColor,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          _badge('TODAY'),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    day.totalCalories != null
                        ? '${day.totalCalories} kcal'
                        : '${day.meals.length} meals',
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: secondaryTextColor,
                    size: 18,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                ...day.meals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: textColor,
                          ),
                        ),
                        Text(
                          meal.items,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                        if (meal.macrosLabel.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              meal.macrosLabel,
                              style: TextStyle(
                                color: _accent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateForm(bool isDark, Color textColor) {
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final disclosure = (_planState?['consent'] is Map)
        ? (_planState!['consent'] as Map)['disclosure_text']?.toString()
        : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 12),
                Text(
                  "Request your $_title",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Share your preferences. Your company ${_isWorkoutKind ? 'trainer' : 'dietitian'} will create and approve the plan before it appears here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isWorkoutKind)
            _buildWorkoutForm(isDark, textColor)
          else
            _buildNutritionForm(isDark, textColor),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  disclosure ??
                      'AI is used to prepare a draft from the health and preference information you provide. Your company specialist reviews it before approval.',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
                PlanConsentCheckbox(
                  planLabel: _planLabel,
                  value: _consentChecked,
                  accent: _accent,
                  textColor: textColor,
                  onChanged: (value) => setState(() {
                    _consentChecked = value ?? false;
                    _generateError = null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_generateError != null) ...[
            Text(
              _generateError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
          ],
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isGenerating ? null : _requestPlan,
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("✨", style: TextStyle(fontSize: 16)),
            label: Text(
              _isGenerating
                  ? "Sending request…"
                  : "Get ${_isWorkoutKind ? 'workout' : 'diet'} plan",
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, Color? color) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
        color: color,
      ),
    ),
  );

  Widget _buildWorkoutForm(bool isDark, Color textColor) {
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    const goals = [
      'General fitness',
      'Lose weight',
      'Build muscle',
      'Endurance',
    ];
    const experiences = ['Beginner', 'Intermediate', 'Advanced'];
    const locations = ['Home', 'Gym', 'Outdoor'];
    const equipmentOptions = [
      'Bodyweight only',
      'Dumbbells',
      'Barbell',
      'Resistance bands',
      'Full gym',
    ];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Goal', secondaryTextColor),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goals
                .map(
                  (g) => ChoiceChip(
                    label: Text(g, style: const TextStyle(fontSize: 11.5)),
                    selected: _goal == g,
                    selectedColor: _accent.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _goal = g),
                  ),
                )
                .toList(),
          ),
          _sectionLabel('Experience', secondaryTextColor),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: experiences
                .map(
                  (e) => ChoiceChip(
                    label: Text(e, style: const TextStyle(fontSize: 11.5)),
                    selected: _experience == e,
                    selectedColor: _accent.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _experience = e),
                  ),
                )
                .toList(),
          ),
          _sectionLabel('Trains at', secondaryTextColor),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: locations
                .map(
                  (l) => ChoiceChip(
                    label: Text(l, style: const TextStyle(fontSize: 11.5)),
                    selected: _location == l,
                    selectedColor: _accent.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _location = l),
                  ),
                )
                .toList(),
          ),
          _sectionLabel('Equipment (pick any)', secondaryTextColor),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipmentOptions
                .map(
                  (eq) => FilterChip(
                    label: Text(eq, style: const TextStyle(fontSize: 11.5)),
                    selected: _equipment.contains(eq),
                    selectedColor: _accent.withValues(alpha: 0.25),
                    onSelected: (sel) => setState(() {
                      if (sel) {
                        _equipment.add(eq);
                      } else {
                        _equipment.remove(eq);
                      }
                    }),
                  ),
                )
                .toList(),
          ),
          _sectionLabel(
            'Session length: ${_sessionMinutes.round()} min',
            secondaryTextColor,
          ),
          Slider(
            value: _sessionMinutes,
            min: 15,
            max: 90,
            divisions: 15,
            activeColor: _accent,
            onChanged: (v) => setState(() => _sessionMinutes = v),
          ),
          _sectionLabel(
            'Days per week: ${_daysPerWeek.round()}',
            secondaryTextColor,
          ),
          Slider(
            value: _daysPerWeek,
            min: 1,
            max: 6,
            divisions: 5,
            activeColor: _accent,
            onChanged: (v) => setState(() => _daysPerWeek = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionForm(bool isDark, Color textColor) {
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    const dietaryOptions = [
      'No preference',
      'Vegetarian',
      'Vegan',
      'Keto',
      'Low-carb',
      'High-protein',
    ];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Dietary preference', secondaryTextColor),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dietaryOptions
                .map(
                  (d) => ChoiceChip(
                    label: Text(d, style: const TextStyle(fontSize: 11.5)),
                    selected: _dietary == d,
                    selectedColor: _accent.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _dietary = d),
                  ),
                )
                .toList(),
          ),
          _sectionLabel('Allergies / avoid', secondaryTextColor),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _allergyCtrl,
                  style: TextStyle(color: textColor, fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: "e.g. peanuts",
                    hintStyle: TextStyle(fontSize: 12),
                    isDense: true,
                  ),
                  onSubmitted: (v) => _addAllergy(v),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: _accent),
                onPressed: () => _addAllergy(_allergyCtrl.text),
              ),
            ],
          ),
          if (_allergies.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _allergies
                  .map(
                    (a) => Chip(
                      label: Text(a, style: const TextStyle(fontSize: 11)),
                      onDeleted: () => setState(() => _allergies.remove(a)),
                    ),
                  )
                  .toList(),
            ),
          _sectionLabel(
            'Meals per day: ${_mealsPerDay.round()}',
            secondaryTextColor,
          ),
          Slider(
            value: _mealsPerDay,
            min: 2,
            max: 6,
            divisions: 4,
            activeColor: _accent,
            onChanged: (v) => setState(() => _mealsPerDay = v),
          ),
          Row(
            children: [
              Switch(
                value: _setCalorieTarget,
                activeThumbColor: _accent,
                onChanged: (v) => setState(() => _setCalorieTarget = v),
              ),
              Text(
                _setCalorieTarget
                    ? 'Daily calorie target: ${_calorieTarget.round()} kcal'
                    : 'Set a calorie target',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
          if (_setCalorieTarget)
            Slider(
              value: _calorieTarget,
              min: 1200,
              max: 4000,
              divisions: 28,
              activeColor: _accent,
              onChanged: (v) => setState(() => _calorieTarget = v),
            ),
          _sectionLabel('Preferred cuisine (optional)', secondaryTextColor),
          TextField(
            controller: _cuisineCtrl,
            style: TextStyle(color: textColor, fontSize: 12.5),
            decoration: const InputDecoration(
              hintText: "e.g. Indian, Mediterranean",
              hintStyle: TextStyle(fontSize: 12),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  void _addAllergy(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || _allergies.contains(trimmed)) return;
    setState(() {
      _allergies.add(trimmed);
      _allergyCtrl.clear();
    });
  }
}

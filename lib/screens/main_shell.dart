import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'challenges_screen.dart';
import 'ai_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'gym_checkin_screen.dart';
import '../theme/app_theme.dart';
import '../services/background_workout_service.dart';
import '../services/push_service.dart';
import '../services/workout_session_service.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _openingCheckout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fire-and-forget: this is the authenticated app shell, reached after
    // every login and on every relaunch with an existing session, so it's
    // the one place that reliably runs for every signed-in user without
    // duplicating the call across every login path (email, code, social).
    PushService.instance.initialize();
    WorkoutSessionService.instance.configurePromptHandler(
      _showWorkoutCompletionPrompt,
    );
    BackgroundWorkoutService.instance.checkoutRequestedSignal.addListener(
      _openCheckoutFromNotification,
    );
    BackgroundWorkoutService.instance.departureCheckoutRequiredSignal
        .addListener(_showNativeDeparturePrompt);
    BackgroundWorkoutService.instance.continueRequestedSignal.addListener(
      _continueFromNotification,
    );
    BackgroundWorkoutService.instance.slotEndContinueRequestedSignal
        .addListener(_continueSlotEndFromNotification);
    // Native checkout actions may arrive during a cold launch. Flush them only
    // after these listeners are installed so the request cannot be lost.
    unawaited(BackgroundWorkoutService.instance.markUiReady());
    WorkoutSessionService.instance.startMonitoring();
    _ensureIosLiveActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundWorkoutService.instance.checkoutRequestedSignal.removeListener(
      _openCheckoutFromNotification,
    );
    BackgroundWorkoutService.instance.departureCheckoutRequiredSignal
        .removeListener(_showNativeDeparturePrompt);
    BackgroundWorkoutService.instance.continueRequestedSignal.removeListener(
      _continueFromNotification,
    );
    BackgroundWorkoutService.instance.slotEndContinueRequestedSignal
        .removeListener(_continueSlotEndFromNotification);
    WorkoutSessionService.instance.configurePromptHandler(null);
    super.dispose();
  }

  Future<void> _openCheckoutFromNotification() async {
    if (!mounted || _openingCheckout) return;
    _openingCheckout = true;
    try {
      final session = await WorkoutSessionService.instance.loadActiveSession();
      if (session == null || !mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GymCheckinScreen()),
      );
    } finally {
      _openingCheckout = false;
    }
  }

  void _ensureIosLiveActivity() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      unawaited(
        WorkoutSessionService.instance.ensurePersistentTimerForActiveSession(),
      );
    }
  }

  Future<void> _showNativeDeparturePrompt() async {
    if (!mounted) return;
    final session = await WorkoutSessionService.instance.loadActiveSession();
    if (session == null || !mounted) return;
    await _showWorkoutCompletionPrompt(
      session,
      WorkoutSessionPromptReason.leftFacility,
    );
  }

  Future<void> _continueFromNotification() async {
    try {
      await WorkoutSessionService.instance.continueWorkout(
        reason: 'Member chose to keep working from the workout notification.',
        promptReason: WorkoutSessionPromptReason.hourly,
      );
      await WorkoutSessionService.instance.markHourlyConfirmation();
    } catch (_) {
      // The session remains open and the next prompt will give the member
      // another safe opportunity to confirm checkout.
    }
  }

  Future<void> _continueSlotEndFromNotification() async {
    try {
      await WorkoutSessionService.instance.continueWorkout(
        reason: 'Member chose to keep working after the booked slot ended.',
        promptReason: WorkoutSessionPromptReason.slotEnd,
      );
    } catch (_) {
      // The workout stays open and the next hourly question remains available.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Timers can be paused by iOS/Android. Re-evaluating on return makes
      // the next overdue hourly question appear instead of silently keeping
      // an abandoned workout active.
      WorkoutSessionService.instance.startMonitoring();
      _ensureIosLiveActivity();
    }
  }

  Future<void> _showWorkoutCompletionPrompt(
    ActiveWorkoutSession session,
    WorkoutSessionPromptReason reason,
  ) async {
    if (!mounted) return;
    final leftFacility = reason == WorkoutSessionPromptReason.leftFacility;
    final slotEnded = reason == WorkoutSessionPromptReason.slotEnd;
    final complete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          leftFacility ? Icons.location_off_outlined : Icons.timer_outlined,
          color: Theme.of(dialogContext).colorScheme.primary,
        ),
        title: Text(
          leftFacility
              ? 'Have you left ${session.facilityName}?'
              : slotEnded
              ? 'Your booked slot has ended'
              : 'Is your workout complete?',
        ),
        content: Text(
          leftFacility
              ? 'Your phone is now at least 2 km from the exact place where you scanned into this workout. Open checkout to finish the active session.'
              : slotEnded
              ? 'Check out now, or keep working. Keeping the session open will notify the facility manager.'
              : 'You started at ${session.facilityName} over an hour ago. End the workout session when you are done.',
        ),
        actions: [
          if (!leftFacility)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Still working out'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(leftFacility ? 'Yes, open checkout' : 'Open checkout'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (complete != true) {
      // A departure prompt intentionally has no "still working" branch and
      // does not manufacture a positive answer if the app is interrupted.
      if (leftFacility) return;
      try {
        await WorkoutSessionService.instance.continueWorkout(
          reason: leftFacility
              ? 'Member chose to keep working after leaving the geofence.'
              : slotEnded
              ? 'Member chose to keep working after the booked slot ended.'
              : 'Member chose to keep working after the hourly prompt.',
          promptReason: slotEnded
              ? WorkoutSessionPromptReason.slotEnd
              : WorkoutSessionPromptReason.hourly,
        );
        if (!slotEnded) {
          await WorkoutSessionService.instance.markHourlyConfirmation();
        }
      } catch (_) {
        // The next local prompt will retry if the network was unavailable.
      }
      return;
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GymCheckinScreen()),
      );
      if (!mounted) return;
      _dashboardKey.currentState?.refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout session completed.'),
          backgroundColor: Colors.green,
        ),
      );
    } on WorkoutSessionException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not complete the workout session. Please try again.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    _refreshTab(index);
  }

  void _refreshTab(int index) {
    if (index == 0) {
      _dashboardKey.currentState?.refreshData();
    } else if (index == 3) {
      _progressKey.currentState?.refresh();
    }
  }

  // Key to refresh dashboard when switching back to it
  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<ProgressScreenState> _progressKey =
      GlobalKey<ProgressScreenState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allow body to extend behind the floating bottom bar
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              DashboardScreen(
                key: _dashboardKey,
                onOpenChallenges: () => setIndex(1),
              ),
              const ChallengesScreen(),
              const AIScreen(),
              ProgressScreen(key: _progressKey),
              const ProfileScreen(),
            ],
          ),

          // Floating bottom navigation — dark rail in light mode.
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isDark ? 15 : 0,
                  sigmaY: isDark ? 15 : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF16161C).withValues(alpha: 0.75)
                        : AppTheme.lightNav,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.08),
                      width: isDark ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.22,
                        ),
                        blurRadius: isDark ? 20 : 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_outlined, Icons.home, "Home"),
                      _buildNavItem(
                        1,
                        Icons.emoji_events_outlined,
                        Icons.emoji_events,
                        "Challenges",
                      ),
                      _buildCenterAINavItem(2),
                      _buildNavItem(
                        3,
                        Icons.bar_chart_outlined,
                        Icons.bar_chart,
                        "Progress",
                      ),
                      _buildNavItem(
                        4,
                        Icons.person_outline,
                        Icons.person,
                        "Profile",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? theme.colorScheme.primary : AppTheme.lightGold;
    final idleColor = isDark ? Colors.white54 : const Color(0xFF9A958C);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          _refreshTab(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.08 : 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? activeColor : idleColor,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : idleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAINavItem(int index) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = isDark ? const Color(0xFFFF6D55) : AppTheme.lightGold;

    return Semantics(
      button: true,
      label: 'Open Fitness Coach',
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isDark
                  ? const [Color(0xFFFF8A4C), Color(0xFFEF5D51)]
                  : const [Color(0xFFE8D5A8), Color(0xFFD4B98A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.white24),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: glow.withValues(alpha: isSelected ? 0.38 : 0.16),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: isDark ? Colors.white : AppTheme.brandInk,
            size: 22,
          ),
        ),
      ),
    );
  }
}

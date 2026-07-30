import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/onboarding/profile_step.dart';
import '../widgets/onboarding/goals_step.dart';
import '../widgets/onboarding/medical_step.dart';
import '../widgets/onboarding/sync_progress_step.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  final int initialPage;
  const OnboardingScreen({super.key, this.initialPage = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentPage;
  final int _totalPages = 4; // 3 form steps + 1 sync step

  // Form keys for validation
  final _profileFormKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // State Variables
  String _gender = 'Female';
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String _activityLevel = 'Active';
  final List<String> _selectedGoals = [];
  List<String> _selectedConditions = [];
  bool _noConditions = false;

  // Sync state
  double _syncProgress = 0.0;
  String _syncStatusText = 'Initializing secure container...';
  bool _isSyncing = false;

  // Background Animation Controllers
  late AnimationController _bgAnimationController;
  late Animation<double> _blobAnimation;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _blobAnimation = CurvedAnimation(
      parent: _bgAnimationController,
      curve: Curves.easeInOut,
    );

    _loadExistingUserData();
  }

  Future<void> _loadExistingUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (name.isNotEmpty) {
      setState(() {
        _fullNameController.text = name;
      });
    }
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _pageController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() async {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  String _formatDateForApi(String dateStr) {
    // Input format: dd-mm-yyyy -> Output format: yyyy-mm-dd
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
    return dateStr;
  }

  Future<void> _startSyncAndFinish() async {
    _nextPage(); // Move to SyncProgressStep
    setState(() {
      _isSyncing = true;
      _syncProgress = 0.0;
    });

    final List<String> statuses = [
      'Establishing secure local environment...',
      'Encrypting medical health profile...',
      'Analyzing lifestyle metrics and wellness goals...',
      'Submitting profile to Medifit server...',
      'Preparing your personalized dashboard...',
    ];

    for (int i = 0; i < statuses.length; i++) {
      if (!mounted) return;
      setState(() {
        _syncStatusText = statuses[i];
        _syncProgress = (i + 1) / statuses.length;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }

    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email') ?? '';
    final userProvider = prefs.getString('user_provider') ?? 'email';

    // Save full name to preferences if entered
    final enteredName = _fullNameController.text.trim();
    if (enteredName.isNotEmpty) {
      await prefs.setString('user_name', enteredName);
    }

    // Construct the updated API request payload
    final Map<String, dynamic> onboardingPayload = {
      'onboarding_completed': true,
      'completed_at': DateTime.now().toUtc().toIso8601String(),
      'auth': {
        'provider': userProvider,
        'name': enteredName,
        'email': userEmail,
      },
      'profile': {
        'full_name': enteredName,
        'dob': _formatDateForApi(_dobController.text.trim()),
        'gender': _gender,
        'height': double.tryParse(_heightController.text),
        'height_unit': _heightUnit,
        'weight': double.tryParse(_weightController.text),
        'weight_unit': _weightUnit,
        'activity_level': _activityLevel,
        'medical_conditions': _noConditions ? [] : _selectedConditions,
        'no_conditions': _noConditions,
      },
      'goals': _selectedGoals,
      // Retain mock permission mapping for backend API compatibility
      'permissions': {
        'health_connect_connected': false,
        'notifications': {
          'daily_reminder': true,
          'hydration_reminder': true,
          'activity_reminder': true,
          'sleep_reminder': true,
          'challenge_updates': false,
          'rewards': false,
          'ai_tips': true,
        },
      },
    };

    try {
      // API call to backend server
      await AuthService.instance.submitOnboarding(onboardingPayload);

      // Save onboarding completion state locally
      await prefs.setString('onboarding_data', jsonEncode(onboardingPayload));
      await prefs.setBool('onboarding_completed', true);

      if (!mounted) return;

      // Navigate to the main dashboard shell
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSyncing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to submit onboarding to server: ${e.toString().replaceAll('Exception: ', '')}",
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
      // Go back to the medical screen to allow retrying
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Mesh Background
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0C0D11) : const Color(0xFFF4F7FB),
            ),
          ),
          // Glowing Background Blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blobAnimation,
              builder: (context, child) {
                final value = _blobAnimation.value;
                return Stack(
                  children: [
                    // Top-Right Blue/Cyan Blob
                    Positioned(
                      top: -120 + (value * 60),
                      right: -120 + (value * 80),
                      width: 380 + (value * 40),
                      height: 380 + (value * 40),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              isDark
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.cyan.withOpacity(0.25),
                              Colors.blue.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom-Left Purple/Pink Blob
                    Positioned(
                      bottom: -80 + (value * 80),
                      left: -120 + (value * 60),
                      width: 420 - (value * 30),
                      height: 420 - (value * 30),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              isDark
                                  ? Colors.purple.withOpacity(0.12)
                                  : Colors.pink.withOpacity(0.20),
                              Colors.purple.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Main Onboarding Wizard
          SafeArea(
            child: Column(
              children: [
                // Header Logo and Indicator Bar
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Teal Square logo block from mockup
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF006D5B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Sliding Indicator (only show for the input pages, i.e., page < 3)
                      if (_currentPage < 3)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 4,
                              width: isActive ? 24 : 12,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF006D5B)
                                    : (isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      // Step 1: Tell Us About Yourself
                      ProfileStep(
                        formKey: _profileFormKey,
                        fullNameController: _fullNameController,
                        dobController: _dobController,
                        heightController: _heightController,
                        weightController: _weightController,
                        gender: _gender,
                        onGenderChanged: (val) {
                          setState(() => _gender = val);
                        },
                        heightUnit: _heightUnit,
                        onHeightUnitChanged: (val) {
                          setState(() => _heightUnit = val);
                        },
                        weightUnit: _weightUnit,
                        onWeightUnitChanged: (val) {
                          setState(() => _weightUnit = val);
                        },
                        onNext: _nextPage,
                      ),
                      // Step 2: Lifestyle & Goals
                      GoalsStep(
                        selectedGoals: _selectedGoals,
                        onGoalToggled: _toggleGoal,
                        activityLevel: _activityLevel,
                        onActivityLevelChanged: (val) {
                          setState(() => _activityLevel = val);
                        },
                        onBack: _prevPage,
                        onNext: _nextPage,
                      ),
                      // Step 3: Medical Health Profile
                      MedicalStep(
                        selectedConditions: _selectedConditions,
                        onConditionsChanged: (val) {
                          setState(() => _selectedConditions = val);
                        },
                        noConditions: _noConditions,
                        onNoConditionsChanged: (val) {
                          setState(() {
                            _noConditions = val;
                            if (val) {
                              _selectedConditions.clear();
                            }
                          });
                        },
                        onBack: _prevPage,
                        onNext: _startSyncAndFinish,
                      ),
                      // Step 4: Loading & Syncing Progress
                      SyncProgressStep(
                        progress: _syncProgress,
                        statusText: _syncStatusText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

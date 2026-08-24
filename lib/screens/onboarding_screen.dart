import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_brand.dart';
import '../services/auth_service.dart';
import '../widgets/onboarding/profile_step.dart';
import '../widgets/onboarding/goals_step.dart';
import '../widgets/onboarding/company_step.dart';
import '../widgets/onboarding/medical_step.dart';
import '../widgets/onboarding/consent_step.dart';
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
  final int _totalPages =
      6; // Profile, Goals, Company, Medical, Consent + 1 sync step
  static const int _consentPageIndex = 4;

  // Form keys for validation
  final _profileFormKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();

  // State Variables
  String _gender = 'Female';
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  String _activityLevel = 'Active';
  final List<String> _selectedGoals = [];
  List<String> _selectedConditions = [];
  bool _noConditions = false;

  // Company/facility selection (enrolment)
  bool _loadingCompanyData = true;
  String? _companyLoadError;
  List<CompanyOption> _corporates = [];
  List<CompanyOption> _facilities = [];
  String? _selectedCorporateId;
  String? _selectedFacilityId;

  // Consent grants — keys match wellness-server's ConsentKey values
  final Map<String, bool> _consentGrants = {
    'terms': false,
    'healthData': false,
    'medicalShare': false,
    'employerAggregate': false,
  };

  // Sync state
  double _syncProgress = 0.0;
  String _syncStatusText = 'Initializing secure container...';
  // ignore: unused_field
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
    _loadCompanyData();
    // Rebuild on every keystroke so ConsentStep's continue-button enablement
    // (which reads signatureController.text at build time) stays live.
    _signatureController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadCompanyData() async {
    setState(() {
      _loadingCompanyData = true;
      _companyLoadError = null;
    });
    try {
      final corpJson = await AuthService.instance.listEnrolmentCorporates();
      final facJson = await AuthService.instance.listEnrolmentFacilities();
      if (!mounted) return;
      setState(() {
        _corporates = corpJson
            .map(
              (c) => CompanyOption(
                id: c['id'] as String,
                name: c['name'] as String,
                subtitle: "${c['industry']} · ${c['city']}",
              ),
            )
            .toList();
        _facilities = facJson
            .map(
              (f) => CompanyOption(
                id: f['id'] as String,
                name: f['name'] as String,
                subtitle: "${f['type']} · ${f['city']}",
              ),
            )
            .toList();
        _loadingCompanyData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCompanyData = false;
        _companyLoadError =
            "Couldn't load companies/facilities: ${e.toString().replaceAll('Exception: ', '')}";
      });
    }
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
    _signatureController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() async {
    FocusManager.instance.primaryFocus?.unfocus();
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
      'Submitting profile to ${AppBrand.name} server...',
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

    // Save full name to preferences if entered
    final enteredName = _fullNameController.text.trim();
    if (enteredName.isNotEmpty) {
      await prefs.setString('user_name', enteredName);
    }

    try {
      // Real wellness-server enrolment pipeline (see app/api/v1/enrolment.py):
      // start -> health-assessment -> consent. `consent` auto-activates the
      // Member row (and issues a member code) when no medical clearance is
      // required; otherwise the enrolment lands in the staff clearance queue
      // and the member sees "pending review" until a doctor/HR approves it.
      final started = await AuthService.instance.startEnrolment(
        corporateId: _selectedCorporateId!,
        facilityId: _selectedFacilityId!,
        goal: _selectedGoals.isNotEmpty ? _selectedGoals.first : null,
      );

      final declaredCondition = _noConditions || _selectedConditions.isEmpty
          ? null
          : _selectedConditions.join(', ');
      await AuthService.instance.submitHealthAssessment(
        answers: {
          'conditions': _noConditions
              ? 'no'
              : (_selectedConditions.isEmpty ? 'no' : 'yes'),
        },
        declaredCondition: declaredCondition,
      );

      final result = await AuthService.instance.submitEnrolmentConsent(
        grants: _consentGrants,
        signatureName: _signatureController.text.trim(),
      );

      final stage =
          result['stage'] as String? ?? started['stage'] as String? ?? '';
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('enrolment_stage', stage);

      // The server's member code ends in the four-digit employee code. It is
      // issued only once activation completes and is used after a facility QR
      // scan to begin a workout session.
      final accessCode = result['access_code'] as String?;
      final checkinCode = accessCode?.split('-').last;
      if (checkinCode != null && RegExp(r'^\d{4}$').hasMatch(checkinCode)) {
        await prefs.setString('member_checkin_code', checkinCode);
      }

      if (!mounted) return;

      if (stage != 'activated') {
        // Needs medical clearance before a Member row/member code exists —
        // dashboard_screen.dart and other member-only endpoints will 409
        // until staff approves it. Let the user know instead of silently
        // dropping them into a broken dashboard.
        setState(() {
          _isSyncing = false;
          _syncStatusText = 'Submitted — awaiting medical clearance review';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Your enrolment needs a quick medical clearance review by our staff before your dashboard unlocks. We'll notify you once it's approved.",
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 6),
          ),
        );
        return;
      }

      if (checkinCode != null &&
          RegExp(r'^\d{4}$').hasMatch(checkinCode) &&
          mounted) {
        await _showCheckinCodeDialog(checkinCode);
      }
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
            "Failed to submit enrolment to server: ${e.toString().replaceAll('Exception: ', '')}",
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
      // Go back to the consent screen to allow retrying
      _pageController.animateToPage(
        _consentPageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _showCheckinCodeDialog(String code) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.pin_outlined, size: 32),
        title: const Text('Your workout check-in code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'After scanning a ${AppBrand.name} facility QR code, enter this code to start a workout session. Keep it private.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 30,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('I saved it'),
          ),
        ],
      ),
    );
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
                                  ? Colors.blue.withValues(alpha: 0.15)
                                  : Colors.cyan.withValues(alpha: 0.25),
                              Colors.blue.withValues(alpha: 0.0),
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
                                  ? Colors.purple.withValues(alpha: 0.12)
                                  : Colors.pink.withValues(alpha: 0.20),
                              Colors.purple.withValues(alpha: 0.0),
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
                    children: [
                      if (_currentPage < 5)
                        IconButton(
                          tooltip: _currentPage == 0
                              ? 'Back to sign in'
                              : 'Previous step',
                          onPressed: _prevPage,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          AppBrand.iconAssetPath,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            color: const Color(0xFF006D5B),
                            child: Text(
                              AppBrand.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (_currentPage < 5)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 4,
                              width: isActive ? 24 : 12,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF006D5B)
                                    : (isDark
                                          ? Colors.white24
                                          : const Color(0xFFE2E8F0)),
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
                      if (page == _consentPageIndex &&
                          _signatureController.text.trim().isEmpty) {
                        _signatureController.text = _fullNameController.text
                            .trim();
                      }
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
                        onBack: _prevPage,
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
                      // Step 3: Company & Home Facility
                      CompanyStep(
                        isLoading: _loadingCompanyData,
                        loadError: _companyLoadError,
                        corporates: _corporates,
                        facilities: _facilities,
                        selectedCorporateId: _selectedCorporateId,
                        selectedFacilityId: _selectedFacilityId,
                        onCorporateSelected: (id) {
                          setState(() => _selectedCorporateId = id);
                        },
                        onFacilitySelected: (id) {
                          setState(() => _selectedFacilityId = id);
                        },
                        onBack: _prevPage,
                        onNext: _nextPage,
                        onRetry: _loadCompanyData,
                      ),
                      // Step 4: Medical Health Profile
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
                        onNext: _nextPage,
                      ),
                      // Step 5: Consent & Signature
                      ConsentStep(
                        grants: _consentGrants,
                        onToggleGrant: (key) {
                          setState(
                            () => _consentGrants[key] =
                                !(_consentGrants[key] ?? false),
                          );
                        },
                        signatureController: _signatureController,
                        onBack: _prevPage,
                        onNext: _startSyncAndFinish,
                      ),
                      // Step 6: Loading & Syncing Progress
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

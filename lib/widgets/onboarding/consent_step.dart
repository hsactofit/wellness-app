import 'package:flutter/material.dart';
import '../../app_brand.dart';
import 'fade_slide_transition.dart';

class ConsentStep extends StatelessWidget {
  final Map<String, bool>
  grants; // keys: terms, healthData, medicalShare, employerAggregate
  final bool medicalShareRequired;
  final ValueChanged<String> onToggleGrant;
  final TextEditingController signatureController;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const ConsentStep({
    super.key,
    required this.grants,
    required this.medicalShareRequired,
    required this.onToggleGrant,
    required this.signatureController,
    required this.onBack,
    required this.onNext,
  });

  List<Map<String, String>> get _clauses => [
    {
      'key': 'terms',
      'title': 'Terms of Service',
      'body':
          'I agree to ${AppBrand.name}\'s terms of service and program participation rules.',
    },
    {
      'key': 'healthData',
      'title': 'Health Data Collection',
      'body':
          'I consent to ${AppBrand.name} collecting my wearable/health metrics (steps, sleep, heart rate) to power my wellness dashboard.',
    },
    {
      'key': 'medicalShare',
      'title': 'Medical Data Sharing',
      'body':
          'I consent to sharing relevant medical assessment answers with ${AppBrand.name}\'s clinical staff for clearance review, where applicable.',
    },
    {
      'key': 'employerAggregate',
      'title': 'Aggregate Reporting to Employer',
      'body':
          'I consent to my employer receiving only anonymized, aggregate program participation statistics — never my individual health data.',
    },
  ];

  bool _isRequired(String key) => key != 'medicalShare' || medicalShareRequired;

  String _requirementLabel(String key) {
    if (key == 'medicalShare') {
      return medicalShareRequired
          ? 'Required for doctor clearance'
          : 'Optional';
    }
    return 'Required';
  }

  bool get _allRequiredGranted => _clauses
      .where((clause) => _isRequired(clause['key']!))
      .every((clause) => grants[clause['key']] == true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canContinue =
        _allRequiredGranted && signatureController.text.trim().isNotEmpty;
    final consentInstruction = medicalShareRequired
        ? 'All four consents below are required because a doctor must review your declared condition before clearance.'
        : 'Three consents below are required to activate your ${AppBrand.name} membership. Medical Data Sharing is optional.';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideTransition(
                    delay: Duration.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Consent & Authorization",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.6,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          consentInstruction,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._clauses.map((clause) {
                    final key = clause['key']!;
                    final granted = grants[key] == true;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => onToggleGrant(key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: granted
                                ? const Color(
                                    0xFF006D5B,
                                  ).withValues(alpha: 0.06)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.04)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: granted
                                  ? const Color(0xFF006D5B)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.grey.withValues(alpha: 0.18)),
                              width: granted ? 2.0 : 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: granted,
                                activeColor: const Color(0xFF006D5B),
                                onChanged: (_) => onToggleGrant(key),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clause['title']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _requirementLabel(key),
                                      style: TextStyle(
                                        color:
                                            key == 'medicalShare' &&
                                                !medicalShareRequired
                                            ? const Color(0xFF006D5B)
                                            : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      clause['body']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.3,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Text(
                    "Type your full name as your electronic signature",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey[300]
                          : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: signatureController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "Full legal name",
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF006D5B),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3EDF7),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: onBack,
                    child: const Text(
                      "PREVIOUS",
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006D5B),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: const Color(
                        0xFF006D5B,
                      ).withValues(alpha: 0.3),
                      elevation: 4,
                    ),
                    onPressed: canContinue
                        ? onNext
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please agree to the required consents and sign your name',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "AGREE & ACTIVATE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
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

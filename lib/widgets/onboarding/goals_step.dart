import 'package:flutter/material.dart';
import 'fade_slide_transition.dart';

class GoalsStep extends StatelessWidget {
  final List<String> selectedGoals;
  final void Function(String goal) onGoalToggled;
  final String activityLevel;
  final ValueChanged<String> onActivityLevelChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const GoalsStep({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
    required this.activityLevel,
    required this.onActivityLevelChanged,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> activityLevels = [
      {
        'title': 'Sedentary',
        'desc': 'Desk job, little to no exercise in a typical week.',
      },
      {
        'title': 'Moderate',
        'desc': 'Active 2-3 times a week, moderate daily movement.',
      },
      {
        'title': 'Active',
        'desc': 'Intense exercise 4-5 times a week, high daily steps.',
      },
      {
        'title': 'Very Active',
        'desc': 'Physical job or professional athlete training daily.',
      },
    ];

    final List<Map<String, dynamic>> healthGoals = [
      {
        'title': 'Weight Loss',
        'icon': Icons.shopping_bag_outlined, // kettlebell/shopping bag shape
      },
      {
        'title': 'Muscle Gain',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'title': 'Better Sleep',
        'icon': Icons.nightlight_round_outlined,
      },
      {
        'title': 'Stress Reduction',
        'icon': Icons.self_improvement_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideTransition(
                    delay: Duration.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Lifestyle & Goals",
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
                          "Tell us about your current lifestyle and what you're looking to achieve with Vitality.",
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

                  // Your Activity Level
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: const [
                        Icon(Icons.directions_run_rounded, color: Color(0xFF006D5B), size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Your Activity Level",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Activity Cards
                  ...List.generate(activityLevels.length, (idx) {
                    final item = activityLevels[idx];
                    final title = item['title']!;
                    final desc = item['desc']!;
                    final isSelected = activityLevel == title;

                    return FadeSlideTransition(
                      delay: Duration(milliseconds: 120 + (idx * 40)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () => onActivityLevelChanged(title),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF006D5B).withOpacity(0.06)
                                  : (isDark ? Colors.white.withOpacity(0.04) : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF006D5B)
                                    : (isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.18)),
                                width: isSelected ? 2.0 : 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Primary Health Goals Header
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      children: const [
                        Icon(Icons.flag_outlined, color: Color(0xFF006D5B), size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Primary Health Goals",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid of Goals (2x2)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: healthGoals.length,
                    itemBuilder: (context, idx) {
                      final goal = healthGoals[idx];
                      final title = goal['title']!;
                      final icon = goal['icon'] as IconData;
                      final isSelected = selectedGoals.contains(title);
                      final itemDelay = Duration(milliseconds: 320 + (idx * 40));

                      return FadeSlideTransition(
                        delay: itemDelay,
                        child: GestureDetector(
                          onTap: () => onGoalToggled(title),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF006D5B).withOpacity(0.06)
                                      : (isDark ? Colors.white.withOpacity(0.04) : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF006D5B)
                                        : (isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.18)),
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icon,
                                      color: const Color(0xFF006D5B),
                                      size: 26,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(1),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF006D5B),
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Button Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D5B),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    shadowColor: const Color(0xFF006D5B).withOpacity(0.3),
                    elevation: 3,
                  ),
                  onPressed: selectedGoals.isEmpty ? null : onNext,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: onBack,
                    child: const Text(
                      "Back to Personal Info",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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

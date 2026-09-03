import 'package:flutter/material.dart';
import 'fade_slide_transition.dart';
import '../../theme/app_theme.dart';

class MedicalStep extends StatefulWidget {
  final List<String> selectedConditions;
  final void Function(List<String> conditions) onConditionsChanged;
  final bool noConditions;
  final ValueChanged<bool> onNoConditionsChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const MedicalStep({
    super.key,
    required this.selectedConditions,
    required this.onConditionsChanged,
    required this.noConditions,
    required this.onNoConditionsChanged,
    required this.onBack,
    required this.onNext,
  });

  @override
  State<MedicalStep> createState() => _MedicalStepState();
}

class _MedicalStepState extends State<MedicalStep> {
  final List<Map<String, String>> _predefinedConditions = [
    {
      'title': 'Hypertension',
      'subtitle': 'High blood pressure management',
      'icon': 'favorite_outline',
    },
    {
      'title': 'Diabetes',
      'subtitle': 'Type 1, Type 2, or Prediabetes',
      'icon': 'water_drop_outlined',
    },
    {
      'title': 'Asthma',
      'subtitle': 'Respiratory health and breathing',
      'icon': 'air_outlined',
    },
    {
      'title': 'Heart Condition',
      'subtitle': 'Any cardiovascular health concerns',
      'icon': 'favorite_rounded',
    },
    {
      'title': 'Allergies',
      'subtitle': 'Severe or chronic allergic reactions',
      'icon': 'warning_amber_rounded',
    },
  ];

  final List<String> _customConditions = [];
  final TextEditingController _customConditionController =
      TextEditingController();

  @override
  void dispose() {
    _customConditionController.dispose();
    super.dispose();
  }

  void _toggleCondition(String title) {
    if (widget.noConditions) return;

    final updated = List<String>.from(widget.selectedConditions);
    if (updated.contains(title)) {
      updated.remove(title);
    } else {
      updated.add(title);
    }
    widget.onConditionsChanged(updated);
  }

  void _showAddCustomConditionDialog() {
    _customConditionController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Add Custom Condition",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _customConditionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: "Enter condition name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.actionOf(
                    context,
                    dark: const Color(0xFF006D5B),
                  ),
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.actionOf(
                  context,
                  dark: const Color(0xFF006D5B),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final text = _customConditionController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    if (!_customConditions.contains(text)) {
                      _customConditions.add(text);
                    }
                  });
                  _toggleCondition(text);
                }
                Navigator.pop(context);
              },
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite_outline':
        return Icons.favorite_border;
      case 'water_drop_outlined':
        return Icons.water_drop_outlined;
      case 'air_outlined':
        return Icons.air_outlined;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      default:
        return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allConditions = [
      ..._predefinedConditions,
      ..._customConditions.map(
        (c) => {
          'title': c,
          'subtitle': 'Custom condition',
          'icon': 'medical_services_outlined',
        },
      ),
    ];

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
                          "Medical Health Profile",
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
                          "Select any conditions that apply to you. This helps us tailor your wellness insights.",
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

                  // Conditions List
                  ...List.generate(allConditions.length, (idx) {
                    final cond = allConditions[idx];
                    final title = cond['title']!;
                    final subtitle = cond['subtitle']!;
                    final iconName = cond['icon']!;
                    final isSelected =
                        widget.selectedConditions.contains(title) &&
                        !widget.noConditions;

                    return FadeSlideTransition(
                      delay: Duration(milliseconds: 100 + (idx * 50)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () => _toggleCondition(title),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.actionOf(
                                      context,
                                      dark: const Color(0xFF006D5B),
                                    ).withValues(alpha: 0.06)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.04)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.actionOf(
                                        context,
                                        dark: const Color(0xFF006D5B),
                                      )
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.grey.withValues(
                                              alpha: 0.18,
                                            )),
                                width: isSelected ? 2.0 : 1.2,
                              ),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.actionOf(
                                            context,
                                            dark: const Color(0xFF006D5B),
                                          ).withValues(alpha: 0.12)
                                        : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                              : const Color(0xFFE0F2F1)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconData(iconName),
                                    color: AppTheme.actionOf(
                                      context,
                                      dark: const Color(0xFF006D5B),
                                    ),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.actionOf(
                                      context,
                                      dark: const Color(0xFF006D5B),
                                    ),
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Add Other Condition button
                  FadeSlideTransition(
                    delay: Duration(
                      milliseconds: 100 + (allConditions.length * 50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: widget.noConditions
                            ? null
                            : _showAddCustomConditionDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: widget.noConditions
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : AppTheme.actionOf(
                                      context,
                                      dark: const Color(0xFF006D5B),
                                    ).withValues(alpha: 0.5),
                              width: 1.5,
                              style: BorderStyle
                                  .values[1], // dotted border style simulation
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: widget.noConditions
                                      ? Colors.grey
                                      : AppTheme.actionOf(
                                          context,
                                          dark: const Color(0xFF006D5B),
                                        ),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "ADD OTHER CONDITION",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.noConditions
                                        ? Colors.grey
                                        : AppTheme.actionOf(
                                            context,
                                            dark: const Color(0xFF006D5B),
                                          ),
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // "I don't have any of these conditions" checkbox
                  FadeSlideTransition(
                    delay: Duration(
                      milliseconds: 150 + (allConditions.length * 50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: InkWell(
                        onTap: () {
                          widget.onNoConditionsChanged(!widget.noConditions);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: widget.noConditions,
                                  activeColor: AppTheme.actionOf(
                                    context,
                                    dark: const Color(0xFF006D5B),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      widget.onNoConditionsChanged(val);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "I don't have any of these conditions",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : const Color(0xFF334155),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Security Information Note
                  FadeSlideTransition(
                    delay: Duration(
                      milliseconds: 200 + (allConditions.length * 50),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFC8E6C9),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Your medical data is encrypted and only used to personalize your wellness experience. We never share your data with third parties.",
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF2E7D32),
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Navigation Row
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
                      backgroundColor: const Color(0xFFEEF1F6),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: widget.onBack,
                    child: const Text(
                      "PREVIOUS",
                      style: TextStyle(
                        color: AppTheme.brandInk,
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
                      backgroundColor: AppTheme.actionOf(
                        context,
                        dark: const Color(0xFF006D5B),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadowColor: AppTheme.actionOf(
                        context,
                        dark: const Color(0xFF006D5B),
                      ).withValues(alpha: 0.3),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (!widget.noConditions &&
                          widget.selectedConditions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please select a condition or check the box below",
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      widget.onNext();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "CONTINUE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
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

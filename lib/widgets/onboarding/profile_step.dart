import 'package:flutter/material.dart';
import 'fade_slide_transition.dart';

class ProfileStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController dobController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String gender;
  final ValueChanged<String> onGenderChanged;
  final String heightUnit;
  final ValueChanged<String> onHeightUnitChanged;
  final String weightUnit;
  final ValueChanged<String> onWeightUnitChanged;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const ProfileStep({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.dobController,
    required this.heightController,
    required this.weightController,
    required this.gender,
    required this.onGenderChanged,
    required this.heightUnit,
    required this.onHeightUnitChanged,
    required this.weightUnit,
    required this.onWeightUnitChanged,
    required this.onNext,
    this.onBack,
  });

  void _showGenderPicker(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Select Gender",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ...["Female", "Male", "Other"].map((g) {
                final isSelected = gender == g;
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Icon(
                      g == "Female"
                          ? Icons.female_rounded
                          : g == "Male"
                          ? Icons.male_rounded
                          : Icons.transgender_rounded,
                      color: isSelected ? const Color(0xFF006D5B) : Colors.grey,
                    ),
                    title: Text(
                      g,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF006D5B)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF006D5B),
                          )
                        : null,
                    onTap: () {
                      onGenderChanged(g);
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitToggle(
    String currentUnit,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = currentUnit.toLowerCase() == opt.toLowerCase();
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              onChanged(opt.toLowerCase());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF006D5B)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.grey.withValues(alpha: 0.6),
        fontWeight: FontWeight.w400,
        fontSize: 15,
      ),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF006D5B), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }

  Widget _buildFieldLabel(
    String labelText, {
    Widget? trailing,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0, top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlideTransition(
                delay: Duration.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tell Us About Yourself",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.6,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We use this data to calculate your personalized wellness scores and recovery goals.",
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Full Name
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel("Full Name", isDark: isDark),
                    TextFormField(
                      controller: fullNameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      decoration: _inputDecoration(
                        hintText: "John Doe",
                        prefixIcon: Icons.person_outline_rounded,
                        isDark: isDark,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Please enter your full name"
                          : null,
                    ),
                  ],
                ),
              ),

              // Date of Birth
              FadeSlideTransition(
                delay: const Duration(milliseconds: 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel("Date of Birth", isDark: isDark),
                    TextFormField(
                      controller: dobController,
                      readOnly: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        hintText: "dd-mm-yyyy",
                        prefixIcon: Icons.calendar_today_outlined,
                        suffixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        isDark: isDark,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? "Please select your date of birth"
                          : null,
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1998, 1, 1),
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF006D5B),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF0F172A),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (selectedDate != null) {
                          final day = selectedDate.day.toString().padLeft(
                            2,
                            '0',
                          );
                          final month = selectedDate.month.toString().padLeft(
                            2,
                            '0',
                          );
                          final year = selectedDate.year.toString();
                          dobController.text = "$day-$month-$year";
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Gender Selector
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel("Gender", isDark: isDark),
                    GestureDetector(
                      onTap: () => _showGenderPicker(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          style: TextStyle(
                            color: gender.isEmpty || gender == "Select Gender"
                                ? (isDark ? Colors.white38 : Colors.grey)
                                : (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A)),
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                          decoration: _inputDecoration(
                            hintText: gender.isEmpty ? "Select Gender" : gender,
                            prefixIcon: Icons.people_outline_rounded,
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                              size: 22,
                            ),
                            isDark: isDark,
                          ),
                          validator: (v) =>
                              (gender.isEmpty || gender == "Select Gender")
                              ? "Please select your gender"
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Height
              FadeSlideTransition(
                delay: const Duration(milliseconds: 250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      "Height",
                      trailing: _buildUnitToggle(heightUnit, [
                        "CM",
                        "IN",
                      ], onHeightUnitChanged),
                      isDark: isDark,
                    ),
                    TextFormField(
                      controller: heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        hintText: heightUnit.toLowerCase() == "cm"
                            ? "180"
                            : "71",
                        prefixIcon: Icons.straighten_rounded,
                        isDark: isDark,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your height";
                        }
                        if (double.tryParse(v) == null) {
                          return "Please enter a valid number";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Weight
              FadeSlideTransition(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(
                      "Weight",
                      trailing: _buildUnitToggle(weightUnit, [
                        "KG",
                        "LBS",
                      ], onWeightUnitChanged),
                      isDark: isDark,
                    ),
                    TextFormField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(
                        hintText: weightUnit.toLowerCase() == "kg"
                            ? "75"
                            : "165",
                        prefixIcon: Icons.scale_outlined,
                        isDark: isDark,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter your weight";
                        }
                        if (double.tryParse(v) == null) {
                          return "Please enter a valid number";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Next Button
              FadeSlideTransition(
                delay: const Duration(milliseconds: 350),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF006D5B).withValues(alpha: 0.3),
                  ),
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (formKey.currentState!.validate()) {
                      onNext();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Next",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              if (onBack != null) ...[
                const SizedBox(height: 12),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 380),
                  child: Center(
                    child: TextButton(
                      onPressed: onBack,
                      child: const Text(
                        "Back to sign in",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Privacy Policy Footer
              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text.rich(
                      TextSpan(
                        text: "By continuing, you agree to our ",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF64748B),
                        ),
                        children: [
                          TextSpan(
                            text: "Privacy Policy",
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

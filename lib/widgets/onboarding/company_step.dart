import 'package:flutter/material.dart';
import 'fade_slide_transition.dart';

class CompanyOption {
  final String id;
  final String name;
  final String subtitle;

  const CompanyOption({required this.id, required this.name, required this.subtitle});
}

class CompanyStep extends StatelessWidget {
  final bool isLoading;
  final String? loadError;
  final List<CompanyOption> corporates;
  final List<CompanyOption> facilities;
  final String? selectedCorporateId;
  final String? selectedFacilityId;
  final ValueChanged<String> onCorporateSelected;
  final ValueChanged<String> onFacilitySelected;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  const CompanyStep({
    super.key,
    required this.isLoading,
    required this.loadError,
    required this.corporates,
    required this.facilities,
    required this.selectedCorporateId,
    required this.selectedFacilityId,
    required this.onCorporateSelected,
    required this.onFacilitySelected,
    required this.onBack,
    required this.onNext,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canContinue = selectedCorporateId != null && selectedFacilityId != null;

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
                          "Your Employer",
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
                          "Select the company that enrolled you and the facility you'll check in at.",
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
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF006D5B))),
                    )
                  else if (loadError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            loadError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(onPressed: onRetry, child: const Text("Retry")),
                        ],
                      ),
                    )
                  else ...[
                    _sectionLabel("Company", Icons.apartment_rounded),
                    const SizedBox(height: 10),
                    ...corporates.map(
                      (c) => _optionTile(
                        context: context,
                        isSelected: selectedCorporateId == c.id,
                        title: c.name,
                        subtitle: c.subtitle,
                        onTap: () => onCorporateSelected(c.id),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionLabel("Home Facility", Icons.fitness_center_rounded),
                    const SizedBox(height: 10),
                    ...facilities.map(
                      (f) => _optionTile(
                        context: context,
                        isSelected: selectedFacilityId == f.id,
                        title: f.name,
                        subtitle: f.subtitle,
                        onTap: () => onFacilitySelected(f.id),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE3EDF7),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      shadowColor: const Color(0xFF006D5B).withOpacity(0.3),
                      elevation: 4,
                    ),
                    onPressed: canContinue
                        ? onNext
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select your company and home facility"),
                                backgroundColor: Colors.orange,
                              ),
                            );
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
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
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

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF006D5B), size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF475569)),
        ),
      ],
    );
  }

  Widget _optionTile({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: onTap,
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF006D5B), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

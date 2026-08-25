class MealAnalysis {
  final String id;
  final String description;
  final String? mealName;
  final List<Map<String, dynamic>> items;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatsG;
  final List<String> assumptions;
  final bool needsClarification;
  final String? clarificationQuestion;
  final String status;
  final String? mealLogId;

  const MealAnalysis({
    required this.id,
    required this.description,
    required this.mealName,
    required this.items,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.assumptions,
    required this.needsClarification,
    required this.clarificationQuestion,
    required this.status,
    required this.mealLogId,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> json) {
    double? number(String key) => (json[key] as num?)?.toDouble();
    return MealAnalysis(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mealName: json['meal_name']?.toString(),
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      calories: (json['calories'] as num?)?.round(),
      proteinG: number('protein_g'),
      carbsG: number('carbs_g'),
      fatsG: number('fats_g'),
      assumptions: (json['assumptions'] as List<dynamic>? ?? [])
          .map((value) => value.toString())
          .toList(),
      needsClarification: json['needs_clarification'] == true,
      clarificationQuestion: json['clarification_question']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      mealLogId: json['meal_log_id']?.toString(),
    );
  }
}

class NutritionTracker {
  final Map<String, dynamic> today;
  final List<Map<String, dynamic>> series;

  const NutritionTracker({required this.today, required this.series});

  factory NutritionTracker.fromJson(Map<String, dynamic> json) => NutritionTracker(
    today: Map<String, dynamic>.from(json['today'] as Map? ?? const {}),
    series: (json['series'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList(),
  );
}

enum PlanKind { workout, nutrition }

const List<String> _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String currentWeekdayName() => _weekdayNames[DateTime.now().weekday - 1];

// ── Workout ──────────────────────────────────────────────────────

class WorkoutExercise {
  final String name;
  final int? sets;
  final String? reps;
  final int? restSec;
  final String? notes;

  const WorkoutExercise({
    required this.name,
    this.sets,
    this.reps,
    this.restSec,
    this.notes,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      name: json['name']?.toString() ?? 'Exercise',
      sets: (json['sets'] as num?)?.toInt(),
      reps: json['reps']?.toString(),
      restSec: (json['rest_sec'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
    );
  }

  String get dosageLabel {
    final parts = <String>[];
    if (sets != null) parts.add('$sets sets');
    if (reps != null && reps!.isNotEmpty) parts.add('$reps reps');
    if (restSec != null) parts.add('${restSec}s rest');
    return parts.join(' · ');
  }
}

class WorkoutPlanDay {
  final String day;
  final String? focus;
  final bool isRestDay;
  final List<WorkoutExercise> exercises;

  const WorkoutPlanDay({
    required this.day,
    this.focus,
    this.isRestDay = false,
    this.exercises = const [],
  });

  factory WorkoutPlanDay.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanDay(
      day: json['day']?.toString() ?? '',
      focus: json['focus']?.toString(),
      isRestDay: json['is_rest_day'] as bool? ?? false,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map(
                (e) => WorkoutExercise.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class WorkoutPlan {
  final String id;
  final String title;
  final String? summary;
  final String? goal;
  final String? experience;
  final String? location;
  final List<String> equipment;
  final int sessionMinutes;
  final int daysPerWeek;
  final List<WorkoutPlanDay> days;
  final DateTime createdAt;

  const WorkoutPlan({
    required this.id,
    required this.title,
    this.summary,
    this.goal,
    this.experience,
    this.location,
    this.equipment = const [],
    required this.sessionMinutes,
    required this.daysPerWeek,
    this.days = const [],
    required this.createdAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Workout Plan',
      summary: json['summary']?.toString(),
      goal: json['goal']?.toString(),
      experience: json['experience']?.toString(),
      location: json['location']?.toString(),
      equipment:
          (json['equipment'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sessionMinutes: (json['session_minutes'] as num?)?.toInt() ?? 45,
      daysPerWeek: (json['days_per_week'] as num?)?.toInt() ?? 4,
      days:
          (json['days'] as List<dynamic>?)
              ?.map(
                (d) => WorkoutPlanDay.fromJson(
                  Map<String, dynamic>.from(d as Map),
                ),
              )
              .toList() ??
          const [],
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory WorkoutPlan.fromReviewedJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Workout Plan',
      summary: json['summary']?.toString(),
      sessionMinutes: 45,
      daysPerWeek: 4,
      days:
          (json['content'] as List<dynamic>?)
              ?.map(
                (day) => WorkoutPlanDay.fromJson(
                  Map<String, dynamic>.from(day as Map),
                ),
              )
              .toList() ??
          const [],
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  WorkoutPlanDay? dayFor(String weekdayName) {
    for (final d in days) {
      if (d.day.toLowerCase() == weekdayName.toLowerCase()) return d;
    }
    return null;
  }

  int get totalExercises => days.fold(0, (s, d) => s + d.exercises.length);
}

// ── Nutrition ────────────────────────────────────────────────────

class NutritionMeal {
  final String name;
  final String items;
  final int? calories;
  final int? proteinG;
  final int? carbsG;
  final int? fatG;

  const NutritionMeal({
    required this.name,
    required this.items,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  factory NutritionMeal.fromJson(Map<String, dynamic> json) {
    return NutritionMeal(
      name: json['name']?.toString() ?? 'Meal',
      items: json['items']?.toString() ?? '',
      calories: (json['calories'] as num?)?.toInt(),
      proteinG: (json['protein_g'] as num?)?.toInt(),
      carbsG: (json['carbs_g'] as num?)?.toInt(),
      fatG: (json['fat_g'] as num?)?.toInt(),
    );
  }

  String get macrosLabel {
    final parts = <String>[];
    if (calories != null) parts.add('$calories kcal');
    if (proteinG != null) parts.add('P ${proteinG}g');
    if (carbsG != null) parts.add('C ${carbsG}g');
    if (fatG != null) parts.add('F ${fatG}g');
    return parts.join(' · ');
  }
}

class NutritionPlanDay {
  final String day;
  final int? totalCalories;
  final List<NutritionMeal> meals;

  const NutritionPlanDay({
    required this.day,
    this.totalCalories,
    this.meals = const [],
  });

  factory NutritionPlanDay.fromJson(Map<String, dynamic> json) {
    return NutritionPlanDay(
      day: json['day']?.toString() ?? '',
      totalCalories: (json['total_calories'] as num?)?.toInt(),
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map(
                (m) =>
                    NutritionMeal.fromJson(Map<String, dynamic>.from(m as Map)),
              )
              .toList() ??
          const [],
    );
  }
}

class NutritionPlan {
  final String id;
  final String title;
  final String? summary;
  final String? dietary;
  final List<String> allergies;
  final int mealsPerDay;
  final int? calorieTarget;
  final String? cuisine;
  final List<NutritionPlanDay> days;
  final DateTime createdAt;

  const NutritionPlan({
    required this.id,
    required this.title,
    this.summary,
    this.dietary,
    this.allergies = const [],
    required this.mealsPerDay,
    this.calorieTarget,
    this.cuisine,
    this.days = const [],
    required this.createdAt,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    return NutritionPlan(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Nutrition Plan',
      summary: json['summary']?.toString(),
      dietary: json['dietary']?.toString(),
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mealsPerDay: (json['meals_per_day'] as num?)?.toInt() ?? 3,
      calorieTarget: (json['calorie_target'] as num?)?.toInt(),
      cuisine: json['cuisine']?.toString(),
      days:
          (json['days'] as List<dynamic>?)
              ?.map(
                (d) => NutritionPlanDay.fromJson(
                  Map<String, dynamic>.from(d as Map),
                ),
              )
              .toList() ??
          const [],
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory NutritionPlan.fromReviewedJson(Map<String, dynamic> json) {
    final days =
        (json['content'] as List<dynamic>?)
            ?.map(
              (day) => NutritionPlanDay.fromJson(
                Map<String, dynamic>.from(day as Map),
              ),
            )
            .toList() ??
        const <NutritionPlanDay>[];
    return NutritionPlan(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Nutrition Plan',
      summary: json['summary']?.toString(),
      mealsPerDay: days.isEmpty ? 3 : days.first.meals.length,
      days: days,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  NutritionPlanDay? dayFor(String weekdayName) {
    for (final d in days) {
      if (d.day.toLowerCase() == weekdayName.toLowerCase()) return d;
    }
    return null;
  }

  int get totalMeals => days.fold(0, (s, d) => s + d.meals.length);
}

/// Dashboard-friendly snapshot for either plan type, derived from today's
/// weekday slice of the member's latest generated plan — reads the already-
/// fetched plan, no extra network or LLM call.
class TodayPlanSnapshot {
  final PlanKind kind;
  final String? planTitle;
  final String? subtitle;
  final int itemCount;
  final bool isRestDay;
  final bool hasPlan;

  const TodayPlanSnapshot({
    required this.kind,
    this.planTitle,
    this.subtitle,
    this.itemCount = 0,
    this.isRestDay = false,
    this.hasPlan = false,
  });

  String get title =>
      planTitle ?? (kind == PlanKind.workout ? 'Workout Plan' : 'Meal Plan');

  String get preview {
    if (!hasPlan) {
      return kind == PlanKind.workout
          ? 'Generate a plan for today'
          : 'Generate a meal plan';
    }
    if (isRestDay) return 'Rest day — recover well';
    if (subtitle != null && subtitle!.isNotEmpty) return subtitle!;
    if (kind == PlanKind.workout) {
      return itemCount == 0
          ? 'View today\'s session'
          : '$itemCount exercises lined up';
    }
    return itemCount == 0 ? 'View today\'s meals' : '$itemCount meals planned';
  }

  factory TodayPlanSnapshot.fromWorkout(WorkoutPlan? plan) {
    if (plan == null) return const TodayPlanSnapshot(kind: PlanKind.workout);
    final today = plan.dayFor(currentWeekdayName());
    if (today == null) {
      return TodayPlanSnapshot(
        kind: PlanKind.workout,
        planTitle: plan.title,
        hasPlan: true,
      );
    }
    return TodayPlanSnapshot(
      kind: PlanKind.workout,
      planTitle: plan.title,
      subtitle: today.focus ?? (today.isRestDay ? 'Rest day' : null),
      itemCount: today.exercises.length,
      isRestDay: today.isRestDay,
      hasPlan: true,
    );
  }

  factory TodayPlanSnapshot.fromNutrition(NutritionPlan? plan) {
    if (plan == null) return const TodayPlanSnapshot(kind: PlanKind.nutrition);
    final today = plan.dayFor(currentWeekdayName());
    if (today == null) {
      return TodayPlanSnapshot(
        kind: PlanKind.nutrition,
        planTitle: plan.title,
        hasPlan: true,
      );
    }
    final kcal =
        today.totalCalories ??
        today.meals.fold<int>(0, (s, m) => s + (m.calories ?? 0));
    return TodayPlanSnapshot(
      kind: PlanKind.nutrition,
      planTitle: plan.title,
      subtitle: kcal > 0
          ? '$kcal kcal across ${today.meals.length} meals'
          : null,
      itemCount: today.meals.length,
      hasPlan: true,
    );
  }
}

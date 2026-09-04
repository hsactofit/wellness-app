class WeeklyTrainingSummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime asOf;
  final bool planAvailable;
  final String? planMessage;
  final int completedPlannedDays;
  final int plannedDaysDue;
  final int totalPlannedDays;
  final int futurePlannedDays;
  final int actualTrainingDays;
  final List<WeeklyTrainingDay> days;
  final int totalIncludedSessions;
  final List<TrainingTypeCount> trainingTypes;
  final List<IncludedTrainingSession> includedSessions;
  final WeeklyMetric weight;
  final WeeklyMetric restingHeartRate;
  final WeeklyMetric sleep;
  final Map<String, String> activeCorrectionIds;

  const WeeklyTrainingSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.asOf,
    required this.planAvailable,
    required this.planMessage,
    required this.completedPlannedDays,
    required this.plannedDaysDue,
    required this.totalPlannedDays,
    required this.futurePlannedDays,
    required this.actualTrainingDays,
    required this.days,
    required this.totalIncludedSessions,
    required this.trainingTypes,
    required this.includedSessions,
    required this.weight,
    required this.restingHeartRate,
    required this.sleep,
    required this.activeCorrectionIds,
  });

  static WeeklyTrainingSummary? tryParse(Object? value) {
    if (value is! Map) return null;
    try {
      final json = Map<String, dynamic>.from(value);
      final weekStart = DateTime.tryParse(json['week_start']?.toString() ?? '');
      final weekEnd = DateTime.tryParse(json['week_end']?.toString() ?? '');
      final asOf = DateTime.tryParse(json['as_of']?.toString() ?? '');
      final weight = WeeklyMetric.tryParse(json['weight']);
      final heart = WeeklyMetric.tryParse(json['resting_heart_rate']);
      final sleep = WeeklyMetric.tryParse(json['sleep']);
      if (weekStart == null || weekEnd == null || asOf == null || weight == null || heart == null || sleep == null) {
        return null;
      }
      return WeeklyTrainingSummary(
        weekStart: weekStart,
        weekEnd: weekEnd,
        asOf: asOf,
        planAvailable: json['plan_available'] == true,
        planMessage: json['plan_message']?.toString(),
        completedPlannedDays: _int(json['completed_planned_days']),
        plannedDaysDue: _int(json['planned_days_due']),
        totalPlannedDays: _int(json['total_planned_days']),
        futurePlannedDays: _int(json['future_planned_days']),
        actualTrainingDays: _int(json['actual_training_days']),
        days: _records(json['days']).map(WeeklyTrainingDay.fromJson).toList(),
        totalIncludedSessions: _int(json['total_included_sessions']),
        trainingTypes: _records(json['training_types']).map(TrainingTypeCount.fromJson).toList(),
        includedSessions: _records(json['included_sessions']).map(IncludedTrainingSession.fromJson).toList(),
        weight: weight,
        restingHeartRate: heart,
        sleep: sleep,
        activeCorrectionIds: (json['active_correction_ids'] as Map?)?.map(
              (key, entry) => MapEntry(key.toString(), entry.toString()),
            ) ??
            const {},
      );
    } catch (_) {
      return null;
    }
  }
}

class WeeklyTrainingDay {
  final DateTime date;
  final String weekday;
  final String state;
  final bool planned;
  final bool due;
  final bool completed;
  final bool extraWorkout;
  final bool memberEntered;

  const WeeklyTrainingDay({
    required this.date,
    required this.weekday,
    required this.state,
    required this.planned,
    required this.due,
    required this.completed,
    required this.extraWorkout,
    required this.memberEntered,
  });

  factory WeeklyTrainingDay.fromJson(Map<String, dynamic> json) => WeeklyTrainingDay(
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        weekday: json['weekday']?.toString() ?? '',
        state: json['state']?.toString() ?? 'rest',
        planned: json['planned'] == true,
        due: json['due'] == true,
        completed: json['completed'] == true,
        extraWorkout: json['extra_workout'] == true,
        memberEntered: json['member_entered'] == true,
      );
}

class TrainingTypeCount {
  final String type;
  final int count;

  const TrainingTypeCount({required this.type, required this.count});

  factory TrainingTypeCount.fromJson(Map<String, dynamic> json) => TrainingTypeCount(
        type: json['training_type']?.toString() ?? 'other',
        count: _int(json['count']),
      );
}

class IncludedTrainingSession {
  final String? id;
  final DateTime date;
  final String type;
  final int? durationMinutes;
  final bool memberEntered;
  final String? correctionId;

  const IncludedTrainingSession({
    required this.id,
    required this.date,
    required this.type,
    required this.durationMinutes,
    required this.memberEntered,
    required this.correctionId,
  });

  factory IncludedTrainingSession.fromJson(Map<String, dynamic> json) => IncludedTrainingSession(
        id: json['id']?.toString(),
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        type: json['training_type']?.toString() ?? 'other',
        durationMinutes: json['duration_minutes'] is num ? (json['duration_minutes'] as num).toInt() : null,
        memberEntered: json['member_entered'] == true,
        correctionId: json['correction_id']?.toString(),
      );
}

class WeeklyMetric {
  final String metric;
  final double? value;
  final String unit;
  final double? delta;
  final int sampleCount;
  final int comparisonSampleCount;
  final String displayBasis;
  final List<WeeklyMetricPoint> sparkline;
  final String? activeCorrectionId;

  const WeeklyMetric({
    required this.metric,
    required this.value,
    required this.unit,
    required this.delta,
    required this.sampleCount,
    required this.comparisonSampleCount,
    required this.displayBasis,
    required this.sparkline,
    required this.activeCorrectionId,
  });

  static WeeklyMetric? tryParse(Object? value) {
    if (value is! Map) return null;
    final json = Map<String, dynamic>.from(value);
    final metric = json['metric']?.toString();
    if (metric == null || metric.isEmpty) return null;
    return WeeklyMetric(
      metric: metric,
      value: _doubleOrNull(json['value']),
      unit: json['unit']?.toString() ?? '',
      delta: _doubleOrNull(json['delta']),
      sampleCount: _int(json['sample_count']),
      comparisonSampleCount: _int(json['comparison_sample_count']),
      displayBasis: json['display_basis']?.toString() ?? '',
      sparkline: _records(json['sparkline']).map(WeeklyMetricPoint.fromJson).toList(),
      activeCorrectionId: json['active_correction_id']?.toString(),
    );
  }
}

class WeeklyMetricPoint {
  final DateTime date;
  final double value;
  final bool memberEntered;
  final String? correctionId;

  const WeeklyMetricPoint({
    required this.date,
    required this.value,
    required this.memberEntered,
    required this.correctionId,
  });

  factory WeeklyMetricPoint.fromJson(Map<String, dynamic> json) => WeeklyMetricPoint(
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        value: _doubleOrNull(json['value']) ?? 0,
        memberEntered: json['source']?.toString() == 'member_entered',
        correctionId: json['correction_id']?.toString(),
      );
}

List<Map<String, dynamic>> _records(Object? value) => (value as List? ?? const [])
    .whereType<Map>()
    .map((item) => Map<String, dynamic>.from(item))
    .toList();

int _int(Object? value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
double? _doubleOrNull(Object? value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

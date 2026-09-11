class CareProgramAction {
  const CareProgramAction({
    required this.key,
    required this.title,
    required this.type,
    required this.recurrence,
    required this.weekdays,
    this.trackerRoute,
  });

  final String key;
  final String title;
  final String type;
  final String recurrence;
  final List<int> weekdays;
  final String? trackerRoute;

  factory CareProgramAction.fromJson(Map<String, dynamic> json) =>
      CareProgramAction(
        key: json['key'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        recurrence: (json['recurrence'] as String?) ?? 'daily',
        weekdays: ((json['weekdays'] as List?) ?? const [])
            .map((value) => value as int)
            .toList(),
        trackerRoute: json['tracker_route'] as String?,
      );
}

class CareGuidance {
  const CareGuidance({
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.publishedAt,
  });

  final String text;
  final String authorId;
  final String authorName;
  final DateTime publishedAt;

  factory CareGuidance.fromJson(Map<String, dynamic> json) => CareGuidance(
    text: json['text'] as String,
    authorId: json['author_id'] as String,
    authorName: (json['author_name'] as String?) ?? 'Care team professional',
    publishedAt: DateTime.parse(json['published_at'] as String),
  );
}

class CareProgram {
  const CareProgram({
    required this.id,
    required this.title,
    required this.status,
    required this.revision,
    required this.summary,
    required this.objectives,
    required this.actions,
    required this.guidance,
    required this.reviewDue,
    this.physicianName,
    this.dietitianName,
    this.startsOn,
    this.reviewOn,
    this.endsOn,
    this.completedAt,
    this.completionSummary,
  });

  final String id;
  final String title;
  final String status;
  final int revision;
  final String summary;
  final List<String> objectives;
  final List<CareProgramAction> actions;
  final List<CareGuidance> guidance;
  final bool reviewDue;
  final String? physicianName;
  final String? dietitianName;
  final DateTime? startsOn;
  final DateTime? reviewOn;
  final DateTime? endsOn;
  final DateTime? completedAt;
  final String? completionSummary;

  factory CareProgram.fromJson(Map<String, dynamic> json) => CareProgram(
    id: json['id'] as String,
    title: (json['title'] as String?) ?? 'Care program',
    status: json['status'] as String,
    revision: (json['revision'] as int?) ?? 1,
    summary: (json['member_summary'] as String?) ?? '',
    objectives: ((json['objectives'] as List?) ?? const [])
        .map((value) => value.toString())
        .toList(),
    actions: ((json['actions'] as List?) ?? const [])
        .map(
          (value) => CareProgramAction.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        )
        .toList(),
    guidance: ((json['guidance'] as List?) ?? const [])
        .map(
          (value) =>
              CareGuidance.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(),
    reviewDue: (json['review_due'] as bool?) ?? false,
    physicianName: json['physician_name'] as String?,
    dietitianName: json['dietitian_name'] as String?,
    startsOn: _date(json['starts_on']),
    reviewOn: _date(json['review_on']),
    endsOn: _date(json['ends_on']),
    completedAt: _date(json['terminal_at']),
    completionSummary: json['completion_summary'] as String?,
  );

  static DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}

class CareProgramSummary {
  const CareProgramSummary({
    required this.reviewRequested,
    required this.history,
    required this.expectedActions,
    required this.completedActions,
    required this.measurementChanges,
    this.current,
    this.offer,
  });

  final CareProgram? current;
  final CareProgram? offer;
  final bool reviewRequested;
  final List<CareProgram> history;
  final int expectedActions;
  final int completedActions;
  final List<CareMetricChange> measurementChanges;

  factory CareProgramSummary.fromJson(
    Map<String, dynamic> json,
  ) => CareProgramSummary(
    current: json['current'] is Map
        ? CareProgram.fromJson(
            Map<String, dynamic>.from(json['current'] as Map),
          )
        : null,
    offer: json['offer'] is Map
        ? CareProgram.fromJson(Map<String, dynamic>.from(json['offer'] as Map))
        : null,
    reviewRequested: (json['review_requested'] as bool?) ?? false,
    history: ((json['history'] as List?) ?? const [])
        .map(
          (value) =>
              CareProgram.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(),
    expectedActions:
        ((json['progress'] as Map?)?['expected_actions'] as int?) ?? 0,
    completedActions:
        ((json['progress'] as Map?)?['completed_actions'] as int?) ?? 0,
    measurementChanges:
        ((((json['progress'] as Map?)?['measurement_changes'] as Map?)?['items']
                    as List?) ??
                const [])
            .map(
              (value) => CareMetricChange.fromJson(
                Map<String, dynamic>.from(value as Map),
              ),
            )
            .toList(),
  );
}

class CareMetricChange {
  const CareMetricChange({
    required this.label,
    required this.unit,
    required this.first,
    required this.latest,
    required this.change,
  });

  final String label;
  final String unit;
  final double first;
  final double latest;
  final double change;

  factory CareMetricChange.fromJson(Map<String, dynamic> json) =>
      CareMetricChange(
        label: json['label'] as String,
        unit: json['unit'] as String,
        first: (json['first'] as num).toDouble(),
        latest: (json['latest'] as num).toDouble(),
        change: (json['change'] as num).toDouble(),
      );
}

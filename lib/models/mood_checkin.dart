class MoodCheckin {
  const MoodCheckin({
    required this.id,
    required this.moodScore,
    required this.stressScore,
    required this.anonymous,
    required this.checkedAt,
  });

  final String id;
  final int moodScore;
  final int stressScore;
  final bool anonymous;
  final DateTime checkedAt;

  factory MoodCheckin.fromJson(Map<String, dynamic> json) {
    return MoodCheckin(
      id: json['id'].toString(),
      moodScore: (json['mood_score'] as num).toInt(),
      stressScore: (json['stress_score'] as num).toInt(),
      anonymous: json['anonymous'] as bool? ?? true,
      checkedAt: DateTime.parse(json['checked_at'].toString()),
    );
  }
}

/// Meal Tracker lists today's logs in the member's local calendar day.
///
/// The API stores `logged_at` in UTC. Comparing that string's date prefix
/// to `DateTime.now()` drops meals after local midnight while the daily
/// totals (which use the member's timezone offset) still count them.
class NutritionLogDay {
  static DateTime? parseLocal(Object? loggedAt) {
    if (loggedAt is DateTime) {
      return loggedAt.isUtc ? loggedAt.toLocal() : loggedAt;
    }
    if (loggedAt == null) return null;
    return DateTime.tryParse(loggedAt.toString())?.toLocal();
  }

  static bool isOnLocalDate(Object? loggedAt, DateTime localNow) {
    final local = parseLocal(loggedAt);
    if (local == null) return false;
    return local.year == localNow.year &&
        local.month == localNow.month &&
        local.day == localNow.day;
  }

  static List<Map<String, dynamic>> todaysLogs(
    Iterable<Map<String, dynamic>> logs, {
    DateTime? now,
  }) {
    final localNow = now ?? DateTime.now();
    return [
      for (final log in logs)
        if (isOnLocalDate(log['logged_at'], localNow)) log,
    ];
  }
}

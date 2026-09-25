import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/nutrition_log_day.dart';

void main() {
  test('keeps a UTC meal on the local calendar day after midnight', () {
    const loggedAt = '2026-09-18T19:55:13.812876+00:00';
    final local = DateTime.parse(loggedAt).toLocal();

    expect(NutritionLogDay.isOnLocalDate(loggedAt, local), isTrue);
    expect(
      NutritionLogDay.isOnLocalDate(
        loggedAt,
        local.subtract(const Duration(days: 1)),
      ),
      isFalse,
    );
    expect(loggedAt.startsWith('2026-09-18'), isTrue);
  });

  test('lists only meals from the current local day', () {
    final now = DateTime.parse('2026-09-18T19:55:13.812876+00:00').toLocal();
    final logs = [
      {'food': 'banana', 'logged_at': '2026-09-18T19:55:13.812876+00:00'},
      {
        'food': 'yesterday dal',
        'logged_at': '2026-09-17T10:00:00.000000+00:00',
      },
    ];

    expect(
      NutritionLogDay.todaysLogs(logs, now: now).map((log) => log['food']),
      ['banana'],
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/demo_health_metrics.dart';

void main() {
  test('firstPositive skips zeros and nulls', () {
    expect(DemoHealthMetrics.firstPositive([null, 0, 72]), 72);
    expect(DemoHealthMetrics.firstPositive([0.0, null]), isNull);
  });

  test('empty or zero graph series are treated as missing', () {
    expect(DemoHealthMetrics.seriesIsEmpty(const []), isTrue);
    expect(
      DemoHealthMetrics.seriesIsEmpty(const [
        {'label': '2026-09-01', 'value': 0},
        {'label': '2026-09-02', 'value': 0.0},
      ]),
      isTrue,
    );
    expect(
      DemoHealthMetrics.seriesIsEmpty(const [
        {'label': '2026-09-01', 'value': 7.5},
      ]),
      isFalse,
    );
  });

  test('weekly bucket label uses the Monday of the current week', () {
    expect(
      DemoHealthMetrics.periodBucketLabel(DateTime(2026, 9, 9), 'weeks'),
      '2026-09-07',
    );
    expect(
      DemoHealthMetrics.periodBucketLabel(DateTime(2026, 9, 7), 'days'),
      '2026-09-07',
    );
    expect(
      DemoHealthMetrics.periodBucketLabel(DateTime(2026, 9, 9), 'month'),
      '2026-09-01',
    );
  });

  test('water dummy series uses millilitre values', () {
    final water = DemoHealthMetrics.graphPayload(
      metric: 'water',
      period: 'days',
    );
    expect(water['data'], hasLength(7));
    expect(water['average'], greaterThan(1000));
    expect(DemoHealthMetrics.covers('water'), isTrue);
  });

  test('sleep and heart-rate dummy series fill the selected period', () {
    final now = DateTime(2026, 9, 7);
    final sleep = DemoHealthMetrics.graphPayload(
      metric: 'sleep',
      period: 'days',
    );
    final heart = DemoHealthMetrics.graphSeries(
      metric: 'heart_rate',
      period: 'weeks',
      now: now,
    );

    expect(sleep['data'], hasLength(7));
    expect(sleep['average'], greaterThan(0));
    expect(heart, hasLength(8));
    expect(heart.first['label'], '2026-07-20');
    expect(heart.last['label'], '2026-09-07');
    expect(heart.last['value'], 74.0);
  });
}

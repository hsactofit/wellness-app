/// Placeholder readings used when Health Connect and the dashboard API have
/// no sample yet. Live values always win.
class DemoHealthMetrics {
  static const heartRateBpm = 72.0;
  static const restingHeartRateBpm = 64.0;
  static const heartRateStatus = 'normal';
  static const sleepHours = 7.5;
  static const sleepStatus = 'on track';
  static const waterMl = 1900.0;

  static const _sleepBases = [7.2, 6.8, 7.5, 8.1, 7.4, 7.8, 7.5];
  static const _heartRateBases = [74.0, 70.0, 68.0, 72.0, 71.0, 69.0, 72.0];
  static const _waterBases = [
    1800.0,
    2100.0,
    1950.0,
    2300.0,
    1700.0,
    2050.0,
    1900.0,
  ];

  static bool covers(String metric) =>
      metric == 'heart_rate' || metric == 'sleep' || metric == 'water';

  static double? firstPositive(Iterable<double?> values) {
    for (final value in values) {
      if (value != null && value > 0) return value;
    }
    return null;
  }

  static bool seriesIsEmpty(List<dynamic> data) {
    if (data.isEmpty) return true;
    return data.every((item) {
      if (item is! Map) return true;
      final value = item['value'];
      if (value is! num) return true;
      return value <= 0;
    });
  }

  static String isoDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String periodBucketLabel(DateTime day, String period) {
    final local = DateTime(day.year, day.month, day.day);
    if (period == 'weeks') {
      return isoDate(local.subtract(Duration(days: local.weekday - 1)));
    }
    if (period == 'month') {
      return isoDate(DateTime(local.year, local.month, 1));
    }
    return isoDate(local);
  }

  static Map<String, dynamic> graphPayload({
    required String metric,
    required String period,
  }) {
    final points = graphSeries(metric: metric, period: period);
    final values = points.map((point) => (point['value'] as num).toDouble());
    final sum = values.fold<double>(0, (total, value) => total + value);
    return {
      'data': points,
      'average': double.parse((sum / points.length).toStringAsFixed(1)),
      'total': double.parse(sum.toStringAsFixed(1)),
    };
  }

  static List<Map<String, dynamic>> graphSeries({
    required String metric,
    required String period,
    DateTime? now,
  }) {
    final asOf = now ?? DateTime.now();
    final count = period == 'month'
        ? 30
        : period == 'weeks'
        ? 8
        : 7;
    final step = period == 'weeks'
        ? const Duration(days: 7)
        : const Duration(days: 1);
    final bases = _basesFor(metric);

    return List.generate(count, (index) {
      final date = asOf.subtract(step * (count - 1 - index));
      return {'label': isoDate(date), 'value': bases[index % bases.length]};
    });
  }

  static List<double> _basesFor(String metric) {
    switch (metric) {
      case 'sleep':
        return _sleepBases;
      case 'water':
        return _waterBases;
      default:
        return _heartRateBases;
    }
  }
}

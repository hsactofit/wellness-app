import '../models/body_composition_report.dart';

/// Shared, non-clinical language for a body-composition comparison.
///
/// A positive or negative measurement is not inherently good or bad, so this
/// deliberately describes the observable change without assigning a health
/// judgment. Keeping it here makes the in-app view and downloadable PDF say
/// the same thing.
class BodyCompositionComparisonPresentation {
  const BodyCompositionComparisonPresentation._();

  static bool isComparable(BodyCompositionComparisonMetric metric) =>
      metric.olderValue != null && metric.newerValue != null;

  static bool isChanged(BodyCompositionComparisonMetric metric) =>
      isComparable(metric) && (metric.absoluteChange ?? 0) != 0;

  static int comparableCount(BodyCompositionComparison comparison) =>
      comparison.metrics.where(isComparable).length;

  static int changedCount(BodyCompositionComparison comparison) =>
      comparison.metrics.where(isChanged).length;

  static int unchangedCount(BodyCompositionComparison comparison) => comparison
      .metrics
      .where((metric) => isComparable(metric) && !isChanged(metric))
      .length;

  static int recordedOnceCount(BodyCompositionComparison comparison) =>
      comparison.metrics.where((metric) => !isComparable(metric)).length;

  static String formatNumber(double? value, {int decimalPlaces = 1}) {
    if (value == null) return '—';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(decimalPlaces);
  }

  static String formatValue(double? value, String unit) {
    final number = formatNumber(value);
    return number == '—' || unit.trim().isEmpty ? number : '$number $unit';
  }

  static String availabilityLabel(BodyCompositionComparisonMetric metric) {
    if (metric.olderValue == null && metric.newerValue != null) {
      return 'Recorded only in the latest report';
    }
    if (metric.newerValue == null && metric.olderValue != null) {
      return 'Recorded only in the earlier report';
    }
    return 'Not recorded in either report';
  }

  static String directionWord(BodyCompositionComparisonMetric metric) {
    final change = metric.absoluteChange;
    if (change == null || change == 0) return 'unchanged';
    return change > 0 ? 'higher' : 'lower';
  }

  static String changeDescription(BodyCompositionComparisonMetric metric) {
    if (!isComparable(metric)) return availabilityLabel(metric);
    final change = metric.absoluteChange ?? 0;
    if (change == 0) return 'No change from the earlier report';
    return '${formatValue(change.abs(), metric.unit)} ${directionWord(metric)} than earlier';
  }

  static String? relativeChangeDescription(
    BodyCompositionComparisonMetric metric,
  ) {
    if (!isComparable(metric) || metric.percentageChange == null) return null;
    final percentage = metric.percentageChange!;
    if (percentage == 0) return '0% relative change';
    return '${formatNumber(percentage.abs())}% ${percentage > 0 ? 'higher' : 'lower'} than earlier';
  }

  static String changeForTable(BodyCompositionComparisonMetric metric) {
    if (!isComparable(metric)) return availabilityLabel(metric);
    final relative = relativeChangeDescription(metric);
    return relative == null
        ? changeDescription(metric)
        : '${changeDescription(metric)}\n$relative';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/gender.dart';

void main() {
  test('converts the onboarding gender labels to API values', () {
    expect(genderApiValue('Male'), 'M');
    expect(genderApiValue('Female'), 'F');
    expect(genderApiValue('Non-binary'), 'Non-binary');
    expect(genderApiValue('Other'), 'Other');
  });

  test('preserves an absent or unknown value for normal validation', () {
    expect(genderApiValue(null), isNull);
    expect(genderApiValue('Unknown'), 'Unknown');
  });
}

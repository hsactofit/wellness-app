/// Converts the gender wording shown in the member app to the value accepted
/// by the enrolment API. The UI deliberately uses full words, while the
/// server stores the concise `M` and `F` enum values.
String? genderApiValue(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'm':
    case 'male':
      return 'M';
    case 'f':
    case 'female':
      return 'F';
    case 'non-binary':
    case 'non binary':
      return 'Non-binary';
    case 'other':
      return 'Other';
    default:
      return value;
  }
}

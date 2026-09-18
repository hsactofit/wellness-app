import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/models/care_program.dart';
import 'package:wellnessconnect/services/care_program_tracker_destination.dart';

void main() {
  CareProgramAction action(String type, {String? route}) => CareProgramAction(
    key: type,
    title: type,
    type: type,
    recurrence: 'daily',
    weekdays: const [],
    trackerRoute: route,
  );

  test('opens every tracker action in its matching member workflow', () {
    expect(
      careProgramTrackerDestination(action('measurement')),
      CareProgramTrackerDestination.vitals,
    );
    expect(
      careProgramTrackerDestination(action('activity')),
      CareProgramTrackerDestination.activity,
    );
    expect(
      careProgramTrackerDestination(action('hydration')),
      CareProgramTrackerDestination.hydration,
    );
    expect(
      careProgramTrackerDestination(action('meal')),
      CareProgramTrackerDestination.meal,
    );
  });

  test('honours an explicit tracker route before the action type', () {
    expect(
      careProgramTrackerDestination(action('activity', route: '/water')),
      CareProgramTrackerDestination.hydration,
    );
    expect(
      careProgramTrackerDestination(action('measurement', route: '/steps')),
      CareProgramTrackerDestination.activity,
    );
  });

  test('does not send non-tracker actions to an unrelated screen', () {
    expect(careProgramTrackerDestination(action('checklist')), isNull);
    expect(careProgramTrackerDestination(action('guidance')), isNull);
  });
}

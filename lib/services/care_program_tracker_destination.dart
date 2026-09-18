import '../models/care_program.dart';

enum CareProgramTrackerDestination { hydration, meal, bloodPressure, activity }

CareProgramTrackerDestination? careProgramTrackerDestination(
  CareProgramAction action,
) {
  switch (action.trackerRoute?.trim().toLowerCase()) {
    case '/water':
    case '/hydration':
      return CareProgramTrackerDestination.hydration;
    case '/nutrition':
    case '/meals':
      return CareProgramTrackerDestination.meal;
    case '/health/blood-pressure':
    case '/blood-pressure':
      return CareProgramTrackerDestination.bloodPressure;
    case '/activity':
    case '/steps':
    case '/progress/steps':
      return CareProgramTrackerDestination.activity;
  }

  switch (action.type) {
    case 'hydration':
      return CareProgramTrackerDestination.hydration;
    case 'meal':
      return CareProgramTrackerDestination.meal;
    case 'activity':
      return CareProgramTrackerDestination.activity;
    default:
      final measurementName = '${action.key} ${action.title}'.toLowerCase();
      if (action.type == 'measurement' &&
          (measurementName.contains('blood pressure') ||
              measurementName.contains('morning-bp'))) {
        return CareProgramTrackerDestination.bloodPressure;
      }
      return null;
  }
}

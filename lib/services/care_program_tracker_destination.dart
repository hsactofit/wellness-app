import '../models/care_program.dart';

enum CareProgramTrackerDestination { hydration, meal, vitals, activity }

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
    case '/face-scan':
    case '/vitals':
      return CareProgramTrackerDestination.vitals;
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
    case 'measurement':
      return CareProgramTrackerDestination.vitals;
    case 'activity':
      return CareProgramTrackerDestination.activity;
    default:
      return null;
  }
}

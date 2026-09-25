import 'health_service.dart';

/// Shared Home health-connect policy for Medifit and Mednovations.
///
/// Logout clears local flags, but Apple Health / Health Connect keep the
/// previous decision. After sign-in, Home should reconnect in-app the same
/// way Medifit always did, instead of asking to Connect/Grant and bouncing
/// into the Health app.
class HealthConnectRestore {
  /// Login's user payload does not include member permissions. Reconnect
  /// from the saved profile flag when local state was cleared.
  static bool shouldRestoreFromProfile({
    required bool profileConnected,
    required bool localSyncEnabled,
  }) {
    return profileConnected && !localSyncEnabled;
  }

  /// iOS already has a HealthKit answer, so Home can reconnect without
  /// showing Connect/Grant.
  static bool shouldRestoreFromIosAuthorization({
    required bool isIos,
    required bool localSyncEnabled,
    required HealthAuthorizationRequestStatus authorizationStatus,
  }) {
    return isIos &&
        !localSyncEnabled &&
        authorizationStatus == HealthAuthorizationRequestStatus.unnecessary;
  }

  /// Connect/Grant stay in-app when iOS will not show the permission sheet.
  /// Opening the Health app is reserved for the explicit Manage Access
  /// control.
  static bool shouldFinishConnectWithoutOsPrompt({
    required bool isIos,
    required HealthAuthorizationRequestStatus authorizationStatus,
  }) {
    return isIos &&
        authorizationStatus == HealthAuthorizationRequestStatus.unnecessary;
  }
}

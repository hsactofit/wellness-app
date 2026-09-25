import 'package:flutter_test/flutter_test.dart';
import 'package:wellnessconnect/services/health_connect_restore.dart';
import 'package:wellnessconnect/services/health_service.dart';

void main() {
  test('restores a previously saved profile connection after logout', () {
    expect(
      HealthConnectRestore.shouldRestoreFromProfile(
        profileConnected: true,
        localSyncEnabled: false,
      ),
      isTrue,
    );
    expect(
      HealthConnectRestore.shouldRestoreFromProfile(
        profileConnected: true,
        localSyncEnabled: true,
      ),
      isFalse,
    );
    expect(
      HealthConnectRestore.shouldRestoreFromProfile(
        profileConnected: false,
        localSyncEnabled: false,
      ),
      isFalse,
    );
  });

  test('reconnects on iOS when HealthKit already has an answer', () {
    expect(
      HealthConnectRestore.shouldRestoreFromIosAuthorization(
        isIos: true,
        localSyncEnabled: false,
        authorizationStatus: HealthAuthorizationRequestStatus.unnecessary,
      ),
      isTrue,
    );
    expect(
      HealthConnectRestore.shouldRestoreFromIosAuthorization(
        isIos: true,
        localSyncEnabled: false,
        authorizationStatus: HealthAuthorizationRequestStatus.shouldRequest,
      ),
      isFalse,
    );
    expect(
      HealthConnectRestore.shouldRestoreFromIosAuthorization(
        isIos: false,
        localSyncEnabled: false,
        authorizationStatus: HealthAuthorizationRequestStatus.unnecessary,
      ),
      isFalse,
    );
  });

  test('Connect finishes in-app instead of opening Apple Health', () {
    expect(
      HealthConnectRestore.shouldFinishConnectWithoutOsPrompt(
        isIos: true,
        authorizationStatus: HealthAuthorizationRequestStatus.unnecessary,
      ),
      isTrue,
    );
    expect(
      HealthConnectRestore.shouldFinishConnectWithoutOsPrompt(
        isIos: true,
        authorizationStatus: HealthAuthorizationRequestStatus.shouldRequest,
      ),
      isFalse,
    );
    expect(
      HealthConnectRestore.shouldFinishConnectWithoutOsPrompt(
        isIos: false,
        authorizationStatus: HealthAuthorizationRequestStatus.unnecessary,
      ),
      isFalse,
    );
  });
}

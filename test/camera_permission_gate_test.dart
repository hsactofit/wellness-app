import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wellnessconnect/services/camera_permission_gate.dart';

void main() {
  test('does not request camera access again after it is granted', () async {
    var requestCalls = 0;
    final gate = CameraPermissionGate(
      status: () async => PermissionStatus.granted,
      request: () async {
        requestCalls++;
        return PermissionStatus.granted;
      },
    );

    expect(await gate.requestForQrScanner(), isTrue);
    expect(requestCalls, 0);
  });

  test('requests camera access when it has not been decided yet', () async {
    var requestCalls = 0;
    final gate = CameraPermissionGate(
      status: () async => PermissionStatus.denied,
      request: () async {
        requestCalls++;
        return PermissionStatus.granted;
      },
    );

    expect(await gate.requestForQrScanner(), isTrue);
    expect(requestCalls, 1);
  });

  test('preserves a denial so the screen can show its warning', () async {
    final gate = CameraPermissionGate(
      status: () async => PermissionStatus.denied,
      request: () async => PermissionStatus.denied,
    );

    expect(await gate.requestForQrScanner(), isFalse);
  });
}

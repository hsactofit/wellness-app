import 'package:permission_handler/permission_handler.dart';

typedef CameraPermissionStatusReader = Future<PermissionStatus> Function();
typedef CameraPermissionRequester = Future<PermissionStatus> Function();

/// Requests camera access only when the operating system has not already
/// granted it. The OS owns the one-time permission prompt and preserves its
/// decision for future facility QR scans.
class CameraPermissionGate {
  CameraPermissionGate({
    CameraPermissionStatusReader? status,
    CameraPermissionRequester? request,
  }) : _status = status ?? _platformStatus,
       _request = request ?? _platformRequest;

  final CameraPermissionStatusReader _status;
  final CameraPermissionRequester _request;

  Future<bool> requestForQrScanner() async {
    final status = await _status();
    if (status.isGranted) return true;
    return (await _request()).isGranted;
  }

  static Future<PermissionStatus> _platformStatus() => Permission.camera.status;

  static Future<PermissionStatus> _platformRequest() =>
      Permission.camera.request();
}

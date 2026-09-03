import 'package:permission_handler/permission_handler.dart';

typedef CameraPermissionStatusReader = Future<PermissionStatus> Function();
typedef CameraPermissionRequester = Future<PermissionStatus> Function();
typedef CameraSettingsOpener = Future<bool> Function();

enum CameraPermissionResult { granted, denied, permanentlyDenied }

/// Requests camera access only when the operating system has not already
/// granted it. The OS owns the one-time permission prompt and preserves its
/// decision for gym QR scans and Update Your Health captures.
class CameraPermissionGate {
  CameraPermissionGate({
    CameraPermissionStatusReader? status,
    CameraPermissionRequester? request,
    CameraSettingsOpener? openSettings,
  }) : _status = status ?? _platformStatus,
       _request = request ?? _platformRequest,
       _openSettings = openSettings ?? openAppSettings;

  final CameraPermissionStatusReader _status;
  final CameraPermissionRequester _request;
  final CameraSettingsOpener _openSettings;

  Future<CameraPermissionResult> ensure({bool requestIfNeeded = true}) async {
    final status = await _status();
    if (status.isGranted) return CameraPermissionResult.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return CameraPermissionResult.permanentlyDenied;
    }
    if (!requestIfNeeded) return CameraPermissionResult.denied;
    final requested = await _request();
    if (requested.isGranted) return CameraPermissionResult.granted;
    if (requested.isPermanentlyDenied || requested.isRestricted) {
      return CameraPermissionResult.permanentlyDenied;
    }
    return CameraPermissionResult.denied;
  }

  Future<bool> requestForQrScanner() async {
    return (await ensure()) == CameraPermissionResult.granted;
  }

  Future<bool> openSettings() => _openSettings();

  static Future<PermissionStatus> _platformStatus() => Permission.camera.status;

  static Future<PermissionStatus> _platformRequest() =>
      Permission.camera.request();
}

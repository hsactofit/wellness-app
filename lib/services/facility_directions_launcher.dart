import 'package:url_launcher/url_launcher.dart';

typedef DirectionsUriLauncher =
    Future<bool> Function(Uri uri, {required LaunchMode mode});

enum DirectionsLaunchResult {
  openedExternally,
  openedInAppBrowser,
  unavailable,
}

/// Opens the server-provided Google Maps directions URL without making a
/// facility booking depend on an installed maps application. The external
/// handoff preserves Google Maps' universal-link behaviour; an in-app browser
/// remains a reliable route fallback when the operating system declines it.
class FacilityDirectionsLauncher {
  const FacilityDirectionsLauncher({required DirectionsUriLauncher launch})
    : _launch = launch;

  final DirectionsUriLauncher _launch;

  Future<DirectionsLaunchResult> open(String? rawUrl) async {
    final uri = _validDirectionsUri(rawUrl);
    if (uri == null) return DirectionsLaunchResult.unavailable;

    if (await _tryLaunch(uri, LaunchMode.externalApplication)) {
      return DirectionsLaunchResult.openedExternally;
    }
    if (await _tryLaunch(uri, LaunchMode.inAppBrowserView)) {
      return DirectionsLaunchResult.openedInAppBrowser;
    }
    return DirectionsLaunchResult.unavailable;
  }

  Uri? _validDirectionsUri(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }

  Future<bool> _tryLaunch(Uri uri, LaunchMode mode) async {
    try {
      return await _launch(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }
}

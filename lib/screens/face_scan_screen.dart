import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../app_brand.dart';
import '../config/face_scan_web_config.dart';
import '../l10n/app_text.dart';
import '../services/api_service.dart';
import '../services/camera_permission_gate.dart';
import 'face_scan_reports_screen.dart';

/// Only the browser captures the video. App credentials never enter web content.
class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen>
    with WidgetsBindingObserver {
  final _submissionId = const Uuid().v4();
  WebViewController? _controller;
  String? _sessionId;
  String? _error;
  String _stage = 'loading';
  bool _loading = true;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  Future<bool> _consent() async {
    final consent = await ApiService.instance.fetchFaceScanConsent();
    if (consent.processingGranted) return true;
    if (!mounted) return false;
    var accepted = false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const AppText('Face Scan consent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                'Mednovations will temporarily process a 30-second face video to estimate core vitals. Your confirmed details and report are saved to Mednovations. The temporary video is deleted after processing.',
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: accepted,
                onChanged: (value) => update(() => accepted = value ?? false),
                title: const AppText(
                  'I consent to temporary video processing for Face Scan.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const AppText('Cancel'),
            ),
            FilledButton(
              onPressed: accepted ? () => Navigator.pop(ctx, true) : null,
              child: const AppText('Continue'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return false;
    await ApiService.instance.updateFaceScanConsent('processing', true);
    return true;
  }

  Future<void> _open() async {
    if (!AppBrand.faceScanEnabled) {
      setState(() {
        _loading = false;
        _error = 'Face Scan is not enabled for this app.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!await _consent()) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final launch = await ApiService.instance.createFaceScanWebSession(
        _submissionId,
      );
      _sessionId = launch['id'] as String;
      if (!mounted) {
        await ApiService.instance.revokeFaceScanWebSession(_sessionId!);
        return;
      }
      final uri = Uri.parse(launch['launch_url'] as String);
      if (!FaceScanWebConfig.allows(uri)) {
        throw StateError(
          'The scanner address does not match this app configuration.',
        );
      }
      final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }
      final controller = WebViewController.fromPlatformCreationParams(
        params,
        onPermissionRequest: (request) async {
          final current = await _controller?.currentUrl();
          final trusted =
              current != null && FaceScanWebConfig.allows(Uri.parse(current));
          if (!trusted ||
              request.types.isEmpty ||
              request.types.any(
                (type) => type != WebViewPermissionResourceType.camera,
              )) {
            await request.deny();
            return;
          }
          final result = await CameraPermissionGate().ensure();
          if (mounted &&
              !_closing &&
              result == CameraPermissionResult.granted) {
            await request.grant();
          } else {
            await request.deny();
          }
        },
      );
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              FaceScanWebConfig.allows(Uri.parse(request.url))
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted && !_closing) {
              setState(() {
                _loading = false;
                _error =
                    'The secure scanner could not load. Check your connection and, for the local demo, the device certificate trust.';
              });
            }
          },
          // Certificate errors retain the system's default rejection behavior.
        ),
      );
      await controller.addJavaScriptChannel(
        'MednovationsScanner',
        onMessageReceived: (message) async {
          if (!mounted || _closing) return;
          final current = await controller.currentUrl();
          if (current == null ||
              !FaceScanWebConfig.allows(Uri.parse(current))) {
            return;
          }
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            if (data['version'] != 1) return;
            if (data['type'] == 'state' && data['stage'] is String) {
              _stage = data['stage'] as String;
            }
            if (data['type'] == 'close') await _close();
            // Saved messages are hints only; reports are fetched from the authenticated API.
          } on FormatException {
            // Unrecognized browser messages have no effect on app data.
          } on TypeError {
            // Reject messages that do not follow the integration contract.
          }
        },
      );
      _controller = controller;
      await controller.clearLocalStorage();
      await controller.loadRequest(uri);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _clearBrowser() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.runJavaScript(
        "window.dispatchEvent(new Event('mednovations-close')); window.dispatchEvent(new Event('pagehide')); sessionStorage.clear();",
      );
      await controller.clearLocalStorage();
      await controller.clearCache();
    } catch (_) {
      // The page may already be closed; the server capability is also revoked.
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    if (const {'recording', 'uploading'}.contains(_stage)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const AppText('Leave Face Scan?'),
          content: const AppText(
            'Recording or upload may be interrupted. Any scan already uploaded will continue processing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const AppText('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const AppText('Leave'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    _closing = true;
    await _clearBrowser();
    final id = _sessionId;
    if (id != null) {
      try {
        await ApiService.instance.revokeFaceScanWebSession(id);
      } catch (_) {
        /* Offline capabilities expire after 30 minutes. */
      }
      _sessionId = null;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const FaceScanReportsScreen()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && !_closing) {
      unawaited(
        ApiService.instance.fetchUserProfile().catchError(
          (_) => <String, dynamic>{},
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_clearBrowser());
    final id = _sessionId;
    if (id != null) {
      unawaited(
        ApiService.instance.revokeFaceScanWebSession(id).catchError((_) {}),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _closing,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) unawaited(_close());
    },
    child: Scaffold(
      appBar: AppBar(
        title: const AppText('Face Scan'),
        leading: IconButton(
          tooltip: 'Close Face Scan',
          icon: const Icon(Icons.close),
          onPressed: _close,
        ),
      ),
      body: Stack(
        children: [
          if (_controller != null && _error == null)
            WebViewWidget(controller: _controller!),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _open,
                      child: const AppText('Try again'),
                    ),
                    TextButton(
                      onPressed: _close,
                      child: const AppText('View reports'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

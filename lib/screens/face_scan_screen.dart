import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_text.dart';
import '../models/face_scan.dart';
import '../services/api_service.dart';
import '../services/camera_permission_gate.dart';
import 'face_scan_reports_screen.dart';

enum _FaceScanState {
  preparing,
  ready,
  recording,
  uploading,
  processing,
  success,
  denied,
  error,
}

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Timer? _recordTimer;
  Timer? _pollTimer;
  _FaceScanState _state = _FaceScanState.preparing;
  int _secondsRemaining = 30;
  String? _error;
  String? _localVideoPath;
  String? _jobId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _state == _FaceScanState.ready) {
      _prepareCamera(requestPermission: false);
      return;
    }
    if (state != AppLifecycleState.resumed &&
        _state == _FaceScanState.recording) {
      _abortRecording();
    }
  }

  Future<void> _prepareCamera({bool requestPermission = true}) async {
    if (!mounted) return;
    setState(() {
      _state = _FaceScanState.preparing;
      _error = null;
    });
    final result = await CameraPermissionGate().ensure(
      requestIfNeeded: requestPermission,
    );
    if (!mounted) return;
    if (result != CameraPermissionResult.granted) {
      setState(() => _state = _FaceScanState.denied);
      return;
    }
    try {
      final cameras = await availableCameras();
      final front = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      if (front.isEmpty) throw StateError('No front camera is available.');
      await _controller?.dispose();
      final controller = CameraController(
        front.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _state = _FaceScanState.ready;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _state = _FaceScanState.error;
      });
    }
  }

  Future<bool> _ensureProcessingConsent() async {
    try {
      final current = await ApiService.instance.fetchFaceScanConsent();
      if (current.processingGranted) return true;
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
      return false;
    }
    if (!mounted) return false;
    var accepted = false;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const AppText('Face Scan consent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                'Mednovations will securely upload a 30-second face video to estimate core vitals. The temporary video is deleted after processing and is not included in your report.',
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: accepted,
                onChanged: (value) =>
                    setDialogState(() => accepted = value ?? false),
                title: const AppText(
                  'I consent to temporary video processing for Face Scan.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const AppText('Cancel'),
            ),
            FilledButton(
              onPressed: accepted
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
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

  Future<void> _startScan() async {
    if (!await _ensureProcessingConsent() || !mounted) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.startVideoRecording();
      if (!mounted) return;
      setState(() {
        _state = _FaceScanState.recording;
        _secondsRemaining = 30;
        _error = null;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 0) _finishRecording();
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _state = _FaceScanState.error;
        });
      }
    }
  }

  Future<void> _finishRecording() async {
    _recordTimer?.cancel();
    final controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) return;
    try {
      final video = await controller.stopVideoRecording();
      _localVideoPath = video.path;
      if (!mounted) return;
      setState(() => _state = _FaceScanState.uploading);
      final job = await ApiService.instance.uploadFaceScan(
        videoPath: video.path,
        clientSubmissionId: const Uuid().v4(),
        capturedAt: DateTime.now(),
      );
      await File(video.path).delete().catchError((_) => File(video.path));
      _localVideoPath = null;
      _jobId = job.id;
      if (!mounted) return;
      setState(() {
        _state = job.status == 'completed'
            ? _FaceScanState.success
            : _FaceScanState.processing;
      });
      if (!job.terminal) _beginPolling(job.id);
      if (job.status == 'failed') _showJobFailure(job);
    } catch (error) {
      await _deleteLocalVideo();
      if (mounted) {
        setState(() {
          _error = error.toString();
          _state = _FaceScanState.error;
        });
      }
    }
  }

  void _beginPolling(String jobId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final job = await ApiService.instance.fetchFaceScanJob(jobId);
        if (!mounted) return;
        if (!job.terminal) return;
        _pollTimer?.cancel();
        if (job.status == 'completed') {
          setState(() => _state = _FaceScanState.success);
        } else {
          _showJobFailure(job);
        }
      } catch (_) {
        // The durable job remains visible in the report library. Keep polling.
      }
    });
  }

  Future<void> _cancelProcessing() async {
    final jobId = _jobId;
    if (jobId == null) return;
    try {
      await ApiService.instance.cancelFaceScanJob(jobId);
      _pollTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _jobId = null;
        _error = 'The Face Scan was cancelled. You can record a new scan.';
        _state = _FaceScanState.error;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: AppText(error.toString())));
    }
  }

  void _showJobFailure(FaceScanJob job) {
    setState(() {
      _error =
          job.errorMessage ??
          'The scan could not be processed. Please try again.';
      _state = _FaceScanState.error;
    });
  }

  Future<void> _abortRecording() async {
    _recordTimer?.cancel();
    final controller = _controller;
    if (controller?.value.isRecordingVideo == true) {
      try {
        final video = await controller!.stopVideoRecording();
        await File(video.path).delete();
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _error = 'The scan was interrupted. Please start again.';
        _state = _FaceScanState.error;
      });
    }
  }

  Future<void> _deleteLocalVideo() async {
    final path = _localVideoPath;
    _localVideoPath = null;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _pollTimer?.cancel();
    _controller?.dispose();
    _deleteLocalVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Face Scan'),
        actions: [
          IconButton(
            tooltip: 'Face Scan Reports'.localized(context),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FaceScanReportsScreen()),
            ),
            icon: const Icon(Icons.folder_copy_outlined),
          ),
        ],
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_state == _FaceScanState.denied) {
      return _message(
        Icons.camera_alt_outlined,
        'Camera permission required',
        'Allow camera access to start Face Scan.',
        action: () async {
          final gate = CameraPermissionGate();
          final result = await gate.ensure();
          if (result == CameraPermissionResult.permanentlyDenied) {
            await gate.openSettings();
          }
          if (mounted) _prepareCamera(requestPermission: false);
        },
      );
    }
    if (_state == _FaceScanState.error) {
      return _message(
        Icons.error_outline,
        'Face Scan could not finish',
        _error ?? 'Please try again in steady, even lighting.',
        action: _prepareCamera,
      );
    }
    if (_state == _FaceScanState.uploading ||
        _state == _FaceScanState.processing ||
        _state == _FaceScanState.preparing) {
      final text = _state == _FaceScanState.uploading
          ? 'Uploading securely…'
          : _state == _FaceScanState.processing
          ? 'Creating your report…'
          : 'Preparing camera…';
      return _message(
        Icons.monitor_heart_outlined,
        text,
        _state == _FaceScanState.processing
            ? 'You can leave this screen. Processing will continue and appear in Face Scan Reports.'
            : 'Please wait.',
        loading: true,
        actionLabel: 'Cancel Scan',
        action: _state == _FaceScanState.processing ? _cancelProcessing : null,
      );
    }
    if (_state == _FaceScanState.success) {
      return _message(
        Icons.check_circle_outline,
        'Face Scan report ready',
        'Your report has been saved.',
        actionLabel: 'View Report',
        action: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FaceScanReportsScreen()),
        ),
      );
    }
    final controller = _controller;
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null) CameraPreview(controller),
              Center(
                child: Container(
                  width: 245,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(130),
                    border: Border.all(
                      color: _state == _FaceScanState.recording
                          ? Colors.greenAccent
                          : Colors.white,
                      width: 4,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: 20,
                child: Card(
                  color: Colors.black.withValues(alpha: .65),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: AppText(
                      'Keep your face inside the guide. Use even lighting and hold still.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (_state == _FaceScanState.recording)
                Center(
                  child: Text(
                    '$_secondsRemaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _state == _FaceScanState.ready ? _startScan : null,
              icon: const Icon(Icons.face_retouching_natural),
              label: const AppText('Start 30-second scan'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _message(
    IconData icon,
    String title,
    String body, {
    bool loading = false,
    String actionLabel = 'Try Again',
    FutureOr<void> Function()? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 18),
            AppText(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            AppText(body, textAlign: TextAlign.center),
            if (loading) ...[
              const SizedBox(height: 22),
              const CircularProgressIndicator(),
            ],
            if (action != null) ...[
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => action(),
                child: AppText(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

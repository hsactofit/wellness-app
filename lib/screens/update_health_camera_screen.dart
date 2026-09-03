import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/body_composition_report.dart';
import '../services/body_composition_ocr_service.dart';
import '../services/camera_permission_gate.dart';

enum _CaptureState {
  preparing,
  camera,
  preview,
  processing,
  noText,
  denied,
  error,
}

class UpdateHealthCameraScreen extends StatefulWidget {
  const UpdateHealthCameraScreen({super.key});

  @override
  State<UpdateHealthCameraScreen> createState() =>
      _UpdateHealthCameraScreenState();
}

class _UpdateHealthCameraScreenState extends State<UpdateHealthCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  _CaptureState _state = _CaptureState.preparing;
  String? _temporaryImagePath;
  String? _errorMessage;
  FlashMode _flashMode = FlashMode.off;
  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _state == _CaptureState.camera) {
      _prepareCamera(requestPermission: false);
    } else if (state != AppLifecycleState.resumed) {
      _cameraController?.dispose();
      _cameraController = null;
    }
  }

  Future<void> _prepareCamera({bool requestPermission = true}) async {
    if (!mounted) return;
    setState(() {
      _state = _CaptureState.preparing;
      _errorMessage = null;
    });

    final permission = await CameraPermissionGate().ensure(
      requestIfNeeded: requestPermission,
    );
    if (permission != CameraPermissionResult.granted) {
      if (!mounted) {
        return;
      }
      setState(() => _state = _CaptureState.denied);
      return;
    }

    try {
      final cameras = await availableCameras();
      final rearCamera =
          cameras
              .where(
                (camera) => camera.lensDirection == CameraLensDirection.back,
              )
              .firstOrNull ??
          cameras.firstOrNull;
      if (rearCamera == null) {
        throw CameraException(
          'no_camera',
          'No rear camera is available on this device.',
        );
      }

      await _cameraController?.dispose();
      final controller = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _state = _CaptureState.camera;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.description ?? 'We could not open the camera.';
        _state = _CaptureState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'We could not open the camera. Please try again.';
        _state = _CaptureState.error;
      });
    }
  }

  Future<void> _capture() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    try {
      final picture = await controller.takePicture();
      if (!mounted) {
        await BodyCompositionOcrService.instance.deleteTemporaryCapture(
          picture.path,
        );
        return;
      }
      await BodyCompositionOcrService.instance.trackTemporaryCapture(
        picture.path,
      );
      if (!mounted) {
        await BodyCompositionOcrService.instance.deleteTemporaryCapture(
          picture.path,
        );
        return;
      }
      setState(() {
        _temporaryImagePath = picture.path;
        _state = _CaptureState.preview;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.description ?? 'Could not take the photo.'),
        ),
      );
    }
  }

  Future<void> _retake() async {
    await BodyCompositionOcrService.instance.deleteTemporaryCapture(
      _temporaryImagePath,
    );
    if (!mounted) return;
    setState(() {
      _temporaryImagePath = null;
      _state = _CaptureState.camera;
    });
  }

  Future<void> _usePhoto() async {
    final imagePath = _temporaryImagePath;
    if (imagePath == null) return;
    setState(() => _state = _CaptureState.processing);

    BodyCompositionDraft? draft;
    try {
      draft = await BodyCompositionOcrService.instance.readReport(imagePath);
      if (draft != null &&
          !BodyCompositionOcrService.instance.hasRecognizedMeasurements(
            draft.measurements,
          )) {
        draft = null;
        _errorMessage =
            'We could not find health measurements in that image. Try a sharper, well-lit photo of the complete report.';
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'We could not read that report. Make sure the text is sharp and well lit.';
          _state = _CaptureState.noText;
        });
      }
    } finally {
      await BodyCompositionOcrService.instance.deleteTemporaryCapture(
        imagePath,
      );
      _temporaryImagePath = null;
    }

    if (!mounted || draft == null) {
      if (mounted && _state == _CaptureState.processing) {
        setState(() => _state = _CaptureState.noText);
      }
      return;
    }
    Navigator.of(context).pop(draft);
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null) return;
    final next = _flashMode == FlashMode.torch
        ? FlashMode.off
        : FlashMode.torch;
    try {
      await controller.setFlashMode(next);
      if (mounted) setState(() => _flashMode = next);
    } on CameraException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash is not available on this camera.')),
      );
    }
  }

  Future<void> _focusAt(Offset localPosition, Size previewSize) async {
    final controller = _cameraController;
    if (controller == null || previewSize.isEmpty) return;
    final point = Offset(
      (localPosition.dx / previewSize.width).clamp(0.0, 1.0).toDouble(),
      (localPosition.dy / previewSize.height).clamp(0.0, 1.0).toDouble(),
    );
    try {
      await controller.setFocusPoint(point);
      if (mounted) setState(() => _focusPoint = localPosition);
    } on CameraException catch (_) {
      // Some hardware has fixed focus; the framing guidance still applies.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    unawaited(
      BodyCompositionOcrService.instance.deleteTemporaryCapture(
        _temporaryImagePath,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan BMI report'),
        actions: [
          if (_state == _CaptureState.camera)
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _flashMode == FlashMode.torch
                    ? Icons.flash_on
                    : Icons.flash_off,
              ),
              tooltip: _flashMode == FlashMode.torch
                  ? 'Turn flash off'
                  : 'Turn flash on',
            ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _CaptureState.preparing:
      case _CaptureState.processing:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Reading your report securely on this device',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      case _CaptureState.denied:
        return _buildMessage(
          icon: Icons.camera_alt_outlined,
          title: 'Camera access is needed',
          body:
              'Use your camera to scan a gym BMI or body-composition report. The photo is read on this device and deleted before upload.',
          primaryLabel: 'Allow Camera',
          onPrimary: () async {
            final gate = CameraPermissionGate();
            final result = await gate.ensure(requestIfNeeded: false);
            if (result == CameraPermissionResult.permanentlyDenied) {
              await gate.openSettings();
            } else {
              await _prepareCamera();
            }
          },
        );
      case _CaptureState.error:
        return _buildMessage(
          icon: Icons.camera_enhance_outlined,
          title: 'Camera unavailable',
          body: _errorMessage ?? 'We could not open the camera.',
          primaryLabel: 'Try Again',
          onPrimary: _prepareCamera,
        );
      case _CaptureState.noText:
        return _buildMessage(
          icon: Icons.document_scanner_outlined,
          title: 'We could not read the report',
          body:
              _errorMessage ??
              'Make sure the report is flat, bright, and in focus, then try again.',
          primaryLabel: 'Retake Photo',
          onPrimary: _prepareCamera,
        );
      case _CaptureState.preview:
        return _buildPreview();
      case _CaptureState.camera:
        return _buildCamera();
    }
  }

  Widget _buildCamera() {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _focusAt(details.localPosition, constraints.biggest),
              child: CameraPreview(controller),
            ),
          ),
        ),
        Center(
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        if (_focusPoint != null)
          Positioned(
            left: _focusPoint!.dx - 24,
            top: _focusPoint!.dy - 24,
            child: IgnorePointer(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        const Positioned(
          left: 28,
          right: 28,
          bottom: 120,
          child: Text(
            'Fit the whole report inside the frame. Tap text to focus; keep labels and numbers sharp and glare-free.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: Center(
            child: Semantics(
              button: true,
              label: 'Capture BMI report',
              child: GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white70, width: 5),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final imagePath = _temporaryImagePath;
    if (imagePath == null) {
      return _buildMessage(
        icon: Icons.error_outline,
        title: 'Photo unavailable',
        body: 'Please take the report photo again.',
        primaryLabel: 'Open Camera',
        onPrimary: _prepareCamera,
      );
    }
    return Column(
      children: [
        Expanded(child: Image.file(File(imagePath), fit: BoxFit.contain)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFF17171A),
          child: Column(
            children: [
              const Text(
                'Check that every number is readable.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _retake,
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _usePhoto,
                      child: const Text('Use Photo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String body,
    required String primaryLabel,
    required Future<void> Function() onPrimary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: Colors.white),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

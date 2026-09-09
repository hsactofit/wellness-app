import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/exercise_video_service.dart';

class ExerciseVideoScreen extends StatefulWidget {
  const ExerciseVideoScreen({
    super.key,
    required this.exerciseName,
    required this.videoId,
    this.playbackContext = ExerciseVideoPlaybackContext.activeWorkout,
  });

  final String exerciseName;
  final String videoId;
  final ExerciseVideoPlaybackContext playbackContext;

  @override
  State<ExerciseVideoScreen> createState() => _ExerciseVideoScreenState();
}

class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _loading = true;
  bool _showControls = true;
  bool _isScrubbing = false;
  Duration? _scrubPosition;
  String _title = '';
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _title = widget.exerciseName;
    _load();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller?.removeListener(_onControllerTick);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cached = await ExerciseVideoCache.instance.cachedFile(
        widget.videoId,
      );
      if (cached != null) {
        await _openFile(cached);
        return;
      }
      final playback = await ExerciseVideoService.instance.fetchPlayback(
        widget.videoId,
        context: widget.playbackContext,
      );
      if (!mounted) return;
      setState(() => _title = playback.title.isEmpty ? _title : playback.title);
      await _openNetwork(playback.url);
      ExerciseVideoCache.instance.prefetch(widget.videoId, playback.url);
    } on ExerciseVideoException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not play this exercise video.';
        _loading = false;
      });
    }
  }

  Future<void> _openFile(File file) async {
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    await controller.play();
    controller.addListener(_onControllerTick);
    setState(() {
      _controller = controller;
      _loading = false;
    });
    _scheduleControlsHide();
  }

  Future<void> _openNetwork(Uri url) async {
    final controller = VideoPlayerController.networkUrl(url);
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    await controller.play();
    controller.addListener(_onControllerTick);
    setState(() {
      _controller = controller;
      _loading = false;
    });
    _scheduleControlsHide();
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    final isComplete =
        value.duration > Duration.zero && value.position >= value.duration;
    if (isComplete) await controller.seekTo(Duration.zero);
    if (value.isPlaying) {
      await controller.pause();
      _controlsTimer?.cancel();
      if (mounted) setState(() => _showControls = true);
    } else {
      await controller.play();
      if (mounted) setState(() => _showControls = true);
      _scheduleControlsHide();
    }
  }

  Future<void> _seekRelative(Duration offset) async {
    final controller = _controller;
    if (controller == null) return;
    final target = exerciseVideoSeekTarget(
      position: controller.value.position,
      duration: controller.value.duration,
      offset: offset,
    );
    await controller.seekTo(target);
    _keepControlsVisibleAfterInteraction();
  }

  void _beginScrubbing(double value) {
    _controlsTimer?.cancel();
    setState(() {
      _isScrubbing = true;
      _scrubPosition = Duration(milliseconds: value.round());
      _showControls = true;
    });
  }

  void _updateScrubbing(double value) {
    setState(() {
      _scrubPosition = Duration(milliseconds: value.round());
    });
  }

  Future<void> _completeScrubbing(double value) async {
    final controller = _controller;
    if (controller == null) return;
    final target = Duration(milliseconds: value.round());
    await controller.seekTo(target);
    if (!mounted) return;
    setState(() {
      _isScrubbing = false;
      _scrubPosition = null;
    });
    _keepControlsVisibleAfterInteraction();
  }

  void _keepControlsVisibleAfterInteraction() {
    if (!mounted) return;
    setState(() => _showControls = true);
    if (_controller?.value.isPlaying ?? false) {
      _scheduleControlsHide();
    }
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(milliseconds: 1200), () {
      final controller = _controller;
      if (!mounted || controller == null || !controller.value.isPlaying) return;
      setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _showControls = !_showControls);
    if (_showControls && controller.value.isPlaying) {
      _scheduleControlsHide();
    } else {
      _controlsTimer?.cancel();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) return '$minutes:$seconds';
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_title.isEmpty ? widget.exerciseName : _title),
        actions: [
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Video is not available.'));
    }
    final value = controller.value;
    final isComplete =
        value.duration > Duration.zero && value.position >= value.duration;
    final displayedPosition = _isScrubbing
        ? (_scrubPosition ?? value.position)
        : value.position;
    final durationMilliseconds = value.duration.inMilliseconds;
    final sliderValue = displayedPosition.inMilliseconds
        .clamp(0, durationMilliseconds)
        .toDouble();
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleControls,
                    child: VideoPlayer(controller),
                  ),
                  if (_showControls || !value.isPlaying || isComplete)
                    ExerciseVideoPlaybackControls(
                      isPlaying: value.isPlaying,
                      isComplete: isComplete,
                      onRewind: () =>
                          _seekRelative(const Duration(seconds: -10)),
                      onTogglePlayback: _togglePlayback,
                      onForward: () =>
                          _seekRelative(const Duration(seconds: 10)),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: sliderValue,
            min: 0,
            max: durationMilliseconds > 0 ? durationMilliseconds.toDouble() : 1,
            onChangeStart: durationMilliseconds > 0 ? _beginScrubbing : null,
            onChanged: durationMilliseconds > 0 ? _updateScrubbing : null,
            onChangeEnd: durationMilliseconds > 0 ? _completeScrubbing : null,
            semanticFormatterCallback: (milliseconds) =>
                _formatDuration(Duration(milliseconds: milliseconds.round())),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(displayedPosition)),
            Text(_formatDuration(value.duration)),
          ],
        ),
      ],
    );
  }
}

Duration exerciseVideoSeekTarget({
  required Duration position,
  required Duration duration,
  required Duration offset,
}) {
  final target = position + offset;
  if (target < Duration.zero) return Duration.zero;
  if (duration > Duration.zero && target > duration) return duration;
  return target;
}

class ExerciseVideoPlaybackControls extends StatelessWidget {
  const ExerciseVideoPlaybackControls({
    super.key,
    required this.isPlaying,
    required this.isComplete,
    required this.onRewind,
    required this.onTogglePlayback,
    required this.onForward,
  });

  final bool isPlaying;
  final bool isComplete;
  final VoidCallback onRewind;
  final VoidCallback onTogglePlayback;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            color: Colors.white,
            iconSize: 36,
            tooltip: 'Rewind 10 seconds',
            onPressed: onRewind,
            icon: const Icon(Icons.replay_10_rounded),
          ),
          IconButton(
            iconSize: 56,
            color: Colors.white,
            tooltip: isComplete
                ? 'Replay'
                : isPlaying
                ? 'Pause'
                : 'Play',
            onPressed: onTogglePlayback,
            icon: Icon(
              isComplete
                  ? Icons.replay
                  : isPlaying
                  ? Icons.pause_circle
                  : Icons.play_circle,
            ),
          ),
          IconButton(
            color: Colors.white,
            iconSize: 36,
            tooltip: 'Forward 10 seconds',
            onPressed: onForward,
            icon: const Icon(Icons.forward_10_rounded),
          ),
        ],
      ),
    );
  }
}

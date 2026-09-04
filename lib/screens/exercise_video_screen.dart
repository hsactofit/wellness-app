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
  String _title = '';

  @override
  void initState() {
    super.initState();
    _title = widget.exerciseName;
    _load();
  }

  @override
  void dispose() {
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
    } else {
      await controller.play();
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
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(controller),
                  IconButton(
                    iconSize: 56,
                    color: Colors.white,
                    tooltip: isComplete
                        ? 'Replay'
                        : value.isPlaying
                        ? 'Pause'
                        : 'Play',
                    onPressed: _togglePlayback,
                    icon: Icon(
                      isComplete
                          ? Icons.replay
                          : value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        VideoProgressIndicator(controller, allowScrubbing: true),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(value.position)),
            Text(_formatDuration(value.duration)),
          ],
        ),
      ],
    );
  }
}

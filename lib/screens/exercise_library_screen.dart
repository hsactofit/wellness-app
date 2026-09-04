import 'package:flutter/material.dart';

import '../services/exercise_video_service.dart';
import 'exercise_video_screen.dart';

typedef ExerciseVideoLibraryLoader =
    Future<List<ExerciseVideoLibraryItem>> Function();

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({
    super.key,
    this.libraryLoader,
    this.onOpenVideo,
  });

  final ExerciseVideoLibraryLoader? libraryLoader;
  final ValueChanged<ExerciseVideoLibraryItem>? onOpenVideo;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();
  List<ExerciseVideoLibraryItem> _videos = const [];
  String? _selectedTopic;
  String? _error;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _showingSavedLibrary = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadLibrary();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLibrary() async {
    final saved = await ExerciseVideoLibraryStore.load();
    if (!mounted) return;
    if (saved != null) {
      setState(() {
        _videos = saved;
        _showingSavedLibrary = true;
        _isLoading = false;
        _isRefreshing = true;
        _error = null;
      });
    }

    try {
      final loader =
          widget.libraryLoader ?? ExerciseVideoService.instance.fetchLibrary;
      final loaded = await loader();
      await ExerciseVideoLibraryStore.save(loaded);
      if (!mounted) return;
      setState(() {
        _videos = loaded;
        _showingSavedLibrary = false;
        _isLoading = false;
        _isRefreshing = false;
        _error = null;
      });
    } on ExerciseVideoException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _error = 'Could not refresh the exercise library.';
      });
    }
  }

  List<String> get _topics {
    final topics = _videos.expand((video) => video.topics).toSet().toList()
      ..sort();
    return topics;
  }

  List<ExerciseVideoLibraryItem> get _filteredVideos =>
      filterExerciseVideoLibrary(
        _videos,
        query: _searchController.text,
        topic: _selectedTopic,
      );

  void _openVideo(ExerciseVideoLibraryItem video) {
    final callback = widget.onOpenVideo;
    if (callback != null) {
      callback(video);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseVideoScreen(
          exerciseName: video.title,
          videoId: video.id,
          playbackContext: ExerciseVideoPlaybackContext.library,
        ),
      ),
    );
  }

  String _durationLabel(int? durationSec) {
    if (durationSec == null || durationSec <= 0) return '';
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    if (minutes == 0) return '$seconds sec';
    if (seconds == 0) return '$minutes min';
    return '$minutes min $seconds sec';
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredVideos;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            tooltip: 'Refresh library',
            onPressed: _isRefreshing ? null : _loadLibrary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading && _videos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText: 'Search by exercise or topic',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: _searchController.clear,
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (_topics.isNotEmpty)
                    SizedBox(
                      height: 46,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('All topics'),
                              selected: _selectedTopic == null,
                              onSelected: (_) =>
                                  setState(() => _selectedTopic = null),
                            ),
                          ),
                          ..._topics.map(
                            (topic) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(topic),
                                selected: _selectedTopic == topic,
                                onSelected: (_) => setState(
                                  () => _selectedTopic = _selectedTopic == topic
                                      ? null
                                      : topic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_showingSavedLibrary || _error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: _buildStatusMessage(),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      children: [
                        Text(
                          '${results.length} ${results.length == 1 ? 'video' : 'videos'}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        if (_isRefreshing) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: results.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: results.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) =>
                                _buildVideoCard(results[index]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    final theme = Theme.of(context);
    final hasSavedVideos = _videos.isNotEmpty;
    final text = hasSavedVideos
        ? 'Showing your saved library. Connect to refresh it.'
        : (_error ?? 'Could not load the exercise library.');
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
            TextButton(onPressed: _loadLibrary, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final queryOrFilterApplied =
        _searchController.text.trim().isNotEmpty || _selectedTopic != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              queryOrFilterApplied
                  ? Icons.search_off
                  : Icons.video_library_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              queryOrFilterApplied
                  ? 'No videos match your search.'
                  : (_error ?? 'No exercise videos are available yet.'),
              textAlign: TextAlign.center,
            ),
            if (queryOrFilterApplied) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() {
                  _searchController.clear();
                  _selectedTopic = null;
                }),
                child: const Text('Clear filters'),
              ),
            ] else if (_error != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadLibrary, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(ExerciseVideoLibraryItem video) {
    final duration = _durationLabel(video.durationSec);
    return Card(
      child: ListTile(
        onTap: () => _openVideo(video),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(child: const Icon(Icons.play_arrow_rounded)),
        title: Text(
          video.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video.topics.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: video.topics
                    .map(
                      (topic) => Chip(
                        label: Text(topic),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (duration.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(duration),
            ],
          ],
        ),
        trailing: const Icon(Icons.play_circle_outline),
      ),
    );
  }
}

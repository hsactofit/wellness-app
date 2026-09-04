import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class ExerciseVideoException implements Exception {
  ExerciseVideoException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum ExerciseVideoPlaybackContext { activeWorkout, library }

class ExerciseVideoLibraryItem {
  const ExerciseVideoLibraryItem({
    required this.id,
    required this.title,
    required this.topics,
    required this.durationSec,
    required this.sortOrder,
  });

  final String id;
  final String title;
  final List<String> topics;
  final int? durationSec;
  final int sortOrder;

  factory ExerciseVideoLibraryItem.fromJson(Map<String, dynamic> json) {
    final rawTopics = json['topics'];
    return ExerciseVideoLibraryItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Exercise video',
      topics: rawTopics is List
          ? rawTopics
                .map((topic) => topic.toString().trim())
                .where((topic) => topic.isNotEmpty)
                .toList(growable: false)
          : const [],
      durationSec: (json['duration_sec'] as num?)?.toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'topics': topics,
    'duration_sec': durationSec,
    'sort_order': sortOrder,
  };
}

List<ExerciseVideoLibraryItem> filterExerciseVideoLibrary(
  Iterable<ExerciseVideoLibraryItem> videos, {
  String query = '',
  String? topic,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final normalizedTopic = topic?.trim().toLowerCase();
  return videos
      .where((video) {
        final matchesTopic =
            normalizedTopic == null ||
            normalizedTopic.isEmpty ||
            video.topics.any((value) => value.toLowerCase() == normalizedTopic);
        if (!matchesTopic) return false;
        if (normalizedQuery.isEmpty) return true;
        final searchable = [
          video.title,
          ...video.topics,
        ].join(' ').toLowerCase();
        return searchable.contains(normalizedQuery);
      })
      .toList(growable: false);
}

class ExerciseVideoPlayback {
  const ExerciseVideoPlayback({
    required this.videoId,
    required this.title,
    required this.url,
    required this.expiresAt,
    required this.cacheTtlSec,
  });

  final String videoId;
  final String title;
  final Uri url;
  final DateTime expiresAt;
  final int cacheTtlSec;

  factory ExerciseVideoPlayback.fromJson(Map<String, dynamic> json) {
    return ExerciseVideoPlayback(
      videoId: json['video_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Exercise',
      url: Uri.parse(json['url']?.toString() ?? ''),
      expiresAt:
          DateTime.tryParse(json['expires_at']?.toString() ?? '') ??
          DateTime.now().toUtc().add(const Duration(minutes: 15)),
      cacheTtlSec: (json['cache_ttl_sec'] as num?)?.toInt() ?? 900,
    );
  }
}

class ExerciseVideoLibraryStore {
  ExerciseVideoLibraryStore._();

  static const _storageKey = 'exercise_video_library_v1';

  static Future<List<ExerciseVideoLibraryItem>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map(
            (item) => ExerciseVideoLibraryItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(Iterable<ExerciseVideoLibraryItem> videos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(videos.map((video) => video.toJson()).toList()),
    );
  }
}

class ExerciseVideoService {
  ExerciseVideoService._();

  static final ExerciseVideoService instance = ExerciseVideoService._();

  Future<http.Response> _send(String path) async {
    final uri = AuthService.apiUrl(path);
    Future<http.Response> request(String? token) {
      return http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    }

    var token = await AuthService.instance.getAccessToken();
    var response = await request(token);
    if (response.statusCode == 401) {
      await AuthService.instance.refreshSessionToken();
      token = await AuthService.instance.getAccessToken();
      response = await request(token);
    }
    return response;
  }

  Future<List<ExerciseVideoLibraryItem>> fetchLibrary() async {
    final response = await _send('/api/exercise-videos');
    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ExerciseVideoException(_message(body, response.statusCode));
    }
    if (body is! List) {
      throw ExerciseVideoException('Could not load the exercise library.');
    }
    final videos =
        body
            .whereType<Map>()
            .map(
              (item) => ExerciseVideoLibraryItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((item) => item.id.isNotEmpty)
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return videos;
  }

  Future<ExerciseVideoPlayback> fetchPlayback(
    String videoId, {
    ExerciseVideoPlaybackContext context =
        ExerciseVideoPlaybackContext.activeWorkout,
  }) async {
    final path = switch (context) {
      ExerciseVideoPlaybackContext.activeWorkout =>
        '/api/attendance/exercise-videos/$videoId/playback',
      ExerciseVideoPlaybackContext.library =>
        '/api/exercise-videos/$videoId/playback',
    };
    final response = await _send(path);
    final body = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ExerciseVideoException(_message(body, response.statusCode));
    }
    if (body is! Map) {
      throw ExerciseVideoException('Could not start the demonstration video.');
    }
    final playback = ExerciseVideoPlayback.fromJson(
      Map<String, dynamic>.from(body),
    );
    if (playback.videoId.isEmpty || playback.url.scheme.isEmpty) {
      throw ExerciseVideoException('Could not start the demonstration video.');
    }
    return playback;
  }

  dynamic _decode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _message(dynamic body, int statusCode) {
    if (body is Map && body['detail'] != null) return body['detail'].toString();
    if (statusCode == 503) {
      return 'Exercise videos are not available yet.';
    }
    return 'Could not load exercise videos ($statusCode)';
  }
}

class ExerciseVideoCache {
  ExerciseVideoCache({Directory? directory, this.maxBytes = 300 * 1024 * 1024})
    : _directory = directory;

  static final ExerciseVideoCache instance = ExerciseVideoCache();

  final int maxBytes;
  Directory? _directory;

  Future<Directory> root() async {
    if (_directory != null) {
      if (!await _directory!.exists()) {
        await _directory!.create(recursive: true);
      }
      return _directory!;
    }
    final temp = await getTemporaryDirectory();
    final directory = Directory('${temp.path}/medifit_exercise_videos');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    _directory = directory;
    return directory;
  }

  Future<File?> cachedFile(String videoId) async {
    final file = File('${(await root()).path}/${_safeName(videoId)}.mp4');
    if (!await file.exists() || await file.length() <= 0) return null;
    try {
      await file.setLastModified(DateTime.now());
    } catch (_) {
      // The video is still usable if the platform denies a timestamp update.
    }
    return file;
  }

  Future<File?> store(String videoId, List<int> bytes) async {
    if (bytes.isEmpty) return null;
    final file = File('${(await root()).path}/${_safeName(videoId)}.mp4');
    await file.writeAsBytes(bytes, flush: true);
    await evictToLimit(keep: {videoId});
    return file;
  }

  Future<void> prefetch(String videoId, Uri url) async {
    if (await cachedFile(videoId) != null) return;
    final request = http.Request('GET', url);
    final client = http.Client();
    try {
      final response = await client.send(request);
      if (response.statusCode != 200 && response.statusCode != 206) return;
      final file = File('${(await root()).path}/${_safeName(videoId)}.mp4');
      final partial = File('${file.path}.download');
      if (await partial.exists()) await partial.delete();
      final sink = partial.openWrite();
      try {
        await response.stream.pipe(sink);
      } finally {
        await sink.close();
      }
      if (await partial.length() <= 0) {
        await partial.delete();
        return;
      }
      if (await file.exists()) await file.delete();
      await partial.rename(file.path);
      await evictToLimit(keep: {videoId});
    } catch (_) {
      final partial = File(
        '${(await root()).path}/${_safeName(videoId)}.mp4.download',
      );
      if (await partial.exists()) await partial.delete();
      // Streaming still works from the signed URL; cache is best-effort.
    } finally {
      client.close();
    }
  }

  Future<void> evictToLimit({Set<String> keep = const {}}) async {
    final directory = await root();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.mp4'))
        .toList();
    files.sort(
      (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
    );
    var total = 0;
    for (final file in files) {
      total += await file.length();
    }
    for (final file in files) {
      if (total <= maxBytes) return;
      final id = _idFromPath(file.path);
      if (keep.contains(id)) continue;
      total -= await file.length();
      await file.delete();
    }
  }

  String _safeName(String videoId) =>
      videoId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  String _idFromPath(String path) {
    final name = path.split(Platform.pathSeparator).last;
    return name.endsWith('.mp4') ? name.substring(0, name.length - 4) : name;
  }
}

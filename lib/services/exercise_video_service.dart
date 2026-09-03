import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'auth_service.dart';

class ExerciseVideoException implements Exception {
  ExerciseVideoException(this.message);

  final String message;

  @override
  String toString() => message;
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

  Future<ExerciseVideoPlayback> fetchPlayback(String videoId) async {
    final response = await _send(
      '/api/attendance/exercise-videos/$videoId/playback',
    );
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
      return 'Demonstration videos are not available yet.';
    }
    return 'Could not load the demonstration video ($statusCode)';
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
    if (await file.exists() && await file.length() > 0) return file;
    return null;
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
      final sink = file.openWrite();
      try {
        await response.stream.pipe(sink);
      } finally {
        await sink.close();
      }
      await evictToLimit(keep: {videoId});
    } catch (_) {
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

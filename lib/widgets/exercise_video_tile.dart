import 'package:flutter/material.dart';

class ExerciseVideoTile extends StatelessWidget {
  const ExerciseVideoTile({
    super.key,
    required this.name,
    required this.details,
    required this.hasVideo,
    required this.onOpen,
  });

  final String name;
  final String details;
  final bool hasVideo;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onOpen,
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: details.isEmpty ? null : Text(details),
        trailing: Icon(
          hasVideo ? Icons.play_circle_outline : Icons.videocam_off_outlined,
        ),
      ),
    );
  }
}

String? exerciseVideoId(Map<String, dynamic> item) {
  final value = item['video_id']?.toString();
  if (value == null || value.isEmpty) return null;
  return value;
}

String exerciseDetails(Map<String, dynamic> item) {
  final details = <String>[];
  if (item['sets'] != null) details.add('${item['sets']} sets');
  if (item['reps'] != null) details.add('${item['reps']} reps');
  if (item['duration_min'] != null) {
    details.add('${item['duration_min']} min');
  }
  return details.join(' · ');
}

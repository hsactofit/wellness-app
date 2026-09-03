import 'package:flutter/material.dart';

import '../models/plan_models.dart';
import '../screens/challenges_screen.dart';
import '../screens/plan_screen.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>>? _notifications;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (mounted) setState(() => _error = null);

    try {
      final notifications = await ApiService.instance.fetchNotifications();
      if (!mounted) return;
      setState(() => _notifications = notifications);

      final unread = notifications.where((item) => item['read_at'] == null);
      await Future.wait(
        unread.map(
          (item) => ApiService.instance.markNotificationRead(
            item['delivery_id'].toString(),
          ),
        ),
      );

      if (!mounted) return;
      final readAt = DateTime.now().toUtc().toIso8601String();
      setState(() {
        _notifications = notifications
            .map(
              (item) =>
                  item['read_at'] == null ? {...item, 'read_at': readAt} : item,
            )
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load notifications. Pull down to try again.';
        _notifications ??= [];
      });
      debugPrint('Notification inbox error: $error');
    }
  }

  IconData _iconForCategory(String category) {
    return switch (category) {
      'clinical' => Icons.medical_services_outlined,
      'attendance' => Icons.fitness_center_rounded,
      'program' => Icons.event_note_rounded,
      'reward' => Icons.emoji_events_outlined,
      'plan' => Icons.assignment_turned_in_outlined,
      'support' => Icons.support_agent_rounded,
      _ => Icons.notifications_outlined,
    };
  }

  Color _colorForPriority(String priority) {
    return switch (priority) {
      'critical' => Colors.redAccent,
      'high' => Colors.orange,
      _ => const Color(0xFF5B8CFF),
    };
  }

  String _formatCreatedAt(Object? raw) {
    final date = DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openAction(String? actionTo) {
    if (actionTo?.startsWith('/challenges') == true) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ChallengesScreen()));
      return;
    }
    final kind = switch (actionTo) {
      '/plans/nutrition' => PlanKind.nutrition,
      '/plans/workout' => PlanKind.workout,
      _ => null,
    };
    if (kind == null) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PlanScreen(kind: kind)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = _notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: notifications == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.62,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 54,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black26,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _error ?? 'No notifications yet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final priority = item['priority']?.toString() ?? '';
                        final color = _colorForPriority(priority);
                        final actionTo = item['action_to']?.toString();
                        final actionLabel = item['action_label']?.toString();
                        return GestureDetector(
                          onTap:
                              (actionTo?.startsWith('/plans/') == true ||
                                  actionTo?.startsWith('/challenges') == true)
                              ? () => _openAction(actionTo)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: color.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconForCategory(
                                      item['category']?.toString() ?? '',
                                    ),
                                    color: color,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']?.toString() ??
                                            'Notification',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['body']?.toString() ?? '',
                                        style: TextStyle(
                                          height: 1.35,
                                          fontSize: 13,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            _formatCreatedAt(
                                              item['created_at'],
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.black38,
                                            ),
                                          ),
                                          if (actionTo?.startsWith('/plans/') ==
                                                  true ||
                                              actionTo?.startsWith(
                                                    '/challenges',
                                                  ) ==
                                                  true) ...[
                                            const Spacer(),
                                            Text(
                                              actionLabel ?? 'View details',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: color,
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: color,
                                              size: 16,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

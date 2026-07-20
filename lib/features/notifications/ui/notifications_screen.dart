import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/notifications/state/notification_provider.dart';
import 'package:frontend/features/notifications/model/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'TASK_DUE': return Icons.alarm_rounded;
      case 'TASK_REMINDER': return Icons.notifications_rounded;
      case 'TASK_COMPLETED': return Icons.check_circle_rounded;
      case 'RECURRING_TASK': return Icons.repeat_rounded;
      default: return Icons.info_rounded;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'TASK_DUE': return const Color(0xFFEF4444);
      case 'TASK_COMPLETED': return const Color(0xFF22C55E);
      case 'RECURRING_TASK': return const Color(0xFF8B5CF6);
      default: return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: Color(0xFF6366F1), fontSize: 13),
              ),
            ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (provider.status == NotificationStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Something went wrong',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<NotificationProvider>().fetchNotifications(),
              child: const Text('Retry', style: TextStyle(color: Color(0xFF6366F1))),
            ),
          ],
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                color: Color(0xFF6366F1),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All caught up!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No notifications yet.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFF1A1A2E),
      onRefresh: () => context.read<NotificationProvider>().fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: provider.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final n = provider.notifications[index];
          return _NotificationCard(
            notification: n,
            iconData: _iconForType(n.type),
            accentColor: _colorForType(n.type),
            timeLabel: _formatTime(n.createdAt),
            onTap: () {
              if (!n.isRead) {
                context.read<NotificationProvider>().markAsRead(n.id);
              }
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final IconData iconData;
  final Color accentColor;
  final String timeLabel;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.iconData,
    required this.accentColor,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFF0F0F23) : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? accentColor.withOpacity(0.35)
                : Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

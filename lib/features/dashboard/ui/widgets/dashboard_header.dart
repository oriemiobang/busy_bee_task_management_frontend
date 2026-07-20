import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/features/notifications/state/notification_provider.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String userImage;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side: Avatar and text
        Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(userImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Notification bell with live badge
        Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            final unread = notifProvider.unreadCount;
            return GestureDetector(
              onTap: () {
                notifProvider.fetchNotifications();
                context.push(AppRoutes.notifications);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          unread > 99 ? '99+' : unread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getGreeting(DateTime time) {
    final hour = time.hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class NotificationBadge extends StatelessWidget {
  final Stream<int> notificationCount;
  final VoidCallback onTap;
  final double size;
  final Color badgeColor;
  final Color textColor;

  const NotificationBadge({
    super.key,
    required this.notificationCount,
    required this.onTap,
    this.size = 24.0,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: notificationCount,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Icon(
                Icons.notifications_rounded,
                size: size,
                color: Colors.white,
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Specialized notification badges for different types
class ChatNotificationBadge extends StatelessWidget {
  final String userId;
  final bool isAdmin;
  final VoidCallback onTap;
  final double size;

  const ChatNotificationBadge({
    super.key,
    required this.userId,
    required this.isAdmin,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final notificationCount =
        isAdmin
            ? NotificationService.getUnreadChatCountForAdmin()
            : NotificationService.getUnreadChatCountForPasien(userId);

    return NotificationBadge(
      notificationCount: notificationCount,
      onTap: onTap,
      size: size,
      badgeColor: const Color(0xFFEC407A), // Pink for chat
    );
  }
}

class ScheduleNotificationBadge extends StatelessWidget {
  final String userId;
  final bool isAdmin;
  final VoidCallback onTap;
  final double size;

  const ScheduleNotificationBadge({
    super.key,
    required this.userId,
    required this.isAdmin,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final notificationCount =
        isAdmin
            ? NotificationService.getPendingScheduleCountForAdmin()
            : NotificationService.getScheduleStatusUpdateCountForPasien(userId);

    return NotificationBadge(
      notificationCount: notificationCount,
      onTap: onTap,
      size: size,
      badgeColor: const Color(0xFF4CAF50), // Green for schedule
    );
  }
}

// Combined notification badge for home screens
class HomeNotificationBadge extends StatelessWidget {
  final String userId;
  final bool isAdmin;
  final VoidCallback onTap;
  final double size;

  const HomeNotificationBadge({
    super.key,
    required this.userId,
    required this.isAdmin,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _getCombinedNotificationCount(),
      builder: (context, snapshot) {
        final totalCount = snapshot.data ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              Icon(
                Icons.notifications_rounded,
                size: size,
                color: Colors.white,
              ),
              if (totalCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC407A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      totalCount > 99 ? '99+' : totalCount.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Stream<int> _getCombinedNotificationCount() {
    if (isAdmin) {
      // For admin: chat + schedule notifications
      return Stream.periodic(const Duration(seconds: 1), (_) {
        // This is a simplified approach - in real implementation you'd use proper stream combination
        return 0; // Placeholder - will be implemented with proper stream handling
      });
    } else {
      // For pasien: chat + schedule status updates
      return Stream.periodic(const Duration(seconds: 1), (_) {
        // This is a simplified approach - in real implementation you'd use proper stream combination
        return 0; // Placeholder - will be implemented with proper stream handling
      });
    }
  }
}

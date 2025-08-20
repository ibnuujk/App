import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;
  final double? size;

  const NotificationBadge({
    super.key,
    required this.child,
    this.badgeColor,
    this.textColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService.getUnreadCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        if (unreadCount == 0) {
          return child;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                width: size ?? 20,
                height: size ?? 20,
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(size ?? 20),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: (size ?? 20) * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget untuk icon notifikasi dengan badge
class NotificationIconWithBadge extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? textColor;
  final double? badgeSize;

  const NotificationIconWithBadge({
    super.key,
    this.onPressed,
    required this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      badgeColor: badgeColor,
      textColor: textColor,
      size: badgeSize,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

// Widget untuk text dengan badge
class NotificationTextWithBadge extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? badgeColor;
  final Color? textColor;
  final double? badgeSize;

  const NotificationTextWithBadge({
    super.key,
    required this.text,
    this.textStyle,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      badgeColor: badgeColor,
      textColor: textColor,
      size: badgeSize,
      child: Text(text, style: textStyle),
    );
  }
}

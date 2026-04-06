import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../../domain/models/notification_model.dart';

/// Notifications Screen
/// Displays all user notifications with read/unread states
/// Supports mark as read, delete, and click-to-navigate actions

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
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<NotificationProvider>().initNotificationListener(user.uid);
      }
    });
  }

  /// Navigate to the relevant screen based on notification type
  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read first
    context.read<NotificationProvider>().markAsRead(notification.notificationId);

    // Navigate based on notification type
    switch (notification.type) {
      case 'like':
      case 'comment':
        // Navigate to post detail if relatedId exists
        if (notification.relatedId.isNotEmpty) {
          // Post detail would need the PostModel, show snackbar instead
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening post: ${notification.relatedId}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        break;
      case 'event':
        if (notification.relatedId.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/events/${notification.relatedId}',
          );
        }
        break;
      case 'group':
        // Navigate to groups
        Navigator.pop(context); // Go back to home
        break;
      case 'message':
        // Navigate to messages
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                ),
              ),
            ),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'mark_all_read':
                        provider.markAllAsRead();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        break;
                      case 'delete_all':
                        _showDeleteAllDialog(provider);
                        break;
                      case 'test':
                        provider.sendTestNotification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test notification sent!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all, color: AppColors.primary),
                          SizedBox(width: 12),
                          Text('Mark all as read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('Delete all'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'test',
                      child: Row(
                        children: [
                          Icon(Icons.send, color: AppColors.info),
                          SizedBox(width: 12),
                          Text('Send test notification'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Notification List
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              // Loading
              if (provider.isLoading && provider.notifications.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              }

              // Empty state
              if (provider.notifications.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No notifications yet',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'You\'ll see notifications here when you\nget likes, comments, or event updates',
                          style: AppTextStyles.body2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: () => provider.sendTestNotification(),
                          icon: const Icon(Icons.send),
                          label: const Text('Send Test Notification'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Notifications list
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final notification = provider.notifications[index];
                    return _NotificationTile(
                      notification: notification,
                      onTap: () => _handleNotificationTap(notification),
                      onDismiss: () => provider
                          .deleteNotification(notification.notificationId),
                    );
                  },
                  childCount: provider.notifications.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete All'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all notifications? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications deleted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

/// Notification Tile Widget
/// Single notification item with swipe-to-dismiss
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final icon = NotificationProvider.getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.white
              : AppColors.primary.withOpacity(0.04),
          border: Border(
            bottom: BorderSide(
              color: AppColors.greyLight,
              width: 0.5,
            ),
            left: notification.isRead
                ? BorderSide.none
                : const BorderSide(
                    color: AppColors.primary,
                    width: 3,
                  ),
          ),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(
            notification.title,
            style: AppTextStyles.body1.copyWith(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: AppTextStyles.body2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                timeago.format(notification.timestamp),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'like':
        return AppColors.error;
      case 'comment':
        return AppColors.info;
      case 'event':
        return AppColors.warning;
      case 'group':
        return AppColors.success;
      case 'message':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}

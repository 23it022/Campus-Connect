import 'dart:async';
import '../../../../core/base/base_provider.dart';
import '../../domain/models/notification_model.dart';
import '../../data/services/notification_service.dart';

/// Notification Provider
/// Manages in-app notification state
/// Provides real-time notification updates via Firestore streams
/// Handles read/unread state and notification actions

class NotificationProvider extends BaseProvider {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  String? _currentUserId;
  StreamSubscription? _notificationSub;
  StreamSubscription? _unreadCountSub;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Initialize notification listener for a user
  void initNotificationListener(String userId) {
    _currentUserId = userId;

    // Cancel existing subscriptions
    _notificationSub?.cancel();
    _unreadCountSub?.cancel();

    // Listen to notifications stream (real-time updates)
    _notificationSub = _notificationService
        .getNotificationsStream(userId)
        .listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });

    // Listen to unread count stream
    _unreadCountSub = _notificationService
        .getUnreadCountStream(userId)
        .listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    await executeOperation(() async {
      await _notificationService.markAsRead(notificationId);
      // Update local state immediately
      final index = _notifications
          .indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    await executeOperation(() async {
      await _notificationService.markAllAsRead(_currentUserId!);
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    });
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await executeOperation(() async {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.notificationId == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    });
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    if (_currentUserId == null) return;
    await executeOperation(() async {
      await _notificationService.deleteAllNotifications(_currentUserId!);
      _notifications = [];
      _unreadCount = 0;
      notifyListeners();
    });
  }

  /// Send a test notification (for demo purposes)
  Future<void> sendTestNotification() async {
    if (_currentUserId == null) return;
    await _notificationService.createNotification(
      userId: _currentUserId!,
      title: 'Welcome to CampusConnect! 🎉',
      body: 'You have successfully enabled notifications.',
      type: 'system',
    );
  }

  /// Get icon for notification type
  static String getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return '❤️';
      case 'comment':
        return '💬';
      case 'event':
        return '📅';
      case 'group':
        return '👥';
      case 'message':
        return '✉️';
      case 'system':
        return '🔔';
      default:
        return '📢';
    }
  }

  /// Clean up subscriptions
  void disposeListeners() {
    _notificationSub?.cancel();
    _unreadCountSub?.cancel();
    _currentUserId = null;
  }

  @override
  void dispose() {
    disposeListeners();
    super.dispose();
  }
}

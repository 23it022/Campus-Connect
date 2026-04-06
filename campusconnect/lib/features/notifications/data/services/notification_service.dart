import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/notification_model.dart';

/// Notification Service
/// Handles all Firestore operations for in-app notifications
/// Supports creating, reading, marking read, and deleting notifications

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'notifications';

  /// Get notifications stream for a user (real-time updates)
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromDocument(doc))
            .toList());
  }

  /// Get unread count stream
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String relatedId = '',
  }) async {
    final notificationId = const Uuid().v4();
    final notification = NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
    );

    await _firestore
        .collection(_collection)
        .doc(notificationId)
        .set(notification.toMap());
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(_collection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final unread = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collection).doc(notificationId).delete();
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Send notification when someone likes a post
  Future<void> sendLikeNotification({
    required String postOwnerId,
    required String likerName,
    required String postId,
  }) async {
    await createNotification(
      userId: postOwnerId,
      title: 'New Like',
      body: '$likerName liked your post',
      type: 'like',
      relatedId: postId,
    );
  }

  /// Send notification when someone comments on a post
  Future<void> sendCommentNotification({
    required String postOwnerId,
    required String commenterName,
    required String postId,
  }) async {
    await createNotification(
      userId: postOwnerId,
      title: 'New Comment',
      body: '$commenterName commented on your post',
      type: 'comment',
      relatedId: postId,
    );
  }

  /// Send notification for new event
  Future<void> sendEventNotification({
    required String userId,
    required String eventTitle,
    required String eventId,
  }) async {
    await createNotification(
      userId: userId,
      title: 'New Event',
      body: 'Don\'t miss: $eventTitle',
      type: 'event',
      relatedId: eventId,
    );
  }

  /// Send notification for group activity
  Future<void> sendGroupNotification({
    required String userId,
    required String groupName,
    required String groupId,
    required String message,
  }) async {
    await createNotification(
      userId: userId,
      title: groupName,
      body: message,
      type: 'group',
      relatedId: groupId,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Model
/// Represents a notification for a user

class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type; // 'like', 'comment', 'follow', 'message', etc.
  final String relatedId; // ID of post, comment, user, etc.
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId = '',
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      relatedId: map['relatedId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data);
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

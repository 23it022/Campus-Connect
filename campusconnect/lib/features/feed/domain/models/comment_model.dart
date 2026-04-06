import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment Model
/// Represents a comment on a post

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String userProfileImage;
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfileImage = '',
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel.fromMap(data);
  }
}

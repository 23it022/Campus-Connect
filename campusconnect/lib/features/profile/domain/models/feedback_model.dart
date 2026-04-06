import 'package:cloud_firestore/cloud_firestore.dart';

/// Feedback Model
/// Represents user feedback and ratings for the app
class FeedbackModel {
  final String feedbackId;
  final String userId;
  final String userName;
  final int rating; // 1-5 stars
  final String comment;
  final String category;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create from Firestore map
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      feedbackId: map['feedbackId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      category: map['category'] ?? 'Other',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from Firestore document
  factory FeedbackModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel.fromMap(data);
  }

  /// Copy with method
  FeedbackModel copyWith({
    String? feedbackId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    String? category,
    DateTime? createdAt,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FeedbackModel(id: $feedbackId, rating: $rating, category: $category)';
  }
}

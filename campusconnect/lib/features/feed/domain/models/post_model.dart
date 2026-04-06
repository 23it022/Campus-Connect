import 'package:cloud_firestore/cloud_firestore.dart';

/// Post Model
/// Represents a social media post in CampusConnect
/// Contains post content, author information, and engagement data

class PostModel {
  final String postId; // Unique post ID
  final String userId; // Author's user ID
  final String username; // Author's display name
  final String userProfileImage; // Author's profile picture URL
  final String text; // Post text content
  final String imageUrl; // Optional post image URL
  final DateTime timestamp; // Post creation time
  final int likesCount; // Number of likes
  final List<String> likes; // List of user IDs who liked
  final int commentsCount; // Number of comments

  // New fields for enhanced functionality
  final List<String> bookmarkedBy; // Users who bookmarked this post
  final Map<String, int> reactions; // Reaction type -> count
  final Map<String, String> userReactions; // userId -> reaction type
  final List<String> hashtags; // Extracted hashtags from text
  final bool isEdited; // Whether post has been edited
  final DateTime? editedAt; // Last edit timestamp

  PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    this.userProfileImage = '',
    required this.text,
    this.imageUrl = '',
    DateTime? timestamp,
    this.likesCount = 0,
    List<String>? likes,
    this.commentsCount = 0,
    List<String>? bookmarkedBy,
    Map<String, int>? reactions,
    Map<String, String>? userReactions,
    List<String>? hashtags,
    this.isEdited = false,
    this.editedAt,
  })  : timestamp = timestamp ?? DateTime.now(),
        likes = likes ?? [],
        bookmarkedBy = bookmarkedBy ?? [],
        reactions = reactions ?? {},
        userReactions = userReactions ?? {},
        hashtags = hashtags ?? [];

  /// Convert PostModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likesCount': likesCount,
      'likes': likes,
      'commentsCount': commentsCount,
      'bookmarkedBy': bookmarkedBy,
      'reactions': reactions,
      'userReactions': userReactions,
      'hashtags': hashtags,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  /// Create PostModel from Firestore document
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userProfileImage: map['userProfileImage'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likesCount'] ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: map['commentsCount'] ?? 0,
      bookmarkedBy: List<String>.from(map['bookmarkedBy'] ?? []),
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
      userReactions: Map<String, String>.from(map['userReactions'] ?? {}),
      hashtags: List<String>.from(map['hashtags'] ?? []),
      isEdited: map['isEdited'] ?? false,
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create PostModel from Firestore DocumentSnapshot
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel.fromMap(data);
  }

  /// Create a copy of PostModel with modified fields
  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userProfileImage,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    int? likesCount,
    List<String>? likes,
    int? commentsCount,
    List<String>? bookmarkedBy,
    Map<String, int>? reactions,
    Map<String, String>? userReactions,
    List<String>? hashtags,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      bookmarkedBy: bookmarkedBy ?? this.bookmarkedBy,
      reactions: reactions ?? this.reactions,
      userReactions: userReactions ?? this.userReactions,
      hashtags: hashtags ?? this.hashtags,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Check if a user has liked this post
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  /// Check if a user has bookmarked this post
  bool isBookmarkedBy(String userId) {
    return bookmarkedBy.contains(userId);
  }

  /// Get user's reaction to this post
  String? getUserReaction(String userId) {
    return userReactions[userId];
  }

  /// Get total reactions count
  int get totalReactions {
    return reactions.values.fold(0, (sum, count) => sum + count);
  }

  /// Extract hashtags from text
  static List<String> extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(r'#[a-zA-Z0-9_]+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!.toLowerCase()).toList();
  }

  @override
  String toString() {
    return 'PostModel(postId: $postId, userId: $userId, text: $text, likesCount: $likesCount, reactions: $reactions)';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/network/firestore_service.dart';
import '../../../../shared/constants/constants.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/report_model.dart';

/// Post Service
/// Handles all post-related operations with Firestore

class PostService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Create a new post
  Future<void> createPost(PostModel post) async {
    // Extract hashtags from post text
    final hashtags = PostModel.extractHashtags(post.text);
    final postWithHashtags = post.copyWith(hashtags: hashtags);

    await _firestoreService.setDocument(
      collection: FirebaseCollections.posts,
      docId: post.postId,
      data: postWithHashtags.toMap(),
    );

    // Update hashtags collection for trending
    if (hashtags.isNotEmpty) {
      await _updateHashtagsCount(hashtags, increment: true);
    }
  }

  /// Get all posts (ordered by timestamp, newest first)
  Stream<List<PostModel>> getPostsStream() {
    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.posts,
      queryBuilder: (query) => query.orderBy('timestamp', descending: true),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    });
  }

  /// Get posts by a specific user
  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.posts,
      queryBuilder: (query) => query
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    });
  }

  /// Get bookmarked posts for a user
  Stream<List<PostModel>> getBookmarkedPostsStream(String userId) {
    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.posts,
      queryBuilder: (query) => query
          .where('bookmarkedBy', arrayContains: userId)
          .orderBy('timestamp', descending: true),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    });
  }

  /// Search posts by text
  Future<List<PostModel>> searchPosts(String searchQuery) async {
    final snapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.posts,
      queryBuilder: (query) => query.orderBy('timestamp', descending: true),
    );

    final posts =
        snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();

    // Filter posts based on search query
    return posts.where((post) {
      final textMatch =
          post.text.toLowerCase().contains(searchQuery.toLowerCase());
      final usernameMatch =
          post.username.toLowerCase().contains(searchQuery.toLowerCase());
      return textMatch || usernameMatch;
    }).toList();
  }

  /// Get posts by hashtag
  Stream<List<PostModel>> getPostsByHashtagStream(String hashtag) {
    final normalizedHashtag = hashtag.toLowerCase().startsWith('#')
        ? hashtag.toLowerCase()
        : '#${hashtag.toLowerCase()}';

    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.posts,
      queryBuilder: (query) => query
          .where('hashtags', arrayContains: normalizedHashtag)
          .orderBy('timestamp', descending: true),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromDocument(doc)).toList();
    });
  }

  /// Like a post
  Future<void> likePost(String postId, String userId) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'likes': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      },
    );
  }

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'likes': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      },
    );
  }

  /// Add reaction to post
  Future<void> addReaction(
      String postId, String userId, String reactionType) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'userReactions.$userId': reactionType,
        'reactions.$reactionType': FieldValue.increment(1),
      },
    );
  }

  /// Remove reaction from post
  Future<void> removeReaction(
      String postId, String userId, String reactionType) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'userReactions.$userId': FieldValue.delete(),
        'reactions.$reactionType': FieldValue.increment(-1),
      },
    );
  }

  /// Change reaction on post
  Future<void> changeReaction(
    String postId,
    String userId,
    String oldReaction,
    String newReaction,
  ) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'userReactions.$userId': newReaction,
        'reactions.$oldReaction': FieldValue.increment(-1),
        'reactions.$newReaction': FieldValue.increment(1),
      },
    );
  }

  /// Bookmark a post
  Future<void> bookmarkPost(String postId, String userId) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'bookmarkedBy': FieldValue.arrayUnion([userId]),
      },
    );
  }

  /// Unbookmark a post
  Future<void> unbookmarkPost(String postId, String userId) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'bookmarkedBy': FieldValue.arrayRemove([userId]),
      },
    );
  }

  /// Edit a post
  Future<void> editPost(String postId, String newText,
      {String? newImageUrl}) async {
    final hashtags = PostModel.extractHashtags(newText);

    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {
        'text': newText,
        if (newImageUrl != null) 'imageUrl': newImageUrl,
        'hashtags': hashtags,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      },
    );

    // Update hashtags count
    if (hashtags.isNotEmpty) {
      await _updateHashtagsCount(hashtags, increment: true);
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    // Get post to retrieve hashtags before deletion
    final doc = await _firestoreService.getDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
    );

    if (doc.exists) {
      final post = PostModel.fromDocument(doc);

      // Decrement hashtag counts
      if (post.hashtags.isNotEmpty) {
        await _updateHashtagsCount(post.hashtags, increment: false);
      }
    }

    await _firestoreService.deleteDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
    );
  }

  /// Report a post
  Future<void> reportPost(ReportModel report) async {
    await _firestoreService.setDocument(
      collection: FirebaseCollections.reports,
      docId: report.reportId,
      data: report.toMap(),
    );
  }

  /// Increment comment count
  Future<void> incrementCommentCount(String postId) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {'commentsCount': FieldValue.increment(1)},
    );
  }

  /// Decrement comment count
  Future<void> decrementCommentCount(String postId) async {
    await _firestoreService.updateDocument(
      collection: FirebaseCollections.posts,
      docId: postId,
      data: {'commentsCount': FieldValue.increment(-1)},
    );
  }

  /// Update hashtags count in separate collection
  Future<void> _updateHashtagsCount(List<String> hashtags,
      {required bool increment}) async {
    for (final hashtag in hashtags) {
      await _firestoreService.setDocument(
        collection: FirebaseCollections.hashtags,
        docId: hashtag.replaceAll('#', ''),
        data: {
          'tag': hashtag,
          'count': FieldValue.increment(increment ? 1 : -1),
          'lastUsed': FieldValue.serverTimestamp(),
        },
        merge: true,
      );
    }
  }

  /// Get trending hashtags
  Future<List<String>> getTrendingHashtags({int limit = 10}) async {
    final snapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.hashtags,
      queryBuilder: (query) =>
          query.orderBy('count', descending: true).limit(limit),
    );

    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['tag'] as String)
        .toList();
  }
}

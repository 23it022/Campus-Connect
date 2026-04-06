import '../../../../core/network/firestore_service.dart';
import '../../../../shared/constants/constants.dart';
import '../../domain/models/comment_model.dart';
import 'post_service.dart';

/// Comment Service
/// Handles all comment-related operations with Firestore

class CommentService {
  final FirestoreService _firestoreService = FirestoreService();
  final PostService _postService = PostService();

  /// Add a comment to a post
  Future<void> addComment(CommentModel comment) async {
    // Add comment document
    await _firestoreService.setDocument(
      collection: FirebaseCollections.comments,
      docId: comment.commentId,
      data: comment.toMap(),
    );

    // Increment comment count on post
    await _postService.incrementCommentCount(comment.postId);
  }

  /// Get comments for a specific post (ordered by timestamp, oldest first)
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestoreService
        .streamDocuments(
      collection: FirebaseCollections.comments,
      queryBuilder: (query) => query
          .where('postId', isEqualTo: postId)
          .orderBy('timestamp', descending: false),
    )
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommentModel.fromDocument(doc))
          .toList();
    });
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    // Delete comment document
    await _firestoreService.deleteDocument(
      collection: FirebaseCollections.comments,
      docId: commentId,
    );

    // Decrement comment count on post
    await _postService.decrementCommentCount(postId);
  }

  /// Get comment count for a post
  Future<int> getCommentCount(String postId) async {
    final snapshot = await _firestoreService.getDocuments(
      collection: FirebaseCollections.comments,
      queryBuilder: (query) => query.where('postId', isEqualTo: postId),
    );
    return snapshot.docs.length;
  }
}

import 'package:uuid/uuid.dart';
import '../../../../core/base/base_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/comment_model.dart';
import '../../data/services/comment_service.dart';

/// Comment Provider
/// Manages comment state and operations for a specific post

class CommentProvider extends BaseProvider {
  final CommentService _commentService = CommentService();
  final AuthProvider _authProvider;
  final String postId;

  List<CommentModel> _comments = [];

  List<CommentModel> get comments => _comments;

  CommentProvider(this._authProvider, this.postId) {
    _initCommentsListener();
  }

  /// Initialize comments listener for real-time updates
  void _initCommentsListener() {
    _commentService.getCommentsStream(postId).listen((comments) {
      _comments = comments;
      notifyListeners();
    });
  }

  /// Add a new comment
  Future<bool> addComment(String text) async {
    final user = _authProvider.currentUser;
    if (user == null) {
      setError('Please login to comment');
      return false;
    }

    if (text.trim().isEmpty) {
      setError('Comment cannot be empty');
      return false;
    }

    final commentId = const Uuid().v4();
    final comment = CommentModel(
      commentId: commentId,
      postId: postId,
      userId: user.uid,
      username: user.name,
      userProfileImage: user.profileImage,
      text: text.trim(),
    );

    await executeOperation(() => _commentService.addComment(comment));
    return !isLoading && errorMessage.isEmpty;
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    await executeOperation(
        () => _commentService.deleteComment(commentId, postId));
    return !isLoading && errorMessage.isEmpty;
  }
}

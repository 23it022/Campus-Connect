import '../../../../core/base/base_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/post_model.dart';
import '../../data/services/post_service.dart';

/// Bookmark Provider
/// Manages bookmarked posts state

class BookmarkProvider extends BaseProvider {
  final PostService _postService = PostService();
  final AuthProvider _authProvider;

  List<PostModel> _bookmarkedPosts = [];

  List<PostModel> get bookmarkedPosts => _bookmarkedPosts;

  BookmarkProvider(this._authProvider) {
    _initBookmarksListener();
  }

  /// Initialize bookmarks listener
  void _initBookmarksListener() {
    final user = _authProvider.currentUser;
    if (user != null) {
      _postService.getBookmarkedPostsStream(user.uid).listen((posts) {
        _bookmarkedPosts = posts;
        notifyListeners();
      });
    }
  }

  /// Toggle bookmark on a post
  Future<void> toggleBookmark(PostModel post) async {
    final user = _authProvider.currentUser;
    if (user == null) return;

    if (post.isBookmarkedBy(user.uid)) {
      await executeOperation(
          () => _postService.unbookmarkPost(post.postId, user.uid));
    } else {
      await executeOperation(
          () => _postService.bookmarkPost(post.postId, user.uid));
    }
  }

  /// Check if post is bookmarked
  bool isBookmarked(String postId) {
    return _bookmarkedPosts.any((post) => post.postId == postId);
  }
}

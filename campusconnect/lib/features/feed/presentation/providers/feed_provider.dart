import '../../../../core/base/base_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/report_model.dart';
import '../../data/services/post_service.dart';
import 'package:uuid/uuid.dart';

/// Feed Provider
/// Manages feed state and post operations

enum FeedFilter { all, trending, following }

class FeedProvider extends BaseProvider {
  final PostService _postService = PostService();
  final AuthProvider _authProvider;

  List<PostModel> _posts = [];
  List<PostModel> _filteredPosts = [];
  FeedFilter _currentFilter = FeedFilter.all;
  String? _searchQuery;
  String? _selectedHashtag;
  List<String> _trendingHashtags = [];

  List<PostModel> get posts =>
      _filteredPosts.isEmpty && _searchQuery == null && _selectedHashtag == null
          ? _posts
          : _filteredPosts;

  FeedFilter get currentFilter => _currentFilter;
  String? get searchQuery => _searchQuery;
  String? get selectedHashtag => _selectedHashtag;
  List<String> get trendingHashtags => _trendingHashtags;

  FeedProvider(this._authProvider) {
    _initFeedListener();
    _loadTrendingHashtags();
  }

  /// Initialize feed listener
  void _initFeedListener() {
    _postService.getPostsStream().listen((posts) {
      _posts = posts;
      _applyFilters();
    });
  }

  /// Load trending hashtags
  Future<void> _loadTrendingHashtags() async {
    _trendingHashtags = await _postService.getTrendingHashtags();
    notifyListeners();
  }

  /// Apply current filters to posts
  void _applyFilters() {
    List<PostModel> filtered = List.from(_posts);

    // Apply filter
    if (_currentFilter == FeedFilter.following) {
      // TODO: Implement following filter when following feature is available
      filtered = _posts;
    } else if (_currentFilter == FeedFilter.trending) {
      // Sort by total engagement (likes + reactions + comments)
      filtered.sort((a, b) {
        final aScore = a.likesCount + a.totalReactions + a.commentsCount;
        final bScore = b.likesCount + b.totalReactions + b.commentsCount;
        return bScore.compareTo(aScore);
      });
    }

    // Apply search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered.where((post) {
        final textMatch =
            post.text.toLowerCase().contains(_searchQuery!.toLowerCase());
        final usernameMatch =
            post.username.toLowerCase().contains(_searchQuery!.toLowerCase());
        return textMatch || usernameMatch;
      }).toList();
    }

    // Apply hashtag filter
    if (_selectedHashtag != null) {
      filtered = filtered.where((post) {
        return post.hashtags.contains(_selectedHashtag!.toLowerCase());
      }).toList();
    }

    _filteredPosts = filtered;
    notifyListeners();
  }

  /// Set filter
  void setFilter(FeedFilter filter) {
    _currentFilter = filter;
    _applyFilters();
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set hashtag filter
  void setHashtagFilter(String? hashtag) {
    _selectedHashtag = hashtag;
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _currentFilter = FeedFilter.all;
    _searchQuery = null;
    _selectedHashtag = null;
    _applyFilters();
  }

  /// Create a new post
  Future<bool> createPost({
    required String text,
    String? imageUrl,
  }) async {
    final user = _authProvider.currentUser;
    if (user == null) {
      setError('Please login to create a post');
      return false;
    }

    final postId = const Uuid().v4();
    final post = PostModel(
      postId: postId,
      userId: user.uid,
      username: user.name,
      userProfileImage: user.profileImage,
      text: text,
      imageUrl: imageUrl ?? '',
    );

    await executeOperation(() => _postService.createPost(post));
    await _loadTrendingHashtags(); // Refresh trending hashtags
    return !isLoading && errorMessage.isEmpty;
  }

  /// Edit a post
  Future<bool> editPost(String postId, String newText,
      {String? newImageUrl}) async {
    await executeOperation(
        () => _postService.editPost(postId, newText, newImageUrl: newImageUrl));
    await _loadTrendingHashtags(); // Refresh trending hashtags
    return !isLoading && errorMessage.isEmpty;
  }

  /// Toggle like on a post
  Future<void> toggleLike(PostModel post) async {
    final user = _authProvider.currentUser;
    if (user == null) return;

    if (post.isLikedBy(user.uid)) {
      await executeOperation(
          () => _postService.unlikePost(post.postId, user.uid));
    } else {
      await executeOperation(
          () => _postService.likePost(post.postId, user.uid));
    }
  }

  /// Add or change reaction
  Future<void> addReaction(PostModel post, String reactionType) async {
    final user = _authProvider.currentUser;
    if (user == null) return;

    final currentReaction = post.getUserReaction(user.uid);

    if (currentReaction == null) {
      // Add new reaction
      await executeOperation(
          () => _postService.addReaction(post.postId, user.uid, reactionType));
    } else if (currentReaction == reactionType) {
      // Remove reaction if clicking same one
      await executeOperation(() =>
          _postService.removeReaction(post.postId, user.uid, reactionType));
    } else {
      // Change reaction
      await executeOperation(() => _postService.changeReaction(
            post.postId,
            user.uid,
            currentReaction,
            reactionType,
          ));
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

  /// Report a post
  Future<bool> reportPost(PostModel post, ReportReason reason,
      {String details = ''}) async {
    final user = _authProvider.currentUser;
    if (user == null) {
      setError('Please login to report posts');
      return false;
    }

    final reportId = const Uuid().v4();
    final report = ReportModel(
      reportId: reportId,
      postId: post.postId,
      reporterId: user.uid,
      reporterName: user.name,
      reason: reason,
      details: details,
    );

    await executeOperation(() => _postService.reportPost(report));
    return !isLoading && errorMessage.isEmpty;
  }

  /// Delete a post
  Future<bool> deletePost(String postId) async {
    await executeOperation(() => _postService.deletePost(postId));
    await _loadTrendingHashtags(); // Refresh trending hashtags
    return !isLoading && errorMessage.isEmpty;
  }

  /// Refresh trending hashtags
  Future<void> refreshTrendingHashtags() async {
    await _loadTrendingHashtags();
  }
}

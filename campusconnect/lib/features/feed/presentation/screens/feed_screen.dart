import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart' as custom;
import '../../../../shared/constants/constants.dart';
import '../widgets/post_card.dart';
import '../widgets/filter_chips_widget.dart';
import '../widgets/trending_hashtags.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/share_dialog.dart';
import '../widgets/report_dialog.dart';

/// Feed Screen
/// Displays feed of posts from all users with gradient app bar

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize notification listener when feed loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context
            .read<NotificationProvider>()
            .initNotificationListener(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() async {
    // Trigger a refresh by re-initializing the feed listener
    await Future.delayed(const Duration(milliseconds: 500));
    final feedProvider = context.read<FeedProvider>();
    await feedProvider.refreshTrendingHashtags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusConnect'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/bookmarks');
            },
            tooltip: 'Bookmarks',
          ),
          // Notification bell with unread badge
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, _) => Stack(
              children: [
                IconButton(
                  icon: Icon(
                    notifProvider.hasUnread
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                  tooltip: 'Notifications',
                ),
                if (notifProvider.hasUnread)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        notifProvider.unreadCount > 9
                            ? '9+'
                            : '${notifProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
            return const LoadingWidget();
          }

          if (feedProvider.errorMessage.isNotEmpty &&
              feedProvider.posts.isEmpty) {
            return custom.ErrorDisplay(
              message: feedProvider.errorMessage,
              onRetry: _refreshFeed,
            );
          }

          return Column(
            children: [
              // Search bar with premium styling
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search posts, users, or hashtags...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: feedProvider.searchQuery != null
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                feedProvider.setSearchQuery(null);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    onChanged: (value) {
                      feedProvider.setSearchQuery(value.isEmpty ? null : value);
                    },
                  ),
                ),
              ),

              // Filter chips
              FilterChipsWidget(
                currentFilter: feedProvider.currentFilter,
                onFilterChanged: (filter) => feedProvider.setFilter(filter),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Trending hashtags
              if (feedProvider.selectedHashtag == null)
                TrendingHashtags(
                  hashtags: feedProvider.trendingHashtags,
                  onHashtagTap: (hashtag) {
                    feedProvider.setHashtagFilter(hashtag);
                  },
                ),

              // Active hashtag filter chip
              if (feedProvider.selectedHashtag != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Chip(
                    label: Text('Filtered by: ${feedProvider.selectedHashtag}'),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      feedProvider.setHashtagFilter(null);
                    },
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  ),
                ),

              // Posts list
              Expanded(
                child: feedProvider.posts.isEmpty
                    ? custom.EmptyState(
                        message: feedProvider.searchQuery != null ||
                                feedProvider.selectedHashtag != null
                            ? 'No posts found'
                            : 'No posts yet',
                        icon: Icons.post_add,
                        actionText: 'Create Post',
                        onAction: () {
                          Navigator.pushNamed(context, '/create-post');
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshFeed,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: feedProvider.posts.length,
                          itemBuilder: (context, index) {
                            final post = feedProvider.posts[index];
                            return PostCard(
                              post: post,
                              onReactionTap: () {
                                ReactionPicker.show(
                                  context,
                                  onReactionSelected: (reactionType) {
                                    feedProvider.addReaction(
                                        post, reactionType);
                                  },
                                  currentReaction: post.getUserReaction(
                                    context
                                            .read<AuthProvider>()
                                            .currentUser
                                            ?.uid ??
                                        '',
                                  ),
                                );
                              },
                              onComment: () {
                                Navigator.pushNamed(
                                  context,
                                  '/post-detail',
                                  arguments: post,
                                );
                              },
                              onBookmark: () {
                                feedProvider.toggleBookmark(post);
                              },
                              onShare: () {
                                ShareDialog.show(
                                  context,
                                  postId: post.postId,
                                  postText: post.text,
                                );
                              },
                              onDelete: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Post'),
                                    content: const Text(
                                      'Are you sure you want to delete this post?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await feedProvider.deletePost(post.postId);
                                }
                              },
                              onEdit: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit-post',
                                  arguments: post,
                                );
                              },
                              onReport: () {
                                ReportDialog.show(
                                  context,
                                  onReport: (reason, details) async {
                                    final success =
                                        await feedProvider.reportPost(
                                      post,
                                      reason,
                                      details: details,
                                    );
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Report submitted successfully'),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                              onHashtagTap: (hashtag) {
                                feedProvider.setHashtagFilter(hashtag);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

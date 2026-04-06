import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/feed_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart' as custom;
import '../widgets/post_card.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/share_dialog.dart';

/// Bookmarks Screen
/// Displays user's bookmarked posts

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.isLoading &&
              bookmarkProvider.bookmarkedPosts.isEmpty) {
            return const LoadingWidget();
          }

          if (bookmarkProvider.errorMessage.isNotEmpty &&
              bookmarkProvider.bookmarkedPosts.isEmpty) {
            return custom.ErrorDisplay(
              message: bookmarkProvider.errorMessage,
            );
          }

          if (bookmarkProvider.bookmarkedPosts.isEmpty) {
            return custom.EmptyState(
              message: 'No saved posts yet',
              icon: Icons.bookmark_border,
              actionText: 'Explore Feed',
              onAction: () {
                Navigator.pop(context);
              },
            );
          }

          return ListView.builder(
            itemCount: bookmarkProvider.bookmarkedPosts.length,
            itemBuilder: (context, index) {
              final post = bookmarkProvider.bookmarkedPosts[index];
              final feedProvider = context.read<FeedProvider>();

              return PostCard(
                post: post,
                onReactionTap: () {
                  ReactionPicker.show(
                    context,
                    onReactionSelected: (reactionType) {
                      feedProvider.addReaction(post, reactionType);
                    },
                    currentReaction: post.getUserReaction(
                      context.read<AuthProvider>().currentUser?.uid ?? '',
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
                  bookmarkProvider.toggleBookmark(post);
                },
                onShare: () {
                  ShareDialog.show(
                    context,
                    postId: post.postId,
                    postText: post.text,
                  );
                },
                onHashtagTap: (hashtag) {
                  // Navigate back to feed with hashtag filter
                  Navigator.pop(context);
                  feedProvider.setHashtagFilter(hashtag);
                },
              );
            },
          );
        },
      ),
    );
  }
}

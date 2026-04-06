import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/post_model.dart';
import '../providers/comment_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_input.dart';
import '../widgets/reaction_picker.dart';
import '../widgets/share_dialog.dart';
import '../widgets/report_dialog.dart';
import '../providers/feed_provider.dart';

/// Post Detail Screen
/// Displays a single post with all its comments

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final feedProvider = context.read<FeedProvider>();

    return ChangeNotifierProvider(
      create: (_) => CommentProvider(authProvider, post.postId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post'),
        ),
        body: Column(
          children: [
            // Post card
            PostCard(
              post: post,
              onReactionTap: () {
                ReactionPicker.show(
                  context,
                  onReactionSelected: (reactionType) {
                    feedProvider.addReaction(post, reactionType);
                  },
                  currentReaction: post.getUserReaction(
                    authProvider.currentUser?.uid ?? '',
                  ),
                );
              },
              onComment: () {}, // Already on detail screen
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
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final success = await feedProvider.deletePost(post.postId);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post deleted'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
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
                    final success = await feedProvider.reportPost(
                      post,
                      reason,
                      details: details,
                    );
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted successfully'),
                        ),
                      );
                    }
                  },
                );
              },
              onHashtagTap: (hashtag) {
                Navigator.pop(context); // Go back to feed
                feedProvider.setHashtagFilter(hashtag);
              },
            ),

            const Divider(height: 1, thickness: 1),

            // Comments section
            Expanded(
              child: Consumer<CommentProvider>(
                builder: (context, commentProvider, child) {
                  if (commentProvider.isLoading &&
                      commentProvider.comments.isEmpty) {
                    return const LoadingWidget();
                  }

                  if (commentProvider.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No comments yet',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Be the first to comment',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: commentProvider.comments.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: AppSpacing.md + 32 + AppSpacing.sm,
                    ),
                    itemBuilder: (context, index) {
                      final comment = commentProvider.comments[index];
                      return CommentCard(
                        comment: comment,
                        onDelete: () {
                          commentProvider.deleteComment(comment.commentId);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Comment input
            Consumer<CommentProvider>(
              builder: (context, commentProvider, child) {
                return CommentInput(
                  onSubmit: (text) async {
                    final success = await commentProvider.addComment(text);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(commentProvider.errorMessage),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  isLoading: commentProvider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

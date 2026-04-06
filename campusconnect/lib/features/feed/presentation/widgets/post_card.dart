import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/reaction_model.dart';

/// Post Card Widget
/// Reusable widget to display a post with reactions, bookmark, comment, and share actions

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onReactionTap;
  final VoidCallback onComment;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReport;
  final Function(String)? onHashtagTap;

  const PostCard({
    super.key,
    required this.post,
    this.onReactionTap,
    required this.onComment,
    this.onBookmark,
    this.onShare,
    this.onDelete,
    this.onEdit,
    this.onReport,
    this.onHashtagTap,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  Widget _buildTextWithHashtags(String text) {
    final words = text.split(' ');
    final spans = <TextSpan>[];

    for (var word in words) {
      if (word.startsWith('#')) {
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          recognizer: onHashtagTap != null
              ? (TapGestureRecognizer()..onTap = () => onHashtagTap!(word))
              : null,
        ));
      } else {
        spans.add(TextSpan(text: '$word '));
      }
    }

    return RichText(
      text: TextSpan(
        style: AppTextStyles.body1,
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isBookmarked = post.isBookmarkedBy(currentUser?.uid ?? '');
    final isOwnPost = post.userId == currentUser?.uid;
    final userReaction = post.getUserReaction(currentUser?.uid ?? '');

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (User info)
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.userProfileImage.isNotEmpty
                  ? NetworkImage(post.userProfileImage)
                  : null,
              child: post.userProfileImage.isEmpty
                  ? Text(post.username[0].toUpperCase())
                  : null,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    post.username,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.isEdited) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const Text(
                    '• Edited',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              _formatTimestamp(post.timestamp),
              style: AppTextStyles.caption,
            ),
            trailing: isOwnPost
                ? IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onEdit != null)
                                ListTile(
                                  leading: const Icon(Icons.edit,
                                      color: AppColors.primary),
                                  title: const Text('Edit Post'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    onEdit!();
                                  },
                                ),
                              if (onDelete != null)
                                ListTile(
                                  leading: const Icon(Icons.delete,
                                      color: AppColors.error),
                                  title: const Text('Delete Post'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    onDelete!();
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : onReport != null
                    ? IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.flag,
                                        color: AppColors.error),
                                    title: const Text('Report Post'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      onReport!();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : null,
          ),

          // Post text
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: _buildTextWithHashtags(post.text),
            ),

          // Post image
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),

          // Engagement stats
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Reactions display
                if (post.totalReactions > 0) ...[
                  Row(
                    children: [
                      ...post.reactions.entries.take(3).map((entry) {
                        final reactionType = ReactionType.fromString(entry.key);
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Text(
                            reactionType.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '${post.totalReactions}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (post.likesCount > 0 && post.totalReactions == 0) ...[
                  const Icon(Icons.favorite, size: 16, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likesCount}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                const Spacer(),
                Text(
                  '${post.commentsCount} comments',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Reaction button
              TextButton.icon(
                onPressed: onReactionTap,
                icon: userReaction != null
                    ? Text(
                        ReactionType.fromString(userReaction).emoji,
                        style: const TextStyle(fontSize: 18),
                      )
                    : const Icon(Icons.sentiment_satisfied_alt_outlined),
                label: Text(
                  userReaction != null
                      ? ReactionType.fromString(userReaction).label
                      : 'React',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: userReaction != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: onComment,
                icon: const Icon(Icons.comment_outlined),
                label: const Text('Comment'),
              ),
              if (onBookmark != null)
                TextButton.icon(
                  onPressed: onBookmark,
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.primary : null,
                  ),
                  label: const Text('Save'),
                  style: TextButton.styleFrom(
                    foregroundColor: isBookmarked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              if (onShare != null)
                TextButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

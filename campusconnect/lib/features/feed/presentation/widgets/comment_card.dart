import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/comment_model.dart';

/// Comment Card Widget
/// Displays a single comment with user info and delete option

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isOwnComment = comment.userId == currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.userProfileImage.isNotEmpty
                ? NetworkImage(comment.userProfileImage)
                : null,
            child: comment.userProfileImage.isEmpty
                ? Text(
                    comment.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and timestamp
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),

                // Comment text
                Text(
                  comment.text,
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),

          // Delete button for own comments
          if (isOwnComment && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.textSecondary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Comment'),
                    content: const Text(
                        'Are you sure you want to delete this comment?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete!();
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

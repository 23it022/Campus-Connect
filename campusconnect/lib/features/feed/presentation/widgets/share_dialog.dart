import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/constants.dart';

/// Share Dialog Widget
/// Shows options for sharing a post

class ShareDialog extends StatelessWidget {
  final String postId;
  final String postText;

  const ShareDialog({
    super.key,
    required this.postId,
    required this.postText,
  });

  void _copyLink(BuildContext context) {
    final link = 'campusconnect://post/$postId';
    Clipboard.setData(ClipboardData(text: link));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  void _shareExternal(BuildContext context) {
    // TODO: Implement external sharing using share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Share Post',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Post preview
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                postText.length > 100
                    ? '${postText.substring(0, 100)}...'
                    : postText,
                style: AppTextStyles.body2,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Share options
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('Copy Link'),
              subtitle: const Text('Share link to this post'),
              onTap: () => _copyLink(context),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.primary),
              title: const Text('Share to...'),
              subtitle: const Text('Share via other apps'),
              onTap: () => _shareExternal(context),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.md),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show share dialog
  static void show(
    BuildContext context, {
    required String postId,
    required String postText,
  }) {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        postId: postId,
        postText: postText,
      ),
    );
  }
}

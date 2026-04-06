import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../../domain/models/post_model.dart';
import '../../../../shared/constants/constants.dart';

/// Edit Post Screen
/// Allows users to edit their existing posts

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _savePost(PostModel post) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final feedProvider = context.read<FeedProvider>();
    final success = await feedProvider.editPost(
      post.postId,
      _textController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedProvider.errorMessage.isNotEmpty
              ? feedProvider.errorMessage
              : 'Failed to update post'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get post from arguments
    final post = ModalRoute.of(context)!.settings.arguments as PostModel;

    // Set initial text if controller is empty
    if (_textController.text.isEmpty) {
      _textController.text = post.text;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _savePost(post),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your post will be marked as edited',
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Text input
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'What\'s on your mind?',
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              maxLength: AppValidation.maxPostLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Post text cannot be empty';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: AppSpacing.md),

            // Hashtag hint
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tag, color: AppColors.primary, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Use #hashtags to make your post discoverable',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Show original post info
            Row(
              children: [
                const Icon(Icons.history,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Originally posted on ${_formatDate(post.timestamp)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

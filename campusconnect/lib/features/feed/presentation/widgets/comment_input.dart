import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';

/// Comment Input Widget
/// Text field for adding new comments

class CommentInput extends StatefulWidget {
  final Function(String) onSubmit;
  final bool isLoading;

  const CommentInput({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSubmit(text);
      _controller.clear();
      setState(() => _hasText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.greyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() => _hasText = value.trim().isNotEmpty);
                },
                onSubmitted: (_) => _handleSubmit(),
                enabled: !widget.isLoading,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Send button
            widget.isLoading
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _hasText ? _handleSubmit : null,
                    icon: Icon(
                      Icons.send,
                      color: _hasText ? AppColors.primary : AppColors.textHint,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          _hasText ? AppColors.primary.withOpacity(0.1) : null,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';

/// Message Input Widget
/// Text field for composing and sending messages

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.isEnabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Send button
            Container(
              decoration: BoxDecoration(
                gradient: _hasText && widget.isEnabled
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _hasText && widget.isEnabled
                    ? null
                    : AppColors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: _hasText && widget.isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: AppColors.white,
                onPressed: _hasText && widget.isEnabled ? _sendMessage : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

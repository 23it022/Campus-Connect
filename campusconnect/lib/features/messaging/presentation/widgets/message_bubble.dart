import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';
import '../../domain/models/message_model.dart';

/// Message Bubble Widget
/// Displays a single message with different styles for sent/received

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: isSentByCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByCurrentUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                gradient: isSentByCurrentUser
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSentByCurrentUser ? null : AppColors.greyLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusMd),
                  topRight: const Radius.circular(AppSpacing.radiusMd),
                  bottomLeft: isSentByCurrentUser
                      ? const Radius.circular(AppSpacing.radiusMd)
                      : const Radius.circular(4),
                  bottomRight: isSentByCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(AppSpacing.radiusMd),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSentByCurrentUser
                            ? AppColors.primary
                            : AppColors.grey)
                        .withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSentByCurrentUser
                          ? AppColors.white
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timestamp and read status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSentByCurrentUser
                              ? AppColors.white.withOpacity(0.8)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isSentByCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? AppColors.info
                              : AppColors.white.withOpacity(0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSentByCurrentUser) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

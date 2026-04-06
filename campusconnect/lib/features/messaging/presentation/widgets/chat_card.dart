import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../shared/constants/constants.dart';
import '../../domain/models/chat_model.dart';

/// Chat Card Widget
/// Displays a conversation card in the chat list
/// Shows user info, last message, timestamp, and unread badge

class ChatCard extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatCard({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserName = chat.getOtherParticipantName(currentUserId);
    final otherUserRole = chat.getOtherParticipantRole(currentUserId);
    final otherUserImage = chat.getOtherParticipantImage(currentUserId);
    final unreadCount = chat.getUnreadCountForUser(currentUserId);
    final hasUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.primaryLight.withOpacity(0.05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: AppColors.greyLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: otherUserImage.isNotEmpty
                      ? NetworkImage(otherUserImage)
                      : null,
                  child: otherUserImage.isEmpty
                      ? Text(
                          otherUserName.isNotEmpty
                              ? otherUserName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        )
                      : null,
                ),
                // Online indicator (optional - can be enhanced later)
                // Positioned(
                //   right: 0,
                //   bottom: 0,
                //   child: Container(
                //     width: 14,
                //     height: 14,
                //     decoration: BoxDecoration(
                //       color: AppColors.success,
                //       shape: BoxShape.circle,
                //       border: Border.all(color: AppColors.white, width: 2),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight:
                                hasUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimestamp(chat.lastMessageTime),
                        style: AppTextStyles.caption.copyWith(
                          color: hasUnread
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (otherUserRole.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getRoleColor(otherUserRole).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            otherUserRole.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: _getRoleColor(otherUserRole),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          chat.lastMessage.isEmpty
                              ? 'Start a conversation'
                              : chat.lastMessage,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.normal,
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusRound),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 24) {
      return timeago.format(timestamp, locale: 'en_short');
    } else if (difference.inDays < 7) {
      return timeago.format(timestamp, locale: 'en_short');
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'teacher':
        return AppColors.info;
      case 'student':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }
}

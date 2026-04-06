import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../domain/models/chat_model.dart';
import '../providers/messaging_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Chat Detail Screen
/// Displays messages in a one-on-one conversation
/// Supports real-time message updates and sending new messages

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;
  final String currentUserId;

  const ChatDetailScreen({
    super.key,
    required this.chat,
    required this.currentUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markAsRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    final messagingProvider = context.read<MessagingProvider>();
    messagingProvider.loadChatMessages(widget.chat.chatId);
  }

  void _markAsRead() {
    final messagingProvider = context.read<MessagingProvider>();
    messagingProvider.markChatAsRead(widget.chat.chatId, widget.currentUserId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    final messagingProvider = context.read<MessagingProvider>();
    final currentUser =
        widget.chat.participantNames[widget.currentUserId] ?? 'Unknown';

    final success = await messagingProvider.sendMessage(
      chatId: widget.chat.chatId,
      senderId: widget.currentUserId,
      senderName: currentUser,
      text: text,
    );

    setState(() {
      _isSending = false;
    });

    if (success) {
      _scrollToBottom();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagingProvider = context.watch<MessagingProvider>();
    final messages = messagingProvider.currentChatMessages;
    final otherUserName =
        widget.chat.getOtherParticipantName(widget.currentUserId);
    final otherUserImage =
        widget.chat.getOtherParticipantImage(widget.currentUserId);
    final otherUserRole =
        widget.chat.getOtherParticipantRole(widget.currentUserId);

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.white.withOpacity(0.3),
              backgroundImage: otherUserImage.isNotEmpty
                  ? NetworkImage(otherUserImage)
                  : null,
              child: otherUserImage.isEmpty
                  ? Text(
                      otherUserName.isNotEmpty
                          ? otherUserName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (otherUserRole.isNotEmpty)
                    Text(
                      otherUserRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSentByCurrentUser =
                          message.senderId == widget.currentUserId;

                      return MessageBubble(
                        message: message,
                        isSentByCurrentUser: isSentByCurrentUser,
                      );
                    },
                  ),
          ),

          // Message input
          MessageInput(
            onSendMessage: _sendMessage,
            isEnabled: !_isSending,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Say hi to ${widget.chat.getOtherParticipantName(widget.currentUserId)}',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Start the conversation',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/messaging_provider.dart';
import '../widgets/chat_card.dart';
import 'chat_detail_screen.dart';
import 'new_chat_screen.dart';

/// Chat List Screen
/// Displays all conversations for the current user
/// Supports real-time updates and navigation to chat details

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    final authProvider = context.read<AuthProvider>();
    final messagingProvider = context.read<MessagingProvider>();

    if (authProvider.currentUser != null) {
      messagingProvider.loadUserChats(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final messagingProvider = context.watch<MessagingProvider>();

    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: const Center(
          child: Text('Please log in to view messages'),
        ),
      );
    }

    final currentUserId = authProvider.currentUser!.uid;
    final chats = messagingProvider.chats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
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
        actions: [
          // Unread count badge
          if (messagingProvider.totalUnreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Text(
                  messagingProvider.totalUnreadCount > 99
                      ? '99+'
                      : messagingProvider.totalUnreadCount.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: chats.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                _loadChats();
              },
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatCard(
                    chat: chat,
                    currentUserId: currentUserId,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chat: chat,
                            currentUserId: currentUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewChatScreen(
                currentUser: authProvider.currentUser!,
              ),
            ),
          );
        },
        label: const Text('New Chat'),
        icon: const Icon(Icons.chat_bubble_outline),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No conversations yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start a new chat to connect with others',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewChatScreen(
                    currentUser: authProvider.currentUser!,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Start New Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

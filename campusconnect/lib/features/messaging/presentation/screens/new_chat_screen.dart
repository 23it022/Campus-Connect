import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/domain/models/user_model.dart';
import '../providers/messaging_provider.dart';
import 'chat_detail_screen.dart';

/// New Chat Screen
/// Allows users to search and select other users to start a conversation

class NewChatScreen extends StatefulWidget {
  final UserModel currentUser;

  const NewChatScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final messagingProvider = context.read<MessagingProvider>();
    final users = await messagingProvider.getAllUsers(widget.currentUser.uid);

    setState(() {
      _allUsers = users;
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.department.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _startChat(UserModel otherUser) async {
    final messagingProvider = context.read<MessagingProvider>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final chat = await messagingProvider.createOrGetChat(
      currentUserId: widget.currentUser.uid,
      otherUserId: otherUser.uid,
      currentUser: widget.currentUser,
      otherUser: otherUser,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (chat != null && mounted) {
      // Navigate to chat detail screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            chat: chat,
            currentUserId: widget.currentUser.uid,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create chat. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
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
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
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
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return InkWell(
      onTap: () => _startChat(user),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
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
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user.profileImage.isNotEmpty
                  ? NetworkImage(user.profileImage)
                  : null,
              child: user.profileImage.isEmpty
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user.department,
                          style: AppTextStyles.body2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchController.text.isEmpty
                ? 'No users found'
                : 'No results for "${_searchController.text}"',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Try a different search term',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
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

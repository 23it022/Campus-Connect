import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../widgets/group_card.dart';

/// Groups Screen
/// Displays all groups and user's joined groups with premium styling

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final groupProvider = context.read<GroupProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

    await groupProvider.refreshGroups(userId);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Groups'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'All Groups'),
            Tab(text: 'My Groups'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar with premium styling
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.subtle,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllGroupsTab(currentUserId),
                _buildMyGroupsTab(currentUserId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.button,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: AppShadows.elevated,
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/groups/create');
          },
          label: const Text('Create Group'),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAllGroupsTab(String? currentUserId) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, _) {
        if (groupProvider.isLoading) {
          return const LoadingWidget();
        }

        if (groupProvider.errorMessage.isNotEmpty) {
          return _buildErrorState(groupProvider.errorMessage);
        }

        final groups = _searchQuery.isEmpty
            ? groupProvider.allGroups
            : groupProvider.allGroups
                .where((group) =>
                    group.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    group.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        if (groups.isEmpty) {
          return _buildEmptyState(
            _searchQuery.isEmpty ? 'No groups available' : 'No groups found',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadGroups,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final isMember =
                  currentUserId != null && group.isMember(currentUserId);

              return GroupCard(
                group: group,
                currentUserId: currentUserId,
                onTap: () {
                  Navigator.pushNamed(context, '/groups/${group.groupId}');
                },
                onJoinLeave: () async {
                  if (isMember) {
                    await groupProvider.leaveGroup(
                        group.groupId, currentUserId!);
                  } else {
                    await groupProvider.joinGroup(
                        group.groupId, currentUserId!);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyGroupsTab(String? currentUserId) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, _) {
        if (groupProvider.isLoading) {
          return const LoadingWidget();
        }

        final groups = _searchQuery.isEmpty
            ? groupProvider.myGroups
            : groupProvider.myGroups
                .where((group) =>
                    group.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    group.description
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();

        if (groups.isEmpty) {
          return _buildEmptyState(
            _searchQuery.isEmpty
                ? 'You haven\'t joined any groups yet'
                : 'No groups found',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadGroups,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];

              return GroupCard(
                group: group,
                currentUserId: currentUserId,
                onTap: () {
                  Navigator.pushNamed(context, '/groups/${group.groupId}');
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_off_rounded,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            style: AppTextStyles.body1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadGroups,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';
import '../../domain/models/group_model.dart';

/// Group Card Widget
/// Displays a group in a card format with join button

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onJoinLeave;

  const GroupCard({
    super.key,
    required this.group,
    this.currentUserId,
    required this.onTap,
    this.onJoinLeave,
  });

  @override
  Widget build(BuildContext context) {
    final isMember = currentUserId != null && group.isMember(currentUserId!);
    final isAdmin = currentUserId != null && group.isAdmin(currentUserId!);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Group Avatar/Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: group.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            child: Image.network(
                              group.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultIcon(),
                            ),
                          )
                        : _buildDefaultIcon(),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Group Name and Count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: AppTextStyles.h3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (group.isPrivate)
                              const Icon(
                                Icons.lock,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs / 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs / 2),
                            Text(
                              '${group.membersCount} ${group.membersCount == 1 ? 'member' : 'members'}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(group.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      group.category,
                      style: TextStyle(
                        color: _getCategoryColor(group.category),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Description
              Text(
                group.description,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Join/Joined Button
              if (onJoinLeave != null && !isAdmin)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onJoinLeave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isMember ? AppColors.greyLight : AppColors.primary,
                      foregroundColor:
                          isMember ? AppColors.textPrimary : AppColors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    icon: Icon(
                      isMember ? Icons.check_circle : Icons.add_circle,
                      size: 18,
                    ),
                    label: Text(isMember ? 'Joined' : 'Join Group'),
                  ),
                ),

              if (isAdmin)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.white,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Admin',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return const Icon(
      Icons.group,
      color: AppColors.white,
      size: 32,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return const Color(0xFF2196F3);
      case 'Sports':
        return const Color(0xFF4CAF50);
      case 'Cultural':
        return const Color(0xFF9C27B0);
      case 'Technology':
        return const Color(0xFFFF9800);
      case 'Social':
        return const Color(0xFFE91E63);
      case 'General':
      default:
        return AppColors.textSecondary;
    }
  }
}

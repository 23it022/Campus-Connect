import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile Screen
/// Displays user profile information with premium UI
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with Gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile picture with shadow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage: user.profileImage.isNotEmpty
                                ? NetworkImage(user.profileImage)
                                : null,
                            child: user.profileImage.isEmpty
                                ? Text(
                                    user.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 40),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Name with shadow
                      Text(
                        user.name,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        user.email,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Department and Year chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoChip(user.department),
                          const SizedBox(width: AppSpacing.sm),
                          _buildInfoChip(user.year),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Bio Section
                if (user.bio.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              user.bio,
                              style: AppTextStyles.body2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Menu Options with Premium Cards
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPremiumMenuCard(
                        context,
                        icon: Icons.star_rate,
                        title: 'Rate & Feedback',
                        subtitle: 'Share your experience with us',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/rate-feedback');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPremiumMenuCard(
                        context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get assistance when you need it',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/help-support');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPremiumMenuCard(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'Customize your preferences',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildPremiumMenuCard(
                        context,
                        icon: Icons.analytics_outlined,
                        title: 'Analytics Dashboard',
                        subtitle: 'View charts and insights',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B1FA2), Color(0xFF6A1B9A)],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/analytics');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action Buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      // Edit Profile Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to edit profile
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Logout Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Logout'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true && context.mounted) {
                            await context.read<AuthProvider>().signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }
                        },
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          side: const BorderSide(
                              color: AppColors.error, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPremiumMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

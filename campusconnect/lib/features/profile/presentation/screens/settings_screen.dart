import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';

/// Settings Screen
/// Comprehensive settings with preferences, notifications, privacy, and account management
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification Settings
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _eventReminders = true;
  bool _postLikesNotifications = true;
  bool _commentNotifications = true;
  bool _messageNotifications = true;

  // Privacy Settings
  bool _profilePublic = true;
  bool _showEmail = false;
  bool _showPhone = false;
  bool _allowTagging = true;
  bool _showOnlineStatus = true;

  // App Preferences
  bool _darkMode = false;
  String _language = 'English';
  String _fontSize = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6A1B9A),
                      Color(0xFF8E24AA),
                      Color(0xFFAB47BC),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Notifications Section
                _buildSectionHeader(
                  Icons.notifications_outlined,
                  'Notifications',
                  const Color(0xFF2196F3),
                ),
                _buildNotificationSettings(),

                const SizedBox(height: AppSpacing.xl),

                // Privacy Section
                _buildSectionHeader(
                  Icons.privacy_tip_outlined,
                  'Privacy',
                  const Color(0xFF4CAF50),
                ),
                _buildPrivacySettings(),

                const SizedBox(height: AppSpacing.xl),

                // Appearance Section
                _buildSectionHeader(
                  Icons.palette_outlined,
                  'Appearance',
                  const Color(0xFFFF9800),
                ),
                _buildAppearanceSettings(),

                const SizedBox(height: AppSpacing.xl),

                // Account Section
                _buildSectionHeader(
                  Icons.person_outline,
                  'Account',
                  const Color(0xFFF44336),
                ),
                _buildAccountSettings(),

                const SizedBox(height: AppSpacing.xl),

                // About Section
                _buildSectionHeader(
                  Icons.info_outline,
                  'About',
                  const Color(0xFF9C27B0),
                ),
                _buildAboutSection(),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingTile(
              'Push Notifications',
              'Receive push notifications on this device',
              _pushNotificationsEnabled,
              (value) => setState(() => _pushNotificationsEnabled = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Email Notifications',
              'Receive notifications via email',
              _emailNotificationsEnabled,
              (value) => setState(() => _emailNotificationsEnabled = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Event Reminders',
              'Get reminded about upcoming events',
              _eventReminders,
              (value) => setState(() => _eventReminders = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Post Reactions',
              'Notify when someone reacts to your posts',
              _postLikesNotifications,
              (value) => setState(() => _postLikesNotifications = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Comments',
              'Notify when someone comments on your posts',
              _commentNotifications,
              (value) => setState(() => _commentNotifications = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Messages',
              'Notify when you receive a new message',
              _messageNotifications,
              (value) => setState(() => _messageNotifications = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingTile(
              'Public Profile',
              'Allow others to view your profile',
              _profilePublic,
              (value) => setState(() => _profilePublic = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Show Email',
              'Display email address on profile',
              _showEmail,
              (value) => setState(() => _showEmail = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Show Phone',
              'Display phone number on profile',
              _showPhone,
              (value) => setState(() => _showPhone = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Allow Tagging',
              'Let others tag you in posts',
              _allowTagging,
              (value) => setState(() => _allowTagging = value),
            ),
            const Divider(height: 1),
            _buildSettingTile(
              'Online Status',
              'Show when you\'re online',
              _showOnlineStatus,
              (value) => setState(() => _showOnlineStatus = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingTile(
              'Dark Mode',
              'Use dark theme across the app',
              _darkMode,
              (value) {
                setState(() => _darkMode = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dark mode will be available in next update'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildSelectionTile(
              'Language',
              _language,
              Icons.language,
              () => _showLanguageDialog(),
            ),
            const Divider(height: 1),
            _buildSelectionTile(
              'Font Size',
              _fontSize,
              Icons.text_fields,
              () => _showFontSizeDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildActionTile(
              'Change Password',
              Icons.lock_outline,
              const Color(0xFF2196F3),
              () => _showChangePasswordDialog(),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Blocked Users',
              Icons.block,
              const Color(0xFFFF9800),
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No blocked users'),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Download My Data',
              Icons.download_outlined,
              const Color(0xFF4CAF50),
              () => _downloadUserData(),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Delete Account',
              Icons.delete_forever_outlined,
              const Color(0xFFF44336),
              () => _showDeleteAccountDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildInfoTile('App Version', '1.0.0'),
            const Divider(height: 1),
            _buildActionTile(
              'Terms of Service',
              Icons.description_outlined,
              const Color(0xFF2196F3),
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of Service'),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Privacy Policy',
              Icons.policy_outlined,
              const Color(0xFF2196F3),
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy'),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Licenses',
              Icons.article_outlined,
              const Color(0xFF2196F3),
              () {
                showLicensePage(
                  context: context,
                  applicationName: 'CampusConnect',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSelectionTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: title == 'Delete Account' ? color : null,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'English',
            'Spanish',
            'French',
            'German',
            'Hindi',
          ].map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                _saveSettings();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Small',
            'Medium',
            'Large',
          ].map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() => _fontSize = value!);
                Navigator.pop(context);
                _saveSettings();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Account deletion initiated. Please contact support.'),
                  backgroundColor: AppColors.error,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _downloadUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'Your data will be prepared and sent to your registered email address within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Save settings to SharedPreferences or Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

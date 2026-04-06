import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_model.dart';
import '../providers/teacher_provider.dart';
import '../widgets/stats_card.dart';
import 'subject_list_screen.dart';
import 'assignment_list_screen.dart';
import 'announcement_list_screen.dart';
import 'attendance_screen.dart';

/// Teacher Dashboard Screen
/// Main dashboard for teachers showing overview and quick actions
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      teacherProvider.loadSubjects(authProvider.currentUser!.uid);
      teacherProvider.loadAssignmentsByTeacher(authProvider.currentUser!.uid);
      teacherProvider.loadAnnouncements(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer2<TeacherProvider, AuthProvider>(
            builder: (context, teacherProvider, authProvider, child) {
              final user = authProvider.currentUser;

              if (user == null) {
                return const Center(child: Text('Please login'));
              }

              return RefreshIndicator(
                onRefresh: () async => _loadDashboardData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Header
                      _buildWelcomeHeader(user),
                      const SizedBox(height: 24),

                      // Stats Cards
                      _buildStatsCards(teacherProvider),
                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(context),
                      const SizedBox(height: 24),

                      // Recent Activity
                      _buildRecentActivity(teacherProvider),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: user.profileImage.isNotEmpty
                ? NetworkImage(user.profileImage)
                : null,
            child: user.profileImage.isEmpty
                ? const Icon(Icons.person, size: 32, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.designation.isNotEmpty)
                  Text(
                    user.designation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(TeacherProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Subjects',
            value: provider.totalSubjects.toString(),
            icon: Icons.book,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubjectListScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Assignments',
            value: provider.pendingAssignments.toString(),
            icon: Icons.assignment,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AssignmentListScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Announcements',
            value: provider.recentAnnouncements.toString(),
            icon: Icons.campaign,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnnouncementListScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Create Assignment',
                Icons.add_task,
                Colors.blue,
                () {
                  // Navigate to create assignment
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignmentListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Post Announcement',
                Icons.campaign,
                Colors.purple,
                () {
                  // Navigate to create announcement
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Mark Attendance',
                Icons.how_to_reg,
                Colors.green,
                () {
                  // Navigate to attendance
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Manage Subjects',
                Icons.book,
                Colors.orange,
                () {
                  // Navigate to subjects
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubjectListScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(TeacherProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Announcements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (provider.announcements.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No recent announcements',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...provider.announcements.take(3).map((announcement) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign,
                          color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          announcement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.message,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import '../widgets/announcement_card.dart';
import '../../domain/models/announcement_model.dart';
import 'create_announcement_screen.dart';

/// Announcement List Screen
/// Displays all announcements created by the teacher
class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      teacherProvider.loadAnnouncements(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        elevation: 0,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first announcement',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadAnnouncements(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.announcements.length,
              itemBuilder: (context, index) {
                final announcement = provider.announcements[index];
                return AnnouncementCard(
                  title: announcement.title,
                  message: announcement.message,
                  createdAt: announcement.createdAt,
                  imageUrl: announcement.imageUrl,
                  onTap: () {
                    // Show full announcement details
                    _showAnnouncementDetails(announcement);
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAnnouncementScreen(
                            announcement: announcement),
                      ),
                    );
                  },
                  onDelete: () => _deleteAnnouncement(announcement),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateAnnouncementScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Announcement'),
      ),
    );
  }

  void _showAnnouncementDetails(AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (announcement.imageUrl != null &&
                  announcement.imageUrl!.isNotEmpty) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(announcement.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                announcement.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Posted: ${_formatDate(announcement.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnnouncement(AnnouncementModel announcement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content:
            Text('Are you sure you want to delete "${announcement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      final success =
          await provider.deleteAnnouncement(announcement.announcementId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Announcement deleted successfully'
                : 'Failed to delete announcement'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

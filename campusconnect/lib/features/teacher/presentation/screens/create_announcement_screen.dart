import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import '../../domain/models/announcement_model.dart';

/// Create/Edit Announcement Screen
/// Form to create or edit an announcement
class CreateAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel? announcement;

  const CreateAnnouncementScreen({super.key, this.announcement});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  List<String> _selectedSubjects = [];

  bool get isEditing => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.announcement!.title;
      _messageController.text = widget.announcement!.message;
      _selectedSubjects = widget.announcement!.subjectIds;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Announcement title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Write your announcement message',
                      prefixIcon: Icon(Icons.message),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Subject Selection
                  const Text(
                    'Select Subjects',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (provider.subjects.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No subjects available. Create subjects first.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Checkbox(
                              value: _selectedSubjects.length ==
                                  provider.subjects.length,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedSubjects = provider.subjects
                                        .map((s) => s.subjectId)
                                        .toList();
                                  } else {
                                    _selectedSubjects = [];
                                  }
                                });
                              },
                            ),
                            title: const Text(
                              'Select All',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(height: 1),
                          ...provider.subjects.map((subject) {
                            final isSelected =
                                _selectedSubjects.contains(subject.subjectId);
                            return CheckboxListTile(
                              value: isSelected,
                              title: Text(subject.subjectName),
                              subtitle: Text(subject.subjectCode),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedSubjects.add(subject.subjectId);
                                  } else {
                                    _selectedSubjects.remove(subject.subjectId);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  if (_selectedSubjects.isEmpty &&
                      provider.subjects.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Please select at least one subject',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Image Upload Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Image (Optional)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement image picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Image upload coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Upload Image'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveAnnouncement,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing
                            ? 'Update Announcement'
                            : 'Post Announcement'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final announcement = AnnouncementModel(
      announcementId: widget.announcement?.announcementId ?? '',
      teacherId: authProvider.currentUser!.uid,
      subjectIds: _selectedSubjects,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      imageUrl: widget.announcement?.imageUrl ?? '',
      fileUrl: widget.announcement?.fileUrl ?? '',
      createdAt: widget.announcement?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await teacherProvider.updateAnnouncement(announcement);
    } else {
      success = await teacherProvider.createAnnouncement(announcement);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Announcement updated successfully'
                : 'Announcement posted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                teacherProvider.errorMessage ?? 'Failed to save announcement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import '../widgets/subject_card.dart';
import '../../domain/models/subject_model.dart';
import 'create_subject_screen.dart';

/// Subject List Screen
/// Displays all subjects taught by the teacher
class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  void _loadSubjects() {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      teacherProvider.loadSubjects(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
        elevation: 0,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadSubjects(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: provider.subjects.length,
              itemBuilder: (context, index) {
                final subject = provider.subjects[index];
                return SubjectCard(
                  subjectName: subject.subjectName,
                  subjectCode: subject.subjectCode,
                  semester: subject.semester,
                  studentCount: subject.studentCount,
                  onTap: () {
                    // Navigate to subject detail
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateSubjectScreen(subject: subject),
                      ),
                    );
                  },
                  onDelete: () => _deleteSubject(subject),
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
              builder: (_) => const CreateSubjectScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }

  Future<void> _deleteSubject(SubjectModel subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content:
            Text('Are you sure you want to delete ${subject.subjectName}?'),
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
      final success = await provider.deleteSubject(subject.subjectId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Subject deleted successfully'
                : 'Failed to delete subject'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

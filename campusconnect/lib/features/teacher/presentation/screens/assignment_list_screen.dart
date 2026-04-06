import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import '../widgets/assignment_card.dart';
import '../../domain/models/assignment_model.dart';
import 'create_assignment_screen.dart';
import 'assignment_submissions_screen.dart';

/// Assignment List Screen
/// Displays all assignments created by the teacher
class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  void _loadAssignments() {
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      teacherProvider.loadAssignmentsByTeacher(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        elevation: 0,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No assignments yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first assignment',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadAssignments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.assignments.length,
              itemBuilder: (context, index) {
                final assignment = provider.assignments[index];
                return AssignmentCard(
                  title: assignment.title,
                  description: assignment.description,
                  dueDate: assignment.dueDate,
                  maxMarks: assignment.maxMarks,
                  submissionCount: 0, // TODO: Get from service
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignmentSubmissionsScreen(
                          assignment: assignment,
                        ),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateAssignmentScreen(assignment: assignment),
                      ),
                    );
                  },
                  onDelete: () => _deleteAssignment(assignment),
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
              builder: (_) => const CreateAssignmentScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Assignment'),
      ),
    );
  }

  Future<void> _deleteAssignment(AssignmentModel assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
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
      final success = await provider.deleteAssignment(assignment.assignmentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Assignment deleted successfully'
                : 'Failed to delete assignment'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

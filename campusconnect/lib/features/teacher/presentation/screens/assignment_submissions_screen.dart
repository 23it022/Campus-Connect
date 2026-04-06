import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teacher_provider.dart';
import '../../domain/models/assignment_model.dart';
import 'grade_submission_screen.dart';

/// Assignment Submissions Screen
/// Displays all submissions for a specific assignment
class AssignmentSubmissionsScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentSubmissionsScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<AssignmentSubmissionsScreen> createState() =>
      _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState
    extends State<AssignmentSubmissionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  void _loadSubmissions() {
    final provider = Provider.of<TeacherProvider>(context, listen: false);
    provider.loadSubmissions(widget.assignment.assignmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submissions'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Assignment Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.assignment.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDate(widget.assignment.dueDate)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.grade, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      'Max: ${widget.assignment.maxMarks} marks',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Submissions List
          Expanded(
            child: Consumer<TeacherProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.submissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No submissions yet',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadSubmissions(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.submissions.length,
                    itemBuilder: (context, index) {
                      final submission = provider.submissions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: submission.status == 'graded'
                                ? Colors.green
                                : Colors.orange,
                            child: Icon(
                              submission.status == 'graded'
                                  ? Icons.check
                                  : Icons.pending,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Student ID: ${submission.studentId}', // TODO: Get student name
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Submitted: ${_formatDate(submission.submittedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (submission.status == 'graded') ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Marks: ${submission.marks}/${widget.assignment.maxMarks}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: submission.status == 'graded'
                              ? Icon(Icons.visibility,
                                  color: Theme.of(context).primaryColor)
                              : Icon(Icons.rate_review, color: Colors.orange),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GradeSubmissionScreen(
                                  assignment: widget.assignment,
                                  submission: submission,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teacher_provider.dart';
import '../../domain/models/assignment_model.dart';
import '../../domain/models/assignment_submission_model.dart';

/// Grade Submission Screen
/// Interface for teachers to grade student submissions
class GradeSubmissionScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final AssignmentSubmissionModel submission;

  const GradeSubmissionScreen({
    super.key,
    required this.assignment,
    required this.submission,
  });

  @override
  State<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends State<GradeSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marksController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.submission.marks != null) {
      _marksController.text = widget.submission.marks.toString();
    }
    if (widget.submission.feedback != null) {
      _feedbackController.text = widget.submission.feedback!;
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGraded = widget.submission.status == 'graded';

    return Scaffold(
      appBar: AppBar(
        title: Text(isGraded ? 'View Grading' : 'Grade Submission'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assignment.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maximum Marks: ${widget.assignment.maxMarks}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Student Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Student Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Student ID: ${widget.submission.studentId}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted: ${_formatDateTime(widget.submission.submittedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submitted File Section
            if (widget.submission.fileUrl != null) ...[
              const Text(
                'Submitted File',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.submission.fileName ?? 'submission.pdf',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click to view/download',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // TODO: Implement file download
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File download coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Grading Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grading',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _marksController,
                    decoration: InputDecoration(
                      labelText: 'Marks Obtained',
                      hintText: 'Enter marks (0-${widget.assignment.maxMarks})',
                      prefixIcon: const Icon(Icons.grade),
                      suffixText: '/ ${widget.assignment.maxMarks}',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: isGraded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter marks';
                      }
                      final marks = int.tryParse(value);
                      if (marks == null) {
                        return 'Please enter a valid number';
                      }
                      if (marks < 0 || marks > widget.assignment.maxMarks) {
                        return 'Marks must be between 0 and ${widget.assignment.maxMarks}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      labelText: 'Feedback',
                      hintText: 'Provide feedback to the student',
                      prefixIcon: Icon(Icons.comment),
                    ),
                    maxLines: 5,
                    readOnly: isGraded,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  if (!isGraded)
                    Consumer<TeacherProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _submitGrade,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Submit Grade'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitGrade() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<TeacherProvider>(context, listen: false);

    final success = await provider.gradeSubmission(
      widget.submission.submissionId,
      int.parse(_marksController.text.trim()),
      _feedbackController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission graded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(provider.errorMessage ?? 'Failed to grade submission'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

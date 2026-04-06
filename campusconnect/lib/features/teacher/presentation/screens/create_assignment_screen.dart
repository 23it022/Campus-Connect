import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import '../../domain/models/assignment_model.dart';

/// Create/Edit Assignment Screen
/// Form to create or edit an assignment
class CreateAssignmentScreen extends StatefulWidget {
  final AssignmentModel? assignment;

  const CreateAssignmentScreen({super.key, this.assignment});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMarksController = TextEditingController();
  DateTime? _selectedDueDate;
  String? _selectedSubjectId;

  bool get isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.assignment!.title;
      _descriptionController.text = widget.assignment!.description;
      _maxMarksController.text = widget.assignment!.maxMarks.toString();
      _selectedDueDate = widget.assignment!.dueDate;
      _selectedSubjectId = widget.assignment!.subjectId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assignment' : 'Create Assignment'),
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
                  // Subject Selection
                  DropdownButtonFormField<String>(
                    value: _selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'Select a subject',
                      prefixIcon: Icon(Icons.book),
                    ),
                    items: provider.subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject.subjectId,
                        child: Text(subject.subjectName),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subject';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedSubjectId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Title',
                      hintText: 'e.g., Week 5 Programming Task',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter assignment title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Assignment details and instructions',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Due Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(_selectedDueDate == null
                        ? 'Select Due Date'
                        : 'Due: ${_formatDate(_selectedDueDate!)}'),
                    subtitle: _selectedDueDate == null
                        ? const Text('Tap to select date and time')
                        : null,
                    trailing: _selectedDueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                          )
                        : null,
                    onTap: _selectDueDate,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedDueDate == null
                            ? Colors.red.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  if (_selectedDueDate == null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: Text(
                        'Due date is required',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Max Marks
                  TextFormField(
                    controller: _maxMarksController,
                    decoration: const InputDecoration(
                      labelText: 'Maximum Marks',
                      hintText: 'e.g., 100',
                      prefixIcon: Icon(Icons.grade),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter maximum marks';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // File Upload Section
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
                            const Icon(Icons.attach_file, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Attachment (Optional)',
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
                            // TODO: Implement file picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('File upload feature coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Reference File'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveAssignment,
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
                            ? 'Update Assignment'
                            : 'Create Assignment'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final assignment = AssignmentModel(
      assignmentId: widget.assignment?.assignmentId ?? '',
      subjectId: _selectedSubjectId!,
      teacherId: authProvider.currentUser!.uid,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate!,
      maxMarks: int.parse(_maxMarksController.text.trim()),
      fileUrl: widget.assignment?.fileUrl ?? '',
      fileName: widget.assignment?.fileName ?? '',
    );

    bool success;
    if (isEditing) {
      success = await teacherProvider.updateAssignment(assignment);
    } else {
      success = await teacherProvider.createAssignment(assignment);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Assignment updated successfully'
                : 'Assignment created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                teacherProvider.errorMessage ?? 'Failed to save assignment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

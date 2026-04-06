import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/teacher_provider.dart';
import '../../domain/models/subject_model.dart';

/// Create/Edit Subject Screen
/// Form to create or edit a subject
class CreateSubjectScreen extends StatefulWidget {
  final SubjectModel? subject;

  const CreateSubjectScreen({super.key, this.subject});

  @override
  State<CreateSubjectScreen> createState() => _CreateSubjectScreenState();
}

class _CreateSubjectScreenState extends State<CreateSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSemester = '1';

  bool get isEditing => widget.subject != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.subject!.subjectName;
      _codeController.text = widget.subject!.subjectCode;
      _descriptionController.text = widget.subject!.description;
      _selectedSemester = widget.subject!.semester;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Create Subject'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g., Mobile Application Development',
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code',
                  hintText: 'e.g., CS301',
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subject code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: List.generate(8, (index) => (index + 1).toString())
                    .map((sem) => DropdownMenuItem(
                          value: sem,
                          child: Text('Semester $sem'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSemester = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the subject',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Consumer<TeacherProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveSubject,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'Update Subject' : 'Create Subject'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teacherProvider =
        Provider.of<TeacherProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final subject = SubjectModel(
      subjectId: widget.subject?.subjectId ?? '',
      teacherId: authProvider.currentUser!.uid,
      subjectName: _nameController.text.trim(),
      subjectCode: _codeController.text.trim(),
      semester: _selectedSemester,
      description: _descriptionController.text.trim(),
      studentIds: widget.subject?.studentIds ?? [],
    );

    bool success;
    if (isEditing) {
      success = await teacherProvider.updateSubject(subject);
    } else {
      success = await teacherProvider.createSubject(subject);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Subject updated successfully'
                : 'Subject created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(teacherProvider.errorMessage ?? 'Failed to save subject'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

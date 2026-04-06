import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../../domain/models/group_model.dart';

/// Create Group Screen
/// Allows users to create new groups

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'General';
  bool _isPrivate = false;

  final List<String> _categories = [
    'General',
    'Academic',
    'Sports',
    'Cultural',
    'Technology',
    'Social',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final groupProvider = context.read<GroupProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final group = GroupModel(
      groupId: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      adminId: currentUser.uid,
      adminName: currentUser.name,
      category: _selectedCategory,
      isPrivate: _isPrivate,
    );

    final success = await groupProvider.createGroup(group);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(groupProvider.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group Name
              CustomTextField(
                label: 'Group Name',
                hint: 'Enter group name',
                controller: _nameController,
                prefixIcon: Icons.group,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter group name';
                  }
                  if (value.length < 3) {
                    return 'Group name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Enter group description',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter group description';
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Category Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Privacy Setting
              Card(
                child: SwitchListTile(
                  title: const Text('Private Group'),
                  subtitle: const Text('Only members can see group content'),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() => _isPrivate = value);
                  },
                  secondary: Icon(
                    _isPrivate ? Icons.lock : Icons.public,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              Consumer<GroupProvider>(
                builder: (context, groupProvider, _) {
                  return CustomButton(
                    text: 'Create Group',
                    onPressed: _handleSubmit,
                    isLoading: groupProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

/// Create Support Ticket Screen
/// Premium UI for creating support tickets
class CreateSupportTicketScreen extends StatefulWidget {
  const CreateSupportTicketScreen({super.key});

  @override
  State<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState extends State<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'Technical Issue';
  String _priority = 'medium';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Technical Issue',
    'Account',
    'Events',
    'General',
    'Other',
  ];

  final List<Map<String, dynamic>> _priorities = [
    {
      'value': 'low',
      'label': 'Low',
      'color': Color(0xFF4CAF50),
      'icon': Icons.flag_outlined
    },
    {
      'value': 'medium',
      'label': 'Medium',
      'color': Color(0xFFFF9800),
      'icon': Icons.flag
    },
    {
      'value': 'high',
      'label': 'High',
      'color': Color(0xFFF44336),
      'icon': Icons.flag
    },
  ];

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    final success = await profileProvider.createTicket(
      userId: user.uid,
      userName: user.name,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Support ticket created successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(profileProvider.errorMessage)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Create Support Ticket',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF42A5F5),
                      Color(0xFF1E88E5),
                      Color(0xFF1565C0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          hintText: 'Brief description of the issue',
                          prefixIcon: const Icon(Icons.subject),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a subject';
                          }
                          if (value.trim().length < 5) {
                            return 'Subject must be at least 5 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Category Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Priority Selection
                    const Text(
                      'Priority Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: _priorities.map((priority) {
                        final isSelected = _priority == priority['value'];
                        final color = priority['color'] as Color;

                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () {
                                setState(() =>
                                    _priority = priority['value'] as String);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            color,
                                            color.withOpacity(0.8)
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      priority['icon'] as IconData,
                                      color: isSelected ? Colors.white : color,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      priority['label'] as String,
                                      style: TextStyle(
                                        color:
                                            isSelected ? Colors.white : color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Description Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Provide details about your issue...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 100),
                            child: Icon(Icons.description),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe your issue';
                          }
                          if (value.trim().length < 20) {
                            return 'Description must be at least 20 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF42A5F5).withOpacity(0.1),
                            const Color(0xFF1E88E5).withOpacity(0.05),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: const Color(0xFF42A5F5).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF1E88E5),
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Our support team will review your ticket and respond as soon as possible. You can track the status in the Help & Support section.',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Submit Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF42A5F5).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Submit Ticket',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

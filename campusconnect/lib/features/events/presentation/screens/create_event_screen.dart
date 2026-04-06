import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/network/storage_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../../domain/models/event_model.dart';

/// Create/Edit Event Screen
/// Allows users to create new events or edit existing ones
class CreateEventScreen extends StatefulWidget {
  final String? eventId; // If null, create new event; if provided, edit mode

  const CreateEventScreen({
    super.key,
    this.eventId,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedCategory = 'Academic';
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isUploading = false;

  final List<String> _categories = [
    'Academic',
    'Social',
    'Sports',
    'Cultural',
    'Other',
  ];

  bool get _isEditMode => widget.eventId != null;

  @override
  void initState() {
    super.initState();

    // Check if user has permission to create/edit events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final userRole = authProvider.currentUser?.role;

      if (userRole != 'admin' && userRole != 'teacher') {
        // Unauthorized access - redirect back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only admins and teachers can create events'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
        return;
      }
    });

    if (_isEditMode) {
      _loadEvent();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    final eventProvider = context.read<EventProvider>();
    await eventProvider.loadEvent(widget.eventId!);

    final event = eventProvider.selectedEvent;
    if (event != null) {
      setState(() {
        _titleController.text = event.title;
        _descriptionController.text = event.description;
        _locationController.text = event.location;
        _selectedDate = event.eventDate;
        _selectedTime = TimeOfDay.fromDateTime(event.eventDate);
        _selectedCategory = event.category;
        _existingImageUrl = event.imageUrl.isNotEmpty ? event.imageUrl : null;
        if (event.maxAttendees != null) {
          _maxAttendeesController.text = event.maxAttendees.toString();
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event time'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    try {
      // Upload image if selected
      String imageUrl = _existingImageUrl ?? '';
      if (_selectedImage != null && !kIsWeb) {
        final eventId =
            widget.eventId ?? DateTime.now().millisecondsSinceEpoch.toString();
        final imagePath = _storageService.getEventImagePath(eventId);
        imageUrl = await _storageService.uploadImage(
          file: _selectedImage!,
          path: imagePath,
        );
      }

      // Combine date and time
      final eventDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Parse max attendees
      int? maxAttendees;
      if (_maxAttendeesController.text.isNotEmpty) {
        maxAttendees = int.tryParse(_maxAttendeesController.text);
      }

      final event = EventModel(
        eventId: widget.eventId ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        location: _locationController.text.trim(),
        eventDate: eventDate,
        organizer: currentUser.name,
        organizerId: currentUser.uid,
        category: _selectedCategory,
        maxAttendees: maxAttendees,
      );

      bool success;
      if (_isEditMode) {
        success = await eventProvider.updateEvent(event);
      } else {
        success = await eventProvider.createEvent(event);
      }

      setState(() => _isUploading = false);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Event updated successfully'
                    : 'Event created successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(eventProvider.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${_isEditMode ? 'update' : 'create'} event: $e'),
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
        title: Text(_isEditMode ? 'Edit Event' : 'Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _existingImageUrl != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                              child: Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Tap to add event image',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              CustomTextField(
                label: 'Event Title',
                hint: 'Enter event title',
                controller: _titleController,
                prefixIcon: Icons.event,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              CustomTextField(
                label: 'Description',
                hint: 'Enter event description',
                controller: _descriptionController,
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Location
              CustomTextField(
                label: 'Location',
                hint: 'Enter event location',
                controller: _locationController,
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
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

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : 'Select date',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Select time',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Max Attendees (Optional)
              CustomTextField(
                label: 'Max Attendees (Optional)',
                hint: 'Enter maximum number of attendees',
                controller: _maxAttendeesController,
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  return CustomButton(
                    text: _isEditMode ? 'Update Event' : 'Create Event',
                    onPressed: _handleSubmit,
                    isLoading: _isUploading || eventProvider.isLoading,
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

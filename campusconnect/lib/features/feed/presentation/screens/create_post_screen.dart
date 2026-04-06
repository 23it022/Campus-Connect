import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/storage_service.dart';

/// Create Post Screen
/// Allows users to create a new post with text and optional image

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _storageService = StorageService();

  String? _imageUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        final user = context.read<AuthProvider>().currentUser;
        if (user != null) {
          final imageUrl = await _storageService.uploadPostImage(
            userId: user.uid,
            imagePath: image.path,
          );
          setState(() {
            _imageUrl = imageUrl;
            _isUploading = false;
          });
        }
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleCreatePost() async {
    if (!_formKey.currentState!.validate()) return;

    final feedProvider = context.read<FeedProvider>();

    final success = await feedProvider.createPost(
      text: _textController.text.trim(),
      imageUrl: _imageUrl,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedProvider.errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _textController.text.isEmpty ? null : _handleCreatePost,
            child: const Text(
              'Post',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Text input
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      minLines: 5,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() {}),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Image preview
                    if (_imageUrl != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imageUrl!,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() => _imageUrl = null);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),

                    if (_isUploading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _isUploading ? null : _pickImage,
                    tooltip: 'Add image',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_textController.text.length}/500',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

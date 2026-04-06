import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'package:intl/intl.dart';

/// Rate & Feedback Screen
/// Premium UI for submitting feedback and viewing history
class RateFeedbackScreen extends StatefulWidget {
  const RateFeedbackScreen({super.key});

  @override
  State<RateFeedbackScreen> createState() => _RateFeedbackScreenState();
}

class _RateFeedbackScreenState extends State<RateFeedbackScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  int _rating = 0;
  int _hoveredStar = 0;
  String _category = 'App Experience';
  bool _isSubmitting = false;

  late AnimationController _animationController;

  final List<String> _categories = [
    'App Experience',
    'Features',
    'Bug Report',
    'Suggestion',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedback();
    });
  }

  Future<void> _loadFeedback() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId != null) {
      await profileProvider.loadUserFeedback(userId);
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.star_border, color: Colors.white),
              SizedBox(width: 8),
              Text('Please select a rating'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final user = authProvider.currentUser;

    if (user == null) return;

    final success = await profileProvider.submitFeedback(
      userId: user.uid,
      userName: user.name,
      rating: _rating,
      comment: _commentController.text.trim(),
      category: _category,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Thank you for your feedback!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );

        setState(() {
          _rating = 0;
          _category = 'App Experience';
          _commentController.clear();
        });
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
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with Gradient
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Rate & Feedback',
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
                      Color(0xFFFFA726),
                      Color(0xFFFB8C00),
                      Color(0xFFEF6C00),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Submit Feedback Card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFA726),
                                        Color(0xFFFB8C00)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm),
                                  ),
                                  child: const Icon(
                                    Icons.star_rate,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text(
                                  'Rate CampusConnect',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Animated Star Rating
                            _buildAnimatedStarRating(),

                            const SizedBox(height: AppSpacing.lg),

                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              value: _category,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                prefixIcon: const Icon(Icons.category_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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

                            const SizedBox(height: AppSpacing.md),

                            // Comment Field
                            TextFormField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                labelText: 'Your Feedback',
                                hintText: 'Tell us what you think...',
                                prefixIcon: const Icon(Icons.message_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                alignLabelWithHint: true,
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your feedback';
                                }
                                if (value.trim().length < 10) {
                                  return 'Feedback must be at least 10 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Gradient Submit Button
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFA726),
                                    Color(0xFFFB8C00)
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusMd),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFA726)
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _submitFeedback,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Submit Feedback',
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
                ),

                const SizedBox(height: AppSpacing.xl),

                // Feedback History Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Your Feedback History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildFeedbackHistory(),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStarRating() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starValue = index + 1;
          final isSelected = starValue <= _rating;
          final isHovered = starValue <= _hoveredStar;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredStar = starValue),
            onExit: (_) => setState(() => _hoveredStar = 0),
            child: GestureDetector(
              onTap: () {
                setState(() => _rating = starValue);
                _animationController.forward().then((_) {
                  _animationController.reverse();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isSelected || isHovered ? Icons.star : Icons.star_border,
                  size: 48,
                  color: isSelected || isHovered
                      ? Colors.amber
                      : Colors.grey.shade300,
                  shadows: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFeedbackHistory() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        if (profileProvider.isLoading && profileProvider.userFeedback.isEmpty) {
          return const LoadingWidget();
        }

        if (profileProvider.userFeedback.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No feedback submitted yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Be the first to share your thoughts!',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profileProvider.userFeedback.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final feedback = profileProvider.userFeedback[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Stars with gradient
                        ...List.generate(5, (i) {
                          return ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                            ).createShader(bounds),
                            child: Icon(
                              i < feedback.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.white,
                              size: 18,
                            ),
                          );
                        }),
                        const Spacer(),
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFFB8C00)],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            feedback.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      feedback.comment,
                      style: AppTextStyles.body2.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(feedback.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

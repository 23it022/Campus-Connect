import 'package:flutter/material.dart';
import '../../domain/models/reaction_model.dart';
import '../../../../shared/constants/constants.dart';

/// Reaction Picker Widget
/// Bottom sheet showing all available reactions

class ReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;
  final String? currentReaction;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.currentReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          const Text(
            'React to this post',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Reactions grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ReactionType.values.map((reaction) {
              final isSelected = currentReaction == reaction.name;

              return GestureDetector(
                onTap: () {
                  onReactionSelected(reaction.name);
                  Navigator.pop(context);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        reaction.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reaction.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  /// Show reaction picker as bottom sheet
  static void show(
    BuildContext context, {
    required Function(String) onReactionSelected,
    String? currentReaction,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReactionPicker(
        onReactionSelected: onReactionSelected,
        currentReaction: currentReaction,
      ),
    );
  }
}

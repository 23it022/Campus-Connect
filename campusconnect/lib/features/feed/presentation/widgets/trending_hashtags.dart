import 'package:flutter/material.dart';
import '../../../../shared/constants/constants.dart';

/// Trending Hashtags Widget
/// Displays trending hashtags horizontally

class TrendingHashtags extends StatelessWidget {
  final List<String> hashtags;
  final Function(String) onHashtagTap;

  const TrendingHashtags({
    super.key,
    required this.hashtags,
    required this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: AppSpacing.iconMd,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Trending Hashtags',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: hashtags.length,
              itemBuilder: (context, index) {
                final hashtag = hashtags[index];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ActionChip(
                    label: Text(hashtag),
                    onPressed: () => onHashtagTap(hashtag),
                    backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    side: const BorderSide(
                      color: AppColors.primaryLight,
                      width: 1,
                    ),
                    avatar: const Icon(
                      Icons.tag,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

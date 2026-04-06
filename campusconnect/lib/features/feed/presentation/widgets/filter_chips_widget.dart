import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../../../../shared/constants/constants.dart';

/// Filter Chips Widget
/// Shows filter options for the feed

class FilterChipsWidget extends StatelessWidget {
  final FeedFilter currentFilter;
  final Function(FeedFilter) onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All Posts',
            icon: Icons.grid_view,
            filter: FeedFilter.all,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            label: 'Trending',
            icon: Icons.trending_up,
            filter: FeedFilter.trending,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            label: 'Following',
            icon: Icons.people,
            filter: FeedFilter.following,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required FeedFilter filter,
  }) {
    final isSelected = currentFilter == filter;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconSm,
              color: isSelected ? AppColors.white : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onFilterChanged(filter),
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.grey,
            width: 1,
          ),
        ),
        elevation: isSelected ? 4 : 0,
        pressElevation: 2,
      ),
    );
  }
}

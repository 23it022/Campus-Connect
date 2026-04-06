import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/constants/constants.dart';
import '../providers/explore_provider.dart';
import '../../domain/models/university_model.dart';

/// Explore Screen
/// Fetches and displays universities from a REST API
/// Demonstrates: GET requests, JSON parsing, loading/error states, search/filter

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExploreProvider>();
      if (!provider.hasLoaded) {
        provider.loadUniversities();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar with title
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Explore Universities',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                ),
              ),
            ),
            actions: [
              Consumer<ExploreProvider>(
                builder: (context, provider, _) => Padding(
                  padding: const EdgeInsets.only(right: 12, top: 4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${provider.totalCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search universities...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ExploreProvider>().clearSearch();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (value) {
                  context.read<ExploreProvider>().searchUniversities(value);
                  setState(() {}); // Update suffix icon visibility
                },
              ),
            ),
          ),

          // Country Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: Consumer<ExploreProvider>(
                builder: (context, provider, _) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: ExploreProvider.availableCountries.length,
                  itemBuilder: (context, index) {
                    final country = ExploreProvider.availableCountries[index];
                    final isSelected = provider.selectedCountry == country;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(country),
                        selected: isSelected,
                        onSelected: (_) => provider.setCountry(country),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: AppColors.white,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.sm),
          ),

          // Content: Loading / Error / University List
          Consumer<ExploreProvider>(
            builder: (context, provider, _) {
              // Loading state – show shimmer
              if (provider.isLoading) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const _ShimmerUniversityCard(),
                    childCount: 6,
                  ),
                );
              }

              // Error state – show error with retry
              if (provider.errorMessage.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 64,
                          color: AppColors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Failed to load universities',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          provider.errorMessage,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadUniversities(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty state
              if (provider.universities.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: AppColors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No universities found',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Try a different search or country',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Success – show university list
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final university = provider.universities[index];
                    return _UniversityCard(
                      university: university,
                      onTap: () {
                        // Pass data to detail screen via route arguments
                        Navigator.pushNamed(
                          context,
                          '/university-detail',
                          arguments: university,
                        );
                      },
                    );
                  },
                  childCount: provider.universities.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// University Card Widget
/// Displays a single university in a premium card layout
class _UniversityCard extends StatelessWidget {
  final UniversityModel university;
  final VoidCallback onTap;

  const _UniversityCard({
    required this.university,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppShadows.subtle,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // University icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        university.alphaTwoCode,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // University info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          university.name,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                university.stateProvince != null
                                    ? '${university.stateProvince}, ${university.country}'
                                    : university.country,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (university.primaryDomain.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 14,
                                color: AppColors.primary.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  university.primaryDomain,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer Loading Card for universities
class _ShimmerUniversityCard extends StatelessWidget {
  const _ShimmerUniversityCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Shimmer.fromColors(
          baseColor: AppColors.greyLight,
          highlightColor: AppColors.white,
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: AppColors.greyLight,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 10,
                      color: AppColors.greyLight,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 100,
                      height: 10,
                      color: AppColors.greyLight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

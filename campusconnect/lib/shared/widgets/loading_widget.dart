import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/constants.dart';

/// Loading Widget
/// Displays various loading indicators throughout the app

class LoadingWidget extends StatelessWidget {
  final double size;

  const LoadingWidget({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}

/// Shimmer Loading Card
/// Displays a shimmer loading effect for content placeholders
class ShimmerLoadingCard extends StatelessWidget {
  const ShimmerLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Shimmer.fromColors(
          baseColor: AppColors.greyLight,
          highlightColor: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info placeholder
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.greyLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: AppColors.greyLight,
                        ),
                        const SizedBox(height: AppSpacing.xs),
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
              const SizedBox(height: AppSpacing.md),
              // Content placeholder
              Container(
                width: double.infinity,
                height: 14,
                color: AppColors.greyLight,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                height: 14,
                color: AppColors.greyLight,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: 200,
                height: 14,
                color: AppColors.greyLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full page loading indicator
class FullPageLoading extends StatelessWidget {
  final String? message;

  const FullPageLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingWidget(size: 50),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: AppTextStyles.body1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

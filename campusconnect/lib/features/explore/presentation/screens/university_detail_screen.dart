import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/constants/constants.dart';
import '../../domain/models/university_model.dart';

/// University Detail Screen
/// Receives UniversityModel via route arguments (data passing between screens)
/// Displays full university details with website link

class UniversityDetailScreen extends StatelessWidget {
  final UniversityModel university;

  const UniversityDetailScreen({
    super.key,
    required this.university,
  });

  Future<void> _launchUrl(String url) async {
    String fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      fullUrl = 'https://$url';
    }
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                      AppColors.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // University icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            university.alphaTwoCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          university.name,
                          style: AppTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Detail Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Section
                  _buildSectionCard(
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                    ),
                    children: [
                      _buildInfoRow('Country', university.country),
                      if (university.stateProvince != null)
                        _buildInfoRow(
                            'State/Province', university.stateProvince!),
                      _buildInfoRow('Country Code', university.alphaTwoCode),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Domains Section
                  _buildSectionCard(
                    icon: Icons.language,
                    title: 'Domains',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    ),
                    children: university.domains
                        .map((domain) => _buildDomainRow(domain))
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Web Pages Section
                  _buildSectionCard(
                    icon: Icons.public,
                    title: 'Websites',
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    children: university.webPages
                        .map((url) => _buildWebPageRow(url))
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Visit Website Button
                  if (university.primaryWebsite.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppGradients.button,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: AppShadows.elevated,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _launchUrl(university.primaryWebsite),
                        icon: const Icon(Icons.open_in_new,
                            color: Colors.white),
                        label: const Text(
                          'Visit Website',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Section content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainRow(String domain) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            Icons.dns_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              domain,
              style: AppTextStyles.body1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPageRow(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            Icon(
              Icons.link,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                url,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

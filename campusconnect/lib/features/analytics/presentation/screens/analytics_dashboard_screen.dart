import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/constants/constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/analytics_provider.dart';

/// Analytics Dashboard Screen
/// Displays data visualizations using fl_chart:
/// - Stat overview cards (animated counters)
/// - Bar chart: Posts per day (last 7 days)
/// - Line chart: Engagement trend
/// - Pie chart: Content distribution

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      final provider = context.read<AnalyticsProvider>();
      if (user != null && !provider.hasLoaded) {
        provider.loadAnalytics(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar
          SliverAppBar(
            expandedHeight: 120,
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
              title: const Text(
                'Analytics Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.primary),
              ),
            ),
            actions: [
              Consumer<AnalyticsProvider>(
                builder: (context, provider, _) => IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  onPressed: () {
                    final user = context.read<AuthProvider>().currentUser;
                    if (user != null) {
                      provider.refresh(user.uid);
                    }
                  },
                ),
              ),
            ],
          ),

          // Content
          Consumer<AnalyticsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                );
              }

              if (provider.errorMessage.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.grey),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage,
                            style: AppTextStyles.body2),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            final user =
                                context.read<AuthProvider>().currentUser;
                            if (user != null) {
                              provider.loadAnalytics(user.uid);
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Overview Stats Cards
                    _buildStatsRow(provider),
                    const SizedBox(height: AppSpacing.lg),

                    // Bar Chart – Posts Per Day
                    _buildChartCard(
                      title: 'Posts Per Day',
                      subtitle: 'Last 7 days',
                      icon: Icons.bar_chart,
                      iconColor: AppColors.primary,
                      child: SizedBox(
                        height: 220,
                        child: _buildBarChart(provider.postsPerDay),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Line Chart – Engagement Trend
                    _buildChartCard(
                      title: 'Engagement Trend',
                      subtitle: 'Likes + Comments over 7 days',
                      icon: Icons.trending_up,
                      iconColor: AppColors.success,
                      child: SizedBox(
                        height: 220,
                        child: _buildLineChart(provider.engagementTrend),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Pie Chart – Content Distribution
                    _buildChartCard(
                      title: 'Content Distribution',
                      subtitle: 'Platform overview',
                      icon: Icons.pie_chart,
                      iconColor: AppColors.secondary,
                      child: SizedBox(
                        height: 240,
                        child:
                            _buildPieChart(provider.contentDistribution),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Overview Stats Row with animated cards
  Widget _buildStatsRow(AnalyticsProvider provider) {
    final stats = provider.overviewStats;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Posts',
                stats['posts'] ?? 0,
                Icons.article_outlined,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Events',
                stats['events'] ?? 0,
                Icons.event_outlined,
                AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Groups',
                stats['groups'] ?? 0,
                Icons.group_outlined,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Likes',
                stats['likes'] ?? 0,
                Icons.favorite_outline,
                AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: AppTextStyles.h2.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  /// Chart Card wrapper
  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.body1
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  /// Bar Chart – Posts Per Day
  Widget _buildBarChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data
        .map((e) => (e['count'] as int).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY + 2 : 5,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${data[group.x.toInt()]['day']}\n${rod.toY.toInt()} posts',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()]['day'],
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt().toDouble()) {
                  return Text(
                    '${value.toInt()}',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.greyLight,
            strokeWidth: 1,
          ),
        ),
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data[index]['count'] as int).toDouble(),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Line Chart – Engagement Trend
  Widget _buildLineChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data
        .map((e) => (e['engagement'] as int).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${data[spot.x.toInt()]['day']}\n${spot.y.toInt()} interactions',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.greyLight,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()]['day'],
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY > 0 ? maxY + 2 : 5,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (index) => FlSpot(
                index.toDouble(),
                (data[index]['engagement'] as int).toDouble(),
              ),
            ),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.success, Color(0xFF2E7D32)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.success,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.3),
                  AppColors.success.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pie Chart – Content Distribution
  Widget _buildPieChart(Map<String, int> data) {
    if (data.isEmpty || data.values.every((v) => v == 0)) {
      return const Center(child: Text('No data available'));
    }

    final colors = [
      AppColors.primary,
      AppColors.warning,
      AppColors.success,
      AppColors.info,
    ];

    final total = data.values.fold(0, (sum, v) => sum + v);

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: data.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final mapEntry = entry.value;
                final percentage = total > 0
                    ? (mapEntry.value / total * 100).toStringAsFixed(1)
                    : '0';
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: mapEntry.value.toDouble(),
                  title: '$percentage%',
                  radius: 55,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final mapEntry = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${mapEntry.key} (${mapEntry.value})',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

import '../../../../core/base/base_provider.dart';
import '../../data/services/analytics_service.dart';

/// Analytics Provider
/// Manages state for the Analytics Dashboard
/// Fetches aggregated data for charts and stat cards

class AnalyticsProvider extends BaseProvider {
  final AnalyticsService _analyticsService = AnalyticsService();

  // State
  Map<String, int> _overviewStats = {};
  List<Map<String, dynamic>> _postsPerDay = [];
  List<Map<String, dynamic>> _engagementTrend = [];
  Map<String, int> _contentDistribution = {};
  bool _hasLoaded = false;

  // Getters
  Map<String, int> get overviewStats => _overviewStats;
  List<Map<String, dynamic>> get postsPerDay => _postsPerDay;
  List<Map<String, dynamic>> get engagementTrend => _engagementTrend;
  Map<String, int> get contentDistribution => _contentDistribution;
  bool get hasLoaded => _hasLoaded;

  /// Load all analytics data
  Future<void> loadAnalytics(String userId) async {
    await executeOperation(() async {
      // Fetch all data in parallel
      final results = await Future.wait([
        _analyticsService.getOverviewStats(userId),
        _analyticsService.getPostsPerDay(),
        _analyticsService.getEngagementTrend(),
        _analyticsService.getContentDistribution(),
      ]);

      _overviewStats = results[0] as Map<String, int>;
      _postsPerDay = results[1] as List<Map<String, dynamic>>;
      _engagementTrend = results[2] as List<Map<String, dynamic>>;
      _contentDistribution = results[3] as Map<String, int>;
      _hasLoaded = true;
      notifyListeners();
    });
  }

  /// Refresh analytics
  Future<void> refresh(String userId) async {
    _hasLoaded = false;
    await loadAnalytics(userId);
  }
}

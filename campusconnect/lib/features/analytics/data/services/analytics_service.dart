import 'package:cloud_firestore/cloud_firestore.dart';

/// Analytics Service
/// Fetches aggregated data from Firestore for charts and visualizations
/// Provides data for bar charts, line charts, pie charts, and stat cards

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get total counts for stat cards
  Future<Map<String, int>> getOverviewStats(String userId) async {
    try {
      final posts = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      final events = await _firestore.collection('events').get();

      final groups = await _firestore.collection('groups').get();

      int totalLikes = 0;
      int totalComments = 0;
      for (var doc in posts.docs) {
        final data = doc.data();
        totalLikes += ((data['likes'] as List?)?.length ?? 0);
        totalComments += ((data['commentCount'] as int?) ?? 0);
      }

      return {
        'posts': posts.docs.length,
        'events': events.docs.length,
        'groups': groups.docs.length,
        'likes': totalLikes,
        'comments': totalComments,
      };
    } catch (e) {
      return {
        'posts': 0,
        'events': 0,
        'groups': 0,
        'likes': 0,
        'comments': 0,
      };
    }
  }

  /// Get posts per day for bar chart (last 7 days)
  Future<List<Map<String, dynamic>>> getPostsPerDay() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('posts')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('timestamp')
          .get();

      // Group posts by day
      Map<String, int> dailyCounts = {};
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: 6 - i));
        final key = '${day.month}/${day.day}';
        dailyCounts[key] = 0;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          final key = '${timestamp.month}/${timestamp.day}';
          if (dailyCounts.containsKey(key)) {
            dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
          }
        }
      }

      return dailyCounts.entries
          .map((e) => {'day': e.key, 'count': e.value})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get engagement data for line chart (last 7 days)
  Future<List<Map<String, dynamic>>> getEngagementTrend() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('posts')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('timestamp')
          .get();

      Map<String, int> dailyEngagement = {};
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: 6 - i));
        final key = '${day.month}/${day.day}';
        dailyEngagement[key] = 0;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          final key = '${timestamp.month}/${timestamp.day}';
          final likes = (data['likes'] as List?)?.length ?? 0;
          final comments = (data['commentCount'] as int?) ?? 0;
          if (dailyEngagement.containsKey(key)) {
            dailyEngagement[key] =
                (dailyEngagement[key] ?? 0) + likes + comments;
          }
        }
      }

      return dailyEngagement.entries
          .map((e) => {'day': e.key, 'engagement': e.value})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get content distribution for pie chart
  Future<Map<String, int>> getContentDistribution() async {
    try {
      final posts = await _firestore.collection('posts').get();
      final events = await _firestore.collection('events').get();
      final groups = await _firestore.collection('groups').get();
      final users = await _firestore.collection('users').get();

      return {
        'Posts': posts.docs.length,
        'Events': events.docs.length,
        'Groups': groups.docs.length,
        'Users': users.docs.length,
      };
    } catch (e) {
      return {
        'Posts': 0,
        'Events': 0,
        'Groups': 0,
        'Users': 0,
      };
    }
  }
}

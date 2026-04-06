# LAB 11 – Advanced Feature: Data Visualization (Charts)

**Project Name:** CampusConnect – Student Social Media App  
**Technology:** Flutter (Dart) with Firebase  
**Advanced Feature:** Data Visualization using `fl_chart` package  
**Chart Types:** Bar Chart, Line Chart, Pie Chart

---

## 1. Introduction

Advanced features elevate a mobile application from basic functionality to real-world usefulness. In this practical, we implemented **Data Visualization** using the `fl_chart` package to create an **Analytics Dashboard** with interactive charts showing platform engagement and content distribution data.

We implemented:

- **Bar Chart** – Posts created per day (last 7 days)
- **Line Chart** – Engagement trend (likes + comments over time)
- **Pie Chart** – Content distribution across platform categories
- **Stat Overview Cards** – Real-time counts for posts, events, groups, likes
- **Firestore data aggregation** – Querying and computing chart data from collections

---

## 2. Practical Objectives

- **Integrate charts/graphs** for data visualization using `fl_chart`
- **Aggregate Firestore data** for meaningful visual presentations
- **Display interactive charts** with touch tooltips, gradients, and animations
- **Show real-time statistics** from the database
- **Implement loading and error states** for data fetching

---

## 3. Step-by-Step Implementation

### STEP 1: Adding the fl_chart Package

**File:** `pubspec.yaml`

```yaml
dependencies:
  fl_chart: ^0.69.0
```

```bash
flutter pub get
```

The `fl_chart` package provides Flutter-native chart widgets: `BarChart`, `LineChart`, `PieChart`, and more — all with animation and touch interaction support out of the box.

---

### STEP 2: Analytics Service (Firestore Data Aggregation)

**File:** `lib/features/analytics/data/services/analytics_service.dart`

The service queries Firestore and aggregates data for charts:

```dart
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Overview stats (stat cards)
  Future<Map<String, int>> getOverviewStats(String userId) async {
    final posts = await _firestore.collection('posts')
        .where('userId', isEqualTo: userId).get();
    final events = await _firestore.collection('events').get();
    final groups = await _firestore.collection('groups').get();

    int totalLikes = 0;
    for (var doc in posts.docs) {
      totalLikes += ((doc.data()['likes'] as List?)?.length ?? 0);
    }

    return {
      'posts': posts.docs.length,
      'events': events.docs.length,
      'groups': groups.docs.length,
      'likes': totalLikes,
    };
  }

  /// Posts per day for bar chart (last 7 days)
  Future<List<Map<String, dynamic>>> getPostsPerDay() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final snapshot = await _firestore.collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('timestamp').get();

    // Group by date → { "3/15": 5, "3/16": 2, ... }
    Map<String, int> dailyCounts = {};
    for (var doc in snapshot.docs) {
      final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
      final key = '${timestamp.month}/${timestamp.day}';
      dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
    }
    return dailyCounts.entries.map((e) => {'day': e.key, 'count': e.value}).toList();
  }

  /// Content distribution for pie chart
  Future<Map<String, int>> getContentDistribution() async {
    return {
      'Posts': (await _firestore.collection('posts').get()).docs.length,
      'Events': (await _firestore.collection('events').get()).docs.length,
      'Groups': (await _firestore.collection('groups').get()).docs.length,
      'Users': (await _firestore.collection('users').get()).docs.length,
    };
  }
}
```

---

### STEP 3: Analytics Provider (State Management)

**File:** `lib/features/analytics/presentation/providers/analytics_provider.dart`

```dart
class AnalyticsProvider extends BaseProvider {
  Map<String, int> _overviewStats = {};
  List<Map<String, dynamic>> _postsPerDay = [];
  List<Map<String, dynamic>> _engagementTrend = [];
  Map<String, int> _contentDistribution = {};

  /// Load all analytics data in parallel
  Future<void> loadAnalytics(String userId) async {
    await executeOperation(() async {
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
      notifyListeners();
    });
  }
}
```

---

### STEP 4: Bar Chart – Posts Per Day

```dart
BarChart(
  BarChartData(
    alignment: BarChartAlignment.spaceAround,
    barGroups: List.generate(data.length, (index) =>
      BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index]['count'].toDouble(),
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
    // Touch tooltips for interactivity
    barTouchData: BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) =>
          BarTooltipItem('${rod.toY.toInt()} posts', ...),
      ),
    ),
  ),
)
```

---

### STEP 5: Line Chart – Engagement Trend

```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: List.generate(data.length, (i) =>
          FlSpot(i.toDouble(), data[i]['engagement'].toDouble()),
        ),
        isCurved: true,
        gradient: LinearGradient(colors: [AppColors.success, Color(0xFF2E7D32)]),
        barWidth: 3,
        dotData: FlDotData(show: true),
        // Gradient fill below the line
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [AppColors.success.withOpacity(0.3), AppColors.success.withOpacity(0.05)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ],
  ),
)
```

---

### STEP 6: Pie Chart – Content Distribution

```dart
PieChart(
  PieChartData(
    sectionsSpace: 3,
    centerSpaceRadius: 40,
    sections: data.entries.map((entry) =>
      PieChartSectionData(
        color: colors[index],
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 55,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ).toList(),
  ),
)
```

---

### STEP 7: Navigation Integration

**Access from Profile Screen → Quick Actions → "Analytics Dashboard"**

```dart
_buildPremiumMenuCard(
  context,
  icon: Icons.analytics_outlined,
  title: 'Analytics Dashboard',
  subtitle: 'View charts and insights',
  onTap: () => Navigator.pushNamed(context, '/analytics'),
),
```

**Route:** `AppRoutes.analytics: '/analytics'`

---

## 4. Summary

| Component | File | Purpose |
|---|---|---|
| **Package** | `pubspec.yaml` | `fl_chart: ^0.69.0` for chart widgets |
| **Service** | `analytics_service.dart` | Firestore data aggregation |
| **Provider** | `analytics_provider.dart` | State management with parallel data loading |
| **Dashboard** | `analytics_dashboard_screen.dart` | All charts and stat cards |
| **Route** | `app_router.dart` | `/analytics` route |
| **Entry Point** | `profile_screen.dart` | Analytics card in Quick Actions |

---

## 5. Expected Outcome

✅ **Bar Chart** showing posts per day (last 7 days) with gradient bars and tooltips  
✅ **Line Chart** showing engagement trend with curved line and gradient fill  
✅ **Pie Chart** showing content distribution with percentage labels and legend  
✅ **Stat Cards** with real-time counts for posts, events, groups, and likes  
✅ **Touch interactivity** on all charts with tooltip popups  
✅ **Loading and error states** with retry functionality  
✅ **Firestore data aggregation** from multiple collections

---

## 6. Conclusion

This practical successfully integrated **Data Visualization** as an advanced feature using the `fl_chart` package. The Analytics Dashboard provides users with meaningful insights into platform activity through interactive bar, line, and pie charts. Data is aggregated in real-time from Firestore collections and displayed with premium UI elements including gradients, tooltips, and animated transitions.

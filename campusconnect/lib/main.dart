import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'shared/theme/themes.dart';
import 'shared/constants/constants.dart';
import 'shared/navigation/app_router.dart';
import 'shared/navigation/navigation_service.dart';

// Import all providers
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/feed/presentation/providers/feed_provider.dart';
import 'features/events/presentation/providers/event_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/messaging/presentation/providers/messaging_provider.dart';
import 'features/groups/presentation/providers/group_provider.dart';
import 'features/teacher/presentation/providers/teacher_provider.dart';
import 'features/explore/presentation/providers/explore_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/analytics/presentation/providers/analytics_provider.dart';

/// Main entry point for CampusConnect app
/// Initializes Firebase and sets up the app with Provider state management

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider (independent)
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initAuthListener(),
        ),

        // Feed Provider (depends on Auth)
        ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
          create: (context) => FeedProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (_, auth, previous) => previous ?? FeedProvider(auth),
        ),

        // Event Provider (independent)
        ChangeNotifierProvider(
          create: (_) => EventProvider(),
        ),

        // Profile Provider (independent)
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),

        // Messaging Provider (independent)
        ChangeNotifierProvider(
          create: (_) => MessagingProvider(),
        ),

        // Group Provider (independent)
        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
        ),

        // Teacher Provider (independent)
        ChangeNotifierProvider(
          create: (_) => TeacherProvider(),
        ),

        // Explore Provider (independent) – manages API data
        ChangeNotifierProvider(
          create: (_) => ExploreProvider(),
        ),

        // Notification Provider (independent) – manages notifications
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),

        // Analytics Provider (independent) – manages chart data
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(),
        ),
      ],
      child: MaterialApp(
        // App configuration
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: AppTheme.lightTheme,

        // Navigation key for context-independent navigation
        navigatorKey: NavigationService.navigatorKey,

        // Start with splash screen
        initialRoute: AppRoutes.splash,

        // Named routes for navigation
        routes: AppRouter.getRoutes(),

        // Generate route handler for dynamic routes
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

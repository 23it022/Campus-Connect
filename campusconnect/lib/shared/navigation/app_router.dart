import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/feed/presentation/screens/create_post_screen.dart';
import '../../features/feed/presentation/screens/post_detail_screen.dart';
import '../../features/feed/presentation/screens/bookmarks_screen.dart';
import '../../features/feed/presentation/screens/edit_post_screen.dart';
import '../../features/feed/domain/models/post_model.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/profile/presentation/screens/rate_feedback_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/create_support_ticket_screen.dart';
import '../../features/profile/presentation/screens/support_ticket_detail_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/presentation/screens/teacher_login_screen.dart';
import '../../features/teacher/presentation/screens/teacher_signup_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/screens/university_detail_screen.dart';
import '../../features/explore/domain/models/university_model.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';

/// App Router
/// Centralized route management for the application
/// Provides type-safe navigation with named routes

class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String home = '/home';

  // Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  // Feed routes
  static const String feed = '/feed';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String bookmarks = '/bookmarks';
  static const String editPost = '/edit-post';

  // Messaging routes
  static const String chatList = '/chat-list';
  static const String chat = '/chat';

  // Events routes
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String createEvent = '/create-event';

  // Groups routes
  static const String groups = '/groups';
  static const String groupDetail = '/group-detail';
  static const String createGroup = '/create-group';

  // Search routes
  static const String search = '/search';

  // Notifications routes
  static const String notifications = '/notifications';

  // Profile support routes
  static const String rateFeedback = '/rate-feedback';
  static const String helpSupport = '/help-support';
  static const String createSupportTicket = '/create-support-ticket';
  static const String supportTicketDetail = '/support-ticket-detail';
  static const String settings = '/settings';

  // Teacher routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherLogin = '/teacher/login';
  static const String teacherSignup = '/teacher/signup';
  static const String teacherSubjects = '/teacher/subjects';

  // Explore routes
  static const String explore = '/explore';
  static const String universityDetail = '/university-detail';

  // Analytics routes
  static const String analytics = '/analytics';
}

class AppRouter {
  /// Get routes map for MaterialApp
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.splash: (context) => const SplashScreen(),
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.signup: (context) => const SignupScreen(),
      AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
      AppRoutes.home: (context) => const HomeScreen(),
      AppRoutes.createPost: (context) => const CreatePostScreen(),
      AppRoutes.bookmarks: (context) => const BookmarksScreen(),
      AppRoutes.createEvent: (context) => const CreateEventScreen(),
      AppRoutes.rateFeedback: (context) => const RateFeedbackScreen(),
      AppRoutes.helpSupport: (context) => const HelpSupportScreen(),
      AppRoutes.createSupportTicket: (context) =>
          const CreateSupportTicketScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
      AppRoutes.teacherDashboard: (context) => const TeacherDashboardScreen(),
      AppRoutes.teacherLogin: (context) => const TeacherLoginScreen(),
      AppRoutes.teacherSignup: (context) => const TeacherSignupScreen(),
      AppRoutes.explore: (context) => const ExploreScreen(),
      AppRoutes.notifications: (context) => const NotificationsScreen(),
      AppRoutes.analytics: (context) => const AnalyticsDashboardScreen(),
    };
  }

  /// Generate routes based on route settings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Handle dynamic event  routes
    if (settings.name?.startsWith('/events/') ?? false) {
      final segments = settings.name!.split('/');
      if (segments.length >= 3) {
        final eventId = segments[2];

        // Edit event route
        if (segments.length == 4 && segments[3] == 'edit') {
          return MaterialPageRoute(
            builder: (_) => CreateEventScreen(eventId: eventId),
          );
        }

        // Event detail route
        return MaterialPageRoute(
          builder: (_) => EventDetailScreen(eventId: eventId),
        );
      }
    }

    // Handle support ticket detail route
    if (settings.name == AppRoutes.supportTicketDetail) {
      final ticketId = settings.arguments as String?;
      if (ticketId == null) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ticket not found'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => SupportTicketDetailScreen(ticketId: ticketId),
      );
    }

    // Handle university detail route (data passing via arguments)
    if (settings.name == AppRoutes.universityDetail) {
      final university = settings.arguments as UniversityModel?;
      if (university == null) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('University not found'),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => UniversityDetailScreen(university: university),
      );
    }
    switch (settings.name) {
      case AppRoutes.postDetail:
        final post = settings.arguments as PostModel?;
        if (post == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Post not found'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(post: post),
        );

      case AppRoutes.editPost:
        final post = settings.arguments as PostModel?;
        if (post == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Post not found'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const EditPostScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}

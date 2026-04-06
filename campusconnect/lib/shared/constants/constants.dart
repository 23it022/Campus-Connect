import 'package:flutter/material.dart';

/// App-wide constants and configuration values
/// This file contains colors, text styles, spacing, and Firebase collection names

// ============================================================================
// COLORS
// ============================================================================

class AppColors {
  // Primary colors - Modern purple gradient
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5848E8);
  static const Color primaryLight = Color(0xFF8B84FF);

  // Secondary colors
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF8FA3);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);

  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
}

// ============================================================================
// TEXT STYLES
// ============================================================================

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Caption and small text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

// ============================================================================
// SPACING & SIZING
// ============================================================================

class AppSpacing {
  // Padding values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
}

// ============================================================================
// FIREBASE COLLECTION NAMES
// ============================================================================

class FirebaseCollections {
  static const String users = 'users';
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String notifications = 'notifications';
  static const String likes = 'likes';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String events = 'events';
  static const String groups = 'groups';
  static const String reports = 'reports';
  static const String hashtags = 'hashtags';
}

// ============================================================================
// FIREBASE STORAGE PATHS
// ============================================================================

class FirebaseStoragePaths {
  static const String profileImages = 'profile_images';
  static const String postImages = 'post_images';
  static const String eventImages = 'event_images';
  static const String groupImages = 'group_images';
}

// ============================================================================
// APP STRINGS
// ============================================================================

class AppStrings {
  static const String appName = 'CampusConnect';
  static const String tagline = 'Connect. Share. Learn.';

  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'No internet connection';
  static const String errorAuth = 'Authentication failed';

  // Success messages
  static const String successPostCreated = 'Post created successfully!';
  static const String successProfileUpdated = 'Profile updated successfully!';
}

// ============================================================================
// GRADIENTS
// ============================================================================

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryExtended = LinearGradient(
    colors: [Color(0xFF7C74FF), AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splash = LinearGradient(
    colors: [Color(0xFF7C74FF), AppColors.primary, Color(0xFF4A3FD4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient button = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// ============================================================================
// SHADOWS
// ============================================================================

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

// ============================================================================
// VALIDATION
// ============================================================================

class AppValidation {
  static const int minPasswordLength = 7;
  static const int maxBioLength = 150;
  static const int maxPostLength = 500;
}

/// App Constants
/// Contains app-wide constants like years, semesters, designations, etc.

class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'Campus Connect';
  static const String appVersion = '1.0.0';

  // Years of Study
  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  // Semesters
  static const List<String> semesters = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
  ];

  // Teacher Designations
  static const List<String> teacherDesignations = [
    'Professor',
    'Associate Professor',
    'Assistant Professor',
    'Lecturer',
    'Lab Instructor',
  ];

  // Event Types
  static const List<String> eventTypes = [
    'Technical',
    'Cultural',
    'Sports',
    'Academic',
    'Workshop',
    'Seminar',
    'Other',
  ];

  // Announcement Priority
  static const List<String> announcementPriority = [
    'low',
    'medium',
    'high',
    'urgent',
  ];

  // Target Audience
  static const List<String> targetAudience = [
    'all',
    'students',
    'teachers',
    'department',
    'year',
  ];

  // File Size Limits (in bytes)
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxPdfSize = 20 * 1024 * 1024; // 20MB
  static const int maxExcelSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB

  // Allowed File Extensions
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
  static const List<String> allowedDocExtensions = [
    'pdf',
  ];
  static const List<String> allowedExcelExtensions = [
    'xlsx',
    'xls',
  ];

  // Attendance Threshold
  static const double minAttendancePercentage = 75.0;

  // Default Profile Image URL
  static const String defaultProfileImage =
      'https://ui-avatars.com/api/?name=User&background=random';

  // Pagination
  static const int postsPerPage = 10;
  static const int notificationsPerPage = 20;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy hh:mm a';
  static const String fullDateFormat = 'EEEE, dd MMMM yyyy';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxBioLength = 200;
  static const int maxPostTextLength = 500;
  static const int maxAnnouncementLength = 1000;

  // Error Messages
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String permissionDenied = 'Permission denied';
  static const String authError = 'Authentication error';

  // Success Messages
  static const String profileUpdated = 'Profile updated successfully';
  static const String attendanceMarked = 'Attendance marked successfully';
  static const String resultPublished = 'Result published successfully';
  static const String noteSaved = 'Note saved successfully';
  static const String userCreated = 'User created successfully';

  // Shared Preferences Keys
  static const String tokenKey = 'fcm_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String themeKey = 'theme_mode';
}

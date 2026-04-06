import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Date/Time Formatting Utilities
/// Provides consistent date and time formatting across the app

class DateFormatter {
  // Prevent instantiation
  DateFormatter._();

  /// Format date to 'dd MMM yyyy' (e.g., 15 Jan 2026)
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format time to 'hh:mm a' (e.g., 10:30 AM)
  static String formatTime(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }

  /// Format date and time to 'dd MMM yyyy hh:mm a' (e.g., 15 Jan 2026 10:30 AM)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Format date to full format 'EEEE, dd MMMM yyyy' (e.g., Monday, 15 January 2026)
  static String formatFullDate(DateTime date) {
    return DateFormat(AppConstants.fullDateFormat).format(date);
  }

  /// Format relative time (e.g., '2 hours ago', 'Just now')
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Format time for chat messages
  /// Shows 'HH:mm' for today, 'Yesterday' for yesterday, 'dd MMM' for older
  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM').format(dateTime);
    }
  }

  /// Format for attendance date (e.g., '15 Jan')
  static String formatAttendanceDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  /// Format for exam date (e.g., '15th January 2026')
  static String formatExamDate(DateTime date) {
    return DateFormat('do MMMM yyyy').format(date);
  }

  /// Format month and year (e.g., 'January 2026')
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format day of week (e.g., 'Monday')
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get academic year from date
  /// Returns format like '2025-2026'
  static String getAcademicYear(DateTime date) {
    // Academic year starts in July
    if (date.month >= 7) {
      return '${date.year}-${date.year + 1}';
    } else {
      return '${date.year - 1}-${date.year}';
    }
  }

  /// Get current academic year
  static String getCurrentAcademicYear() {
    return getAcademicYear(DateTime.now());
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Calculate age from birthdate
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

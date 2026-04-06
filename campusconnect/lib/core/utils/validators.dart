import '../constants/app_constants.dart';

/// Form Validators
/// Provides validation functions for common form fields

class Validators {
  // Prevent instantiation
  Validators._();

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Check if name contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Indian phone number validation (10 digits)
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  /// Roll number validation
  static String? validateRollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Roll number is required';
    }

    if (value.length < 5) {
      return 'Roll number must be at least 5 characters';
    }

    return null;
  }

  /// Employee ID validation
  static String? validateEmployeeId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee ID is required';
    }

    if (value.length < 4) {
      return 'Employee ID must be at least 4 characters';
    }

    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Number validation
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  /// Marks validation
  static String? validateMarks(String? value, int maxMarks) {
    if (value == null || value.isEmpty) {
      return 'Marks are required';
    }

    final marks = double.tryParse(value);
    if (marks == null) {
      return 'Enter valid marks';
    }

    if (marks < 0) {
      return 'Marks cannot be negative';
    }

    if (marks > maxMarks) {
      return 'Marks cannot exceed $maxMarks';
    }

    return null;
  }

  /// URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }

    return null;
  }

  /// Bio validation
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }

    if (value.length > AppConstants.maxBioLength) {
      return 'Bio must be less than ${AppConstants.maxBioLength} characters';
    }

    return null;
  }

  /// Course code validation
  static String? validateCourseCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course code is required';
    }

    // Course code format: 3 letters + 3 digits (e.g., CSE101)
    final courseCodeRegex = RegExp(r'^[A-Z]{2,4}\d{3}$');
    if (!courseCodeRegex.hasMatch(value.toUpperCase())) {
      return 'Enter valid course code (e.g., CSE301)';
    }

    return null;
  }

  /// Credits validation
  static String? validateCredits(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credits are required';
    }

    final credits = int.tryParse(value);
    if (credits == null) {
      return 'Enter valid credits';
    }

    if (credits < 1 || credits > 6) {
      return 'Credits must be between 1 and 6';
    }

    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Generic max length validation
  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }
}

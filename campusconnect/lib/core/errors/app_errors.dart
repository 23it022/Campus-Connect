/// Custom Exception Classes
/// Defines all custom exceptions used in the app

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException([String message = 'Network error occurred'])
      : super(message, code: 'network-error');
}

/// Authentication related exceptions
class AuthenticationException extends AppException {
  AuthenticationException([String message = 'Authentication failed'])
      : super(message, code: 'auth-error');
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException([String message = 'Validation failed'])
      : super(message, code: 'validation-error');
}

/// Resource not found exceptions
class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, code: 'not-found');
}

/// Permission denied exceptions
class PermissionDeniedException extends AppException {
  PermissionDeniedException([String message = 'Permission denied'])
      : super(message, code: 'permission-denied');
}

/// Server error exceptions
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred'])
      : super(message, code: 'server-error');
}
